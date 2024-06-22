//
//  ACatViewModel.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 21/06/24.
//

import Foundation

final class ACatViewModel {
    
    let model: CatBreed

    var name: String {
        model.name
    }

    var isFavorite: Bool = false

    var modelDidChange: (() -> Void)?
    
    init(model: CatBreed) {
        self.model = model
    }
}
