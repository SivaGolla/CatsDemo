//
//  FetchAllFavCatsResponse.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 22/06/24.
//

import Foundation

// MARK: - FetchAllFavCatsResponse
struct FavoriteCat: Codable {
    let id: Int
    let userID, imageID: String
    let subID: String?
    let createdAt: String
    let image: FavCatImage
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case imageID = "image_id"
        case subID = "sub_id"
        case createdAt = "created_at"
        case image
    }
}

// MARK: - Image
struct FavCatImage: Codable {
    let url: String
    let id: String
}
