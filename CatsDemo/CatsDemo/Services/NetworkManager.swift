//
//  NetworkManager.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 20/06/24.
//

import Foundation

/// Handles various network requests of type Request
class NetworkManager: NSObject {
    
    private let activeSession: URLSessionProtocol
    
    init(session: URLSessionProtocol) {
        activeSession = session
    }
    
    /// To execute a Request object which was created earlier.
    /// - Parameters:
    ///   - request: Request
    ///   - completion: completion with Result (<T, NetworkError>) of the operation
    @discardableResult
    func execute<T: Decodable>(request: Request, completion: @escaping (Result<T, NetworkError>) -> Void) -> URLSessionDataTaskProtocol? {
        
        guard let path = request.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: path) else {
            completion(.failure(.invalidUrl))
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.addValue(request.contentType, forHTTPHeaderField: "Content-Type")
        
        if let headerParams = request.headerParams {
            for (key, value) in headerParams {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if request.method == .post, let body = request.body {
            urlRequest.httpBody = body
        }
                
        let task = activeSession.dataTask(with: urlRequest, completionHandler: { data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.badRequest))
                return
            }
                        
            switch httpResponse.statusCode {
            case 200...300:
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(result))
                } catch let error as NSError {
                    print(error.debugDescription)
                    completion(.failure(.parsingError))
                }
                
            case 500...599:
                completion(.failure(.internalServerError))
            default:
                completion(.failure(.badRequest))
            }
        })
        task.resume()
        return task
    }
}
    
extension NetworkManager : URLSessionDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        /* this application does not use a NSURLCache disk or memory cache */
        completionHandler(nil)
    }
}
