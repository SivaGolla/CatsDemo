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
    func makeRequest() -> Request {
        
        var reqUrlPath = Environment.catList
        
        if let requestParams = urlSearchParams {
            if let limit = requestParams.limit {
                reqUrlPath = reqUrlPath + "&limit=\(limit)"
            }
            
            if let breedName = requestParams.breedName {
                reqUrlPath = reqUrlPath + "&breed_ids=\(breedName)"
            }
        }
        
        let request = Request(path: reqUrlPath, method: .get, contentType: "application/json", headerParams: nil, type: .cats, body: nil)
        return request
    }
    
    /// Generic implementation of fetch APOD service
    func fetch<T>(completion: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
        
        let request = makeRequest()
        NetworkManager(session: activeSession).execute(request: request) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
}
