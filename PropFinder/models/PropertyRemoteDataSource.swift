//
//  PropertyRemoteDataSource.swift
//  PropFinder
//
//  Created by Muhammad Ammar on 18/06/2026.
//


import Foundation

/// Defines the capabilities of the remote networking client.
/// This abstraction allows us to inject a fake mock data source during testing without hitting live servers.
protocol PropertyRemoteDataSourceProtocol {
    /// Asynchronously fetches raw property items from the network layer.
    /// Uses modern Swift concurrency (`async throws`) instead of legacy completion closures.
    func fetchRemoteProperties() async throws -> [Property]
}

/// The concrete network implementation pointing directly to your Firebase Firestore cloud instance.
final class FirestoreRemoteDataSource: PropertyRemoteDataSourceProtocol {
    
    /// Fetches live JSON/Documents from Firestore and decodes them into value-type Domain Models.
    func fetchRemoteProperties() async throws -> [Property] {
        /*
         TODO: Once the Firebase SDK Swift Package is fully initialized,
         this method will execute standard Firestore collection queries.
         
         For right now, we return an empty array to ensure the codebase compiles cleanly 
         as we build out the architecture layout.
         */
        return []
    }
}
