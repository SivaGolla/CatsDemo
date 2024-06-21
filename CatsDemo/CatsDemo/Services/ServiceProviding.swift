//
//  ServiceProviding.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 20/06/24.
//

import Foundation

/// Declares common behaviour of every service
protocol ServiceProviding {
    var urlSearchParams: ServiceRequestModel? { get set }
    func makeRequest() -> Request?
    func fetch<T>(completion: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable
}
