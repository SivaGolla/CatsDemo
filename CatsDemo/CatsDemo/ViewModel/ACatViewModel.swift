//
//  ACatViewModel.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 21/06/24.
//

import Foundation

final class ACatViewModel {
    
    var name: String {
        model.name
    }

    let model: CatBreed

    var imageURL: URL? {
        guard let imageID = model.referenceImageID else { return nil }
        return Self.imageURLCache.object(forKey: imageID as NSString) as URL?
    }

    private static let imageURLCache = NSCache<NSString, NSURL>()

    init(model: CatBreed) {
        self.model = model
    }
}
