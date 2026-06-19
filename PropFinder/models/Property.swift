//
//  Property.swift
//  PropFinder
//
//  Created by Muhammad Ammar on 18/06/2026.
//


import Foundation
// This uses pure value semantics (struct) to hold property listings securely without risk of unexpected reference mutations.
struct Property: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let price: Double
    let location: String
    let bedrooms: Int
    let bathrooms: Int
    let imageUrl: String
    let isFavorite: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case price
        case location
        case bedrooms
        case bathrooms
        case imageUrl = "image_url"
        case isFavorite = "is_favorite"
        case createdAt = "created_at"
    }
}
