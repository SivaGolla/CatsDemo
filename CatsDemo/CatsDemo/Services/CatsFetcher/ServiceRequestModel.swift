//
//  ServiceRequestModel.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 20/06/24.
//

import Foundation

struct ServiceRequestModel {
    let limit: Int?
    let page: Int?
    let favId: String?
}

struct CatFavRequestModel: Encodable {
    let imageId: String
    let subId: String
    
    enum CodingKeys: String, CodingKey {
        case imageId = "image_id"
        case subId = "sub_id"
    }
}
