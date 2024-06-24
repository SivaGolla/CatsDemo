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
    
    private(set) var catModels: [ACatViewModel] = []
    private(set) var favCats: [FavoriteCat] = []
    
    var fetchCatsServiceRequest = FetchCatsService()
    var fetchFavsServiceRequest = CatFavouriteService(type: .fetch)

    private var ongoingTasks = [IndexPath: URLSessionDataTask]()
    
    var group: DispatchGroup = DispatchGroup()
    private let concurrentQueue = DispatchQueue(label: "com.personal.catsQ", attributes: .concurrent)

    func fetchAllCatsWithFavs() {
        
        concurrentQueue.async(group: group) { [weak self] in
            self?.group.enter()
            self?.loadCatList()
            
            self?.group.enter()
            self?.loadFavoriteCats()
        }
        
        group.notify(queue: .main) {
            
            if self.catModels.isEmpty {
                self.serviceDidFailed?(.noData)
                return
            }
            
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
        let urlSearchParams = ServiceRequestModel(limit: nil, page: nil, favId: nil)
        fetchCatsServiceRequest.urlSearchParams = urlSearchParams
        
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
        
        fetchCatsServiceRequest.fetch(completion: completion)
    }
    
    func loadFavoriteCats() {
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
        
        fetchFavsServiceRequest.fetch(completion: completion)
    }
    
    func image(at indexPath: IndexPath, completion: @escaping (UIImage?) -> Void) {
        guard let imageUrlString = catModels[indexPath.row].model.image?.url else {
            completion(Constants.placeholderImage)
            return
        }
        
        // Check cache first
        if let cachedImage = UserSession.imageCache.object(forKey: imageUrlString as NSString) {
            completion(cachedImage)
            return
        }
        
        // Download image if not cached
        guard let imageUrl = URL(string: imageUrlString) else {
            completion(Constants.placeholderImage)
            return
        }
        
        let task = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(Constants.placeholderImage)
                return
            }
            
            // Cache the downloaded image
            UserSession.imageCache.setObject(image, forKey: imageUrlString as NSString)
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
    
    func toggleFavourite(favID: String?, catBreed: CatBreed, type: FavOpType) {
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
}
