//
//  PropertyListState.swift
//  PropFinder
//
//  Created by Muhammad Ammar on 19/06/2026.
//


import Foundation

/// Defines the clear structural states the List UI can be in at any single millisecond.
/// Senior Detail: Enums prevent "impossible states" (like showing an error and loading spinner simultaneously).
enum PropertyListState: Equatable {
    case idle
    case loading
    case success([Property])
    case empty
    case error(String)
}

final class PropertyListViewModel {
    
    // MARK: - Dependencies
    private let repository: PropertyRepositoryProtocol
    
    // MARK: - Binding Closures (The Interface)
    /// This closure is triggered whenever the UI state changes. The ViewController binds to this.
    var onStateChange: ((PropertyListState) -> Void)?
    
    /// Holds the current state of the engine. Every time this changes, it pushes updates to the listener.
    private(set) var state: PropertyListState = .idle {
        didSet {
            // Ensure UI updates always stream back on the Main queue
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.onStateChange?(self.state)
            }
        }
    }
    
    // MARK: - Initializer
    /// Injecting the protocol allows us to test this ViewModel effortlessly by providing a fake repository later.
    init(repository: PropertyRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Intentions / Actions
    
    /// Fetches listings from the repository pipeline.
    func loadProperties() {
        // 1. Check the current state using a clean switch statement
                switch state {
                case .idle, .error:
                    // If we are idle or previously failed, it's safe to show the loading spinner
                    state = .loading
                default:
                    // If we are already loading or already have data, do nothing to prevent redundant UI flashes
                    break
                }
        
        // Execute the asynchronous task using modern Swift concurrency
        Task {
            do {
                let items = try await repository.getProperties()
                
                if items.isEmpty {
                    self.state = .empty
                } else {
                    self.state = .success(items)
                }
            } catch {
                self.state = .error(error.localizedDescription)
            }
        }
    }
}
