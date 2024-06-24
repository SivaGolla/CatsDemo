//
//  NetworkProviding.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 24/06/24.
//

import Foundation

// MARK: Dependency Injection protocols for Networking
protocol URLSessionProtocol {
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        let dataTask = dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
        return dataTask
    }
}

protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}
