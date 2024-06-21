//
//  FetchCatsRequest.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 20/06/24.
//

import Foundation

/// Service Request to fetch Astronomy Picture of the day service
class FetchCatsRequest: ServiceProviding {
    var urlSearchParams: ServiceRequestModel?
    
    var activeSession: URLSession = {
        let config:URLSessionConfiguration = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }()
    
    /// Populates request based on query parameters
    /// Also saves a formatted request into ApodDataStorage
    /// - Returns: Request
    func makeRequest() -> Request? {
        
        guard var urlComponents = URLComponents(string: Environment.catBreedList) else {
            return nil
        }

        var queryParams: [URLQueryItem] = []
        if let requestParams = urlSearchParams {
            if let limit = requestParams.limit {
                queryParams.append(URLQueryItem(name: "limit", value: "\(limit)"))
            }
            
            if let page = requestParams.page {
                queryParams.append(URLQueryItem(name: "page", value: "\(page)"))
            }
        }
        
        queryParams.append(URLQueryItem(name: "api_key", value: Environment.current.apiKey))
        urlComponents.queryItems = queryParams

        guard let urlPath = urlComponents.url?.absoluteString else {
            return nil
        }
        
        let request = Request(path: urlPath, method: .get, contentType: "application/json", headerParams: nil, type: .cats, body: nil)
        return request
    }
    
    /// Generic implementation of fetch APOD service
    func fetch<T>(completion: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
        
        guard let request = makeRequest() else {
            completion(.failure(.invalidUrl))
            return
        }
        
        NetworkManager(session: activeSession).execute(request: request) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
}
