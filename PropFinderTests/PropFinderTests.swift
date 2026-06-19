//
//  PropFinderTests.swift
//  PropFinderTests
//
//  Created by Muhammad Ammar on 18/06/2026.
//

import Testing
@testable import PropFinder
import XCTest

final class PropFinderTests: XCTestCase {
    
    private var sut: PropertyListViewModel! // System Under Test
    private var mockRepository: MockPropertyRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockPropertyRepository()
        sut = PropertyListViewModel(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Test Assertions
    
    func test_loadProperties_emitsSuccessState_whenRepositorySucceeds() {
        // Arrange (Given)
        let expectedProperty = Property(id: "101", title: "Test Villa", price: 500000, location: "Marina", bedrooms: 2, bathrooms: 2, imageUrl: "", isFavorite: false, createdAt: Date())
        mockRepository.mockPropertiesToReturn = [expectedProperty]
        
        let expectation = self.expectation(description: "State changes to success")
        
        // Act (When)
        sut.onStateChange = { state in
            if case .success(let properties) = state {
                // Assert (Then)
                XCTAssertEqual(properties.count, 1)
                XCTAssertEqual(properties.first?.title, "Test Villa")
                expectation.fulfill()
            }
        }
        
        sut.loadProperties()
        
        // Assert pipeline safety timeout window
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertTrue(mockRepository.loadPropertiesCalled)
    }
    
    func test_loadProperties_emitsErrorState_whenRepositoryFails() {
        // Arrange (Given)
        mockRepository.shouldReturnError = true
        let expectation = self.expectation(description: "State changes to error")
        
        // Act (When)
        sut.onStateChange = { state in
            if case .error(let errorMessage) = state {
                // Assert (Then)
                XCTAssertEqual(errorMessage, "Network layer timeout simulation")
                expectation.fulfill()
            }
        }
        
        sut.loadProperties()
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
