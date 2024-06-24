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

/// CatFavouriteService manages favorite operations for cats. (fetch all favourites, mark a cat as favourite and remove a cat from their favourites
class CatFavouriteService: ServiceProviding {
    
    // MARK: properties
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
        
        let requestType: RequestType
        var requestBody: Data? = nil
        var httpMethod: RequestMethod = .get
        
        switch type {
        case .fetch:
            requestType = .getFavs      // Fetches all favorite cats for the user.
            
        case .update:                   // Marks a specific cat as favorite for the user.
            requestType = .favItems
            requestBody = try? JSONEncoder().encode(bodyParams)
            httpMethod = .post
        case .remove:                   // Removes a specific cat from the user's favorites.
            requestType = .unFavItem
            httpMethod = .del
            
            if let requestParams = urlSearchParams {
                if let favId = requestParams.favId {
                    urlPath.append("/\(favId)")
                }
            }
        }
        
        let headerParams = ["x-api-key": Environment.current.apiKey]
        
        let request = Request(path: urlPath, method: httpMethod, contentType: "application/json", headerParams: headerParams, type: requestType, body: requestBody)
        return request
    }
    
    /// Generic implementation of fetch Cats service
    func fetch<T>(completion: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
        
        guard let request = makeRequest() else {
            completion(.failure(.invalidUrl))
            return
        }
        
        NetworkManager(session: UserSession.activeSession).execute(request: request) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
