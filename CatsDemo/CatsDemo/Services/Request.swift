//
//  Request.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 20/06/24.
//

import Foundation

/// Http Request method types
enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case del = "DELETE"
}

/// Defines supported request types
/// Add more cases as required
enum RequestType {
    case cats
    case getFavs
    case favItems
    case unFavItem
}

/// Requesting protocol
protocol Requesting {
    var path: String { get set }
    var method: RequestMethod { get set }
    var contentType: String { get set }
    var headerParams: [String: String]? { get set }
    var type: RequestType { get set }
    var body: Data? { get set }
}

/// Base Request
struct Request: Requesting  {
    var path: String
    var method: RequestMethod
    var contentType: String
    var headerParams: [String: String]?
    var type: RequestType
    var body: Data?
}
