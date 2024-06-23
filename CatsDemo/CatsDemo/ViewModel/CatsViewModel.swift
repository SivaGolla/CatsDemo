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
    var serviceDidFailed: ((NetworkError) -> Void)?
    
    var catModels: [ACatViewModel] = []
    var favCats: [FavoriteCat] = []
    
    private var ongoingTasks = [IndexPath: URLSessionDataTask]()
    private var group: DispatchGroup = DispatchGroup()
    private let concurrentQueue = DispatchQueue(label: "com.personal.catsQ", attributes: .concurrent)

    func fetchAllCatsWithFavs() {
        
//        concurrentQueue.async {
            self.loadCatList()
            self.loadFavoriteCats()
//        }
        
        group.notify(queue: .main) {
            if self.favCats.isEmpty {
                self.itemsDidChange?()
                return
            }
            
            self.catModels.indices.forEach { index in
                let favItem = self.favCats.first { self.catModels[index].model.referenceImageID == $0.imageID }
                if let favItem = favItem {
                    self.catModels[index].isFavorite = true
                    self.catModels[index].favID = favItem.id
                }
            }
            
            self.itemsDidChange?()
        }
    }
    
    func loadCatList() {
        // Load your initial data here
        group.enter()
        let serviceRequest = FetchCatsService()
        let urlSearchParams = ServiceRequestModel(limit: nil, page: nil, favId: nil)
        
        serviceRequest.urlSearchParams = urlSearchParams
        
        let completion: (Result<[CatBreed], NetworkError>) -> Void = { [weak self] result in
            
            switch result {
            case .success(let catList):
                self?.catModels = catList.compactMap { ACatViewModel(model: $0) }
            case .failure(let error):
                print(error.localizedDescription)
                self?.serviceDidFailed?(error)
            }
            self?.group.leave()
        }
        
        serviceRequest.fetch(completion: completion)
    }
    
    func loadFavoriteCats() {
        group.enter()
        let serviceRequest = CatFavouriteService(type: .fetch)
        let completion: (Result<[FavoriteCat], NetworkError>) -> Void = { [weak self] result in
            
            switch result {
            case .success(let favCatList):
                self?.favCats = favCatList
            case .failure(let error):
                print(error.localizedDescription)
                self?.serviceDidFailed?(error)
            }
            
            self?.group.leave()
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
    
    func toggleFavorite(favID: String?, catBreed: CatBreed, type: FavOpType) {
        guard let favID = favID,
              !favID.isEmpty,
              let imageID = catBreed.referenceImageID,
              !imageID.isEmpty else {
                  
            return
        }
        
        let serviceRequest = CatFavouriteService(type: type)
        serviceRequest.urlSearchParams = ServiceRequestModel(limit: nil, page: nil, favId: favID)
        serviceRequest.bodyParams = CatFavRequestModel(imageId: imageID)
        
        let completion: (Result<CatFavResponse, NetworkError>) -> Void = { [weak self] result in
            
            switch result {
            case .success(let response):
                self?.catModels.first { catBreed.id == $0.model.id }?.isFavorite.toggle()
                self?.catModels.first { catBreed.id == $0.model.id }?.favID = response.id ?? 0
                self?.itemsDidChange?()
                
            case .failure(let error):
                print(error.localizedDescription)
                self?.serviceDidFailed?(error)
            }
        }
        
        serviceRequest.fetch(completion: completion)
    }
    
    func isFavorite(at indexPath: IndexPath) -> Bool {
        return catModels[indexPath.row].isFavorite
    }
}
