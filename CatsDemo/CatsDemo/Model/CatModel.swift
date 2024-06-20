//
//  CatModel.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 20/06/24.
//

import Foundation

struct CatModel: Decodable, Identifiable {
    let id: String
    let url: String
    let width, height: Int
}
