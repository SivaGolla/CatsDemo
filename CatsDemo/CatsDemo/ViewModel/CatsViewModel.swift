//
//  CatsViewModel.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 20/06/24.
//

import Foundation

import UIKit

class CatsViewModel {
    
    var catModels: [ACatViewModel] = []
    private var ongoingTasks = [IndexPath: URLSessionDataTask]()
    
    func loadCatList(completion: @escaping (Result<[CatBreed], NetworkError>) -> Void) {
        // Load your initial data here
        let serviceRequest = FetchCatsRequest()
        let urlSearchParams = ServiceRequestModel(limit: nil, page: nil)
        
        serviceRequest.urlSearchParams = urlSearchParams
        serviceRequest.fetch(completion: completion)
    }
    
    func image(at indexPath: IndexPath, completion: @escaping (UIImage?) -> Void) {
        guard let imageUrlString = catModels[indexPath.row].model.image?.url else {
            completion(nil)
            return
        }
        
        // Check cache first
        if let cachedImage = CatsDemoModel.imageCache.object(forKey: imageUrlString as NSString) {
            completion(cachedImage)
            return
        }
        
        // Download image if not cached
        guard let imageUrl = URL(string: imageUrlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            // Cache the downloaded image
            CatsDemoModel.imageCache.setObject(image, forKey: imageUrlString as NSString)
            self.ongoingTasks[indexPath] = nil
            
            // Return the downloaded image
            completion(image)
        }
        task.resume()
        ongoingTasks[indexPath] = task
    }
    
    func cancelImageLoad(at indexPath: IndexPath) {
        if let task = ongoingTasks[indexPath] {
            task.cancel()
            ongoingTasks[indexPath] = nil
        }
    }
}
