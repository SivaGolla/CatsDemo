//
//  CatsViewModel.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 20/06/24.
//

import Foundation

import UIKit

class CatsViewModel {
    
    var itemsDidChange: (() -> Void)?
    var failedToLoadItems: ((NetworkError) -> Void)?
    
    var catModels: [ACatViewModel] = [] {
        didSet {
            itemsDidChange?()
        }
    }
    
    private var ongoingTasks = [IndexPath: URLSessionDataTask]()
    
    func loadCatList() {
        // Load your initial data here
        let serviceRequest = FetchCatsService()
        let urlSearchParams = ServiceRequestModel(limit: nil, page: nil, favId: nil)
        
        serviceRequest.urlSearchParams = urlSearchParams
        
        let completion: (Result<[CatBreed], NetworkError>) -> Void = { [weak self] result in
            
            switch result {
            case .success(let catList):
                self?.catModels = catList.compactMap { ACatViewModel(model: $0) }
            case .failure(let error):
                print(error.localizedDescription)
                self?.failedToLoadItems?(error)
            }
        }
        
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
    
    func toggleFavorite(at indexPath: IndexPath) {
        catModels[indexPath.row].isFavorite.toggle()
    }
    
    func isFavorite(at indexPath: IndexPath) -> Bool {
        return catModels[indexPath.row].isFavorite
    }
}
