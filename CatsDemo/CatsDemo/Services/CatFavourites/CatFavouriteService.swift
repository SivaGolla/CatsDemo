//
//  CatFavouriteService.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 22/06/24.
//

import Foundation

enum FavOpType {
    case fetch
    case update
    case remove
}

class CatFavouriteService: ServiceProviding {
    var urlSearchParams: ServiceRequestModel?
    var bodyParams: CatFavRequestModel?

    let type: FavOpType
    
    init(urlSearchParams: ServiceRequestModel? = nil, type: FavOpType) {
        self.urlSearchParams = urlSearchParams
        self.type = type
    }
    
    /// Populates request based on query parameters
    /// - Returns: Request
    func makeRequest() -> Request? {
        
        var urlPath = Environment.favouriteCats
//        guard var urlComponents = URLComponents(string: Environment.favouriteCats) else {
//            return nil
//        }

//        var queryParams: [URLQueryItem] = []
        
        let requestType: RequestType
        var requestBody: Data? = nil
        var httpMethod: RequestMethod = .get
        
        switch type {
        case .fetch:
            requestType = .getFavs
        case .update:
            requestType = .favItems
            requestBody = try? JSONEncoder().encode(bodyParams)
            httpMethod = .post
        case .remove:
            requestType = .unFavItem
            httpMethod = .del
            
            if let requestParams = urlSearchParams {
                if let favId = requestParams.favId {
                    urlPath.append("/\(favId)")
//                    queryParams.append(URLQueryItem(name: "favourite_id", value: favId))
                }
            }
        }
        
        let headerParams = ["x-api-key": Environment.current.apiKey]
        
//        urlComponents.queryItems = queryParams
//        guard let urlPath = urlComponents.url?.absoluteString else {
//            return nil
//        }
        
        let request = Request(path: urlPath, method: httpMethod, contentType: "application/json", headerParams: headerParams, type: requestType, body: requestBody)
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
