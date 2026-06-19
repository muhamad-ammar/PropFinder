//
//  CoreDataStack.swift
//  PropFinder
//
//  Created by Muhammad Ammar on 18/06/2026.
//

import CoreData
import Foundation

/// The `CoreDataStack` manages the local SQLite database lifecycle.
/// In an offline-first architecture, this is the final source of truth for the UI layer.
final class CoreDataStack {
    
    // MARK: - Singleton Instance
    /// Shared singleton instance to guarantee that only one coordinator manages the database file.
    static let shared = CoreDataStack()
    
    /// Private initializer prevents other files from creating separate instances, avoiding database locks.
    private init() {}
    
    // MARK: - Persistent Container
    /// The container acts as the wrapper for the database model, the underlying file store, and the contexts.
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The name here MUST exactly match the filename of your `PropFinder.xcdatamodeld` file.
         Xcode looks for that file to compile the object-relational mapping schema.
         */
        let container = NSPersistentContainer(name: "PropFinder")
        
        // Load the actual physical database file (SQLite) from disk.
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 In a production app, handle this gracefully (e.g., alert the user, delete and rebuild cache).
                 For development/testing, a fatalError will crash early if the model changes mismatch.
                 */
                fatalError("Unresolved Core Data storage loading error: \(error), \(error.userInfo)")
            }
        }
        
        // MARK: - Concurrency & Sync Optimization Policies
        
        /// CRITICAL FOR SENIOR ROLES:
        /// Automatically merge background context modifications into the main view context.
        /// When our repository saves a background network sync, the UI context updates instantly.
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        /// Conflict Resolution Policy:
        /// If the background thread and main thread modify the same database row simultaneously,
        /// `NSMergeByPropertyObjectTrumpMergePolicy` forces the incoming memory attributes to overwrite the disk.
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    // MARK: - Context Accessors
    
    /// Main Queue Context:
    /// This context runs on the main thread. The ViewModels and TableViews read directly from this context.
    /// Never perform heavy disk writes or complex loops here, or your scrolling frames will drop.
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /// Background Queue Context:
    /// Generates a completely separate, private concurrent queue context.
    /// We pass all network JSON payloads into this context to execute decoding and database insertion
    /// entirely off the main thread.
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
}
