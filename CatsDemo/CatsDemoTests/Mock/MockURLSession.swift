//
//  MockURLSession.swift
//  CatsDemo-Dev
//
//  Created by Venkata Sivannarayana Golla on 24/06/24.
//

import Foundation
import UIKit

protocol MockURLSessionDelegate: AnyObject {
    func resourceName(for path: String, httpMethod: String) -> String
}

/// To create a mock URLSession that can be injected into the network layer for testing purposes, you can define a protocol that represents the network operations and provide the mock URLSession that loads data from a local JSON file.
class MockURLSession: URLSessionProtocol {
    
    weak var delegate: MockURLSessionDelegate? = nil

    var mockDataTask = MockURLSessionDataTask()
    var mockData: Data?
    var mockError: Error?
    var responseFileName: String = ""
    
    private (set) var lastURL: URL?
    
    func mockHttpURLResponse(request: URLRequest) -> URLResponse {
        return HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        lastURL = request.url
        
        let bundle = Bundle(for: NetworkManager.self)
        responseFileName = delegate?.resourceName(for: lastURL?.absoluteString ?? "", httpMethod: request.httpMethod ?? RequestMethod.get.rawValue) ?? ""
        guard let mockResponseFileUrl = bundle.url(forResource: responseFileName, withExtension: "json"),
              let data = try? Data(contentsOf: mockResponseFileUrl) else {
            completionHandler(nil, nil, mockError)
            return mockDataTask
        }
        mockData = data
        
        completionHandler(mockData, mockHttpURLResponse(request: request), mockError)
        return mockDataTask
    }

}

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    private (set) var resumeWasCalled = false
    
    func resume() {
        resumeWasCalled = true
    }
}
