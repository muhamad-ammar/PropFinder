//
//  MockPropertyRepository.swift
//  PropFinder
//
//  Created by Muhammad Ammar on 19/06/2026.
//


import XCTest
@testable import PropFinder // Injects internal app modules into test visibility scope

/// A programmatic Spy/Mock representing our data abstraction boundaries.
final class MockPropertyRepository: PropertyRepositoryProtocol {
    
    var shouldReturnError = false
    var mockPropertiesToReturn: [PropFinder.Property] = []
    
    // Call track flags to verify state expectations
    var loadPropertiesCalled = false
    
    // Matching your exact production signature:
    func getProperties() async throws -> [PropFinder.Property] {
        loadPropertiesCalled = true
        
        if shouldReturnError {
            throw NSError(
                domain: "MockError",
                code: 500,
                userInfo: [NSLocalizedDescriptionKey: "Network layer timeout simulation"]
            )
        }
        
        return mockPropertiesToReturn
    }
}
