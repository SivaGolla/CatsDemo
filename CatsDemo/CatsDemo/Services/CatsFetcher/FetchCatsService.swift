//
//  FetchCatsService.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 20/06/24.
//

import Foundation

/// Service Request to fetch Cats
class FetchCatsService: ServiceProviding {
    var urlSearchParams: ServiceRequestModel?
    
    /// Populates request based on query parameters
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
    
    /// Generic implementation of fetch Cats service
    func fetch<T>(completion: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
        
        guard let request = makeRequest() else {
            completion(.failure(.invalidUrl))
            return
        }
        
        NetworkManager(session: CatsDemoModel.activeSession).execute(request: request) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
