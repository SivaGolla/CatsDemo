//
//  NetworkError.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 20/06/24.
//

import Foundation

enum NetworkError: Error {
    case urlError
    case badRequest
    case internalServerError
    case requestTimedOut
    case parsingError
    case imageCreationError
    case noData
}
