//
//  CatFavResponse.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 22/06/24.
//

import Foundation

struct CatFavResponse: Decodable {
    let message: String
    let id: Int?
}
