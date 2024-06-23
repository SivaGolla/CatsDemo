//
//  ACatDetailViewModel.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 21/06/24.
//

import Foundation
import UIKit

final class ACatDetailViewModel {
    private var ongoingTask: URLSessionDataTask?
    
    var titleText: String {
        model.name
    }

    var fullText: String {
        originText + "\n\n" +
        (model.description ?? "") + "\n\n" +
        temperamentText
    }

    var linkText: String {
        guard let wikipediaLink = model.wikipediaURL, !wikipediaLink.isEmpty else {
            return "No Wikipedia link available."
        }

        return String(format: "Wikipedia link: %@", wikipediaLink)
    }

    private var originText: String {
        guard let countryCode = model.countryCode, countryCode.isEmpty == false else {
            return "Unknown origin"
        }

        return String(format: "Country of origin: %@", Constants.emojiFlag(from: countryCode))
    }

    private var temperamentText: String {
        String(format: "Temperament: %@", model.temperament ?? "")
    }

    private let model: CatBreed

    init(model: CatBreed) {
        self.model = model
    }

    func wikilinkTapped() {
        guard let url = URL(string: model.wikipediaURL ?? ""),
              UIApplication.shared.canOpenURL(url) else {
            return
        }

        UIApplication.shared.open(url)
    }
    
    func loadRemoteImage(completion: @escaping (UIImage?) -> Void) {
        guard let imageUrlString = model.image?.url else {
            completion(nil)
            return
        }
        
        // Check cache first
        if let cachedImage = UserSession.imageCache.object(forKey: imageUrlString as NSString) {
            completion(cachedImage)
            return
        }
        
        // Download image if not cached
        guard let imageUrl = URL(string: imageUrlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            // Cache the downloaded image
            UserSession.imageCache.setObject(image, forKey: imageUrlString as NSString)
            self?.ongoingTask = nil
            
            // Return the downloaded image
            completion(image)
        }
        task.resume()
        ongoingTask = task
    }
}
