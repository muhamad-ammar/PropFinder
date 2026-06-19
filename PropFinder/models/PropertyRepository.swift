//
//  PropertyRepositoryProtocol.swift
//  PropFinder
//
//  Created by Muhammad Ammar on 18/06/2026.
//


import Foundation
import CoreData

/// The Repository Protocol provides a clean interface for the ViewModel.
/// The ViewModel never needs to know *where* the data comes from (Firestore or Core Data).
protocol PropertyRepositoryProtocol {
    /// Retrieves properties following the offline-first strategy.
    func getProperties() async throws -> [Property]
}

/// The concrete orchestrator that coordinates the Network and local Database.
final class PropertyRepository: PropertyRepositoryProtocol {
    
    private let remoteDataSource: PropertyRemoteDataSourceProtocol
    private let coreDataStack: CoreDataStack
    
    /// Dependency Injection via initializer allows for effortless unit testing.
    init(remoteDataSource: PropertyRemoteDataSourceProtocol, coreDataStack: CoreDataStack = .shared) {
        self.remoteDataSource = remoteDataSource
        self.coreDataStack = coreDataStack
    }
    
    /// The Core Architecture Algorithm:
    /// 1. Attempt to fetch fresh data from the network background thread.
    /// 2. If network works -> Save updates directly into the local database file.
    /// 3. If network fails -> Catch the error and swallow it silently.
    /// 4. ALWAYS load from the local database as the final source of truth for the UI.
    func getProperties() async throws -> [Property] {
        do {
            // 1. Hit the remote network data source
            let remoteItems = try await remoteDataSource.fetchRemoteProperties()
            
            // 2. Persist directly to local database disk on a background context
            try await saveToLocalCache(remoteItems)
        } catch {
            // 3. Fallback silently. The user still gets their cached data instead of an error screen.
            print("Repository Log: Remote sync failed (\(error.localizedDescription)). Showing cached data.")
        }
        
        // 4. Return local storage records to guarantee instant UI rendering
        return try fetchLocalProperties()
    }
    
    // MARK: - Core Data Internal Helpers
    
    /// Maps domain values into managed entities completely off the main thread.
    private func saveToLocalCache(_ properties: [Property]) async throws {
        // Spawn a brand new concurrent background queue context
        let backgroundContext = coreDataStack.newBackgroundContext()
        
        // Execute the database modifications inside a perform block to stick to the context's private queue
        try await backgroundContext.perform {
            for item in properties {
                let request: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()
                // Predicate optimization: verify if this record already exists to prevent duplication
                request.predicate = NSPredicate(format: "id == %@", item.id)
                
                // If it exists, update it; if it doesn't, instantiate a new managed object in this context
                let entity = (try backgroundContext.fetch(request).first) ?? PropertyEntity(context: backgroundContext)
                
                // Map fields from API Struct -> DB Entity
                entity.id = item.id
                entity.title = item.title
                entity.price = item.price
                entity.location = item.location
                entity.bedrooms = Int16(item.bedrooms)
                entity.bathrooms = Int16(item.bathrooms)
                entity.imageUrl = item.imageUrl
                entity.isFavorite = item.isFavorite
                entity.createdAt = item.createdAt
            }
            
            // Only write to the physical disk if there are uncommitted record mutations
            if backgroundContext.hasChanges {
                try backgroundContext.save()
                print("Repository Log: Cache successfully updated with \(properties.count) items.")
            }
        }
    }
    
    /// Reads records from the Main View Context so they can be securely consumed on the Main Thread.
    private func fetchLocalProperties() throws -> [Property] {
        let context = coreDataStack.mainContext
        let request: NSFetchRequest<PropertyEntity> = PropertyEntity.fetchRequest()
        
        // Senior Detail: Always enforce explicit sort order for list layouts (Newest first)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let entities = try context.fetch(request)
        
        // Map DB Entities back into clean, immutable Swift value Structs
        return entities.map { entity in
            Property(
                id: entity.id ?? "",
                title: entity.title ?? "",
                price: entity.price,
                location: entity.location ?? "",
                bedrooms: Int(entity.bedrooms),
                bathrooms: Int(entity.bathrooms),
                imageUrl: entity.imageUrl ?? "",
                isFavorite: entity.isFavorite,
                createdAt: entity.createdAt ?? Date()
            )
        }
    }
}
