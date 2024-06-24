//
//  Constants.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 21/06/24.
//

import Foundation
import UIKit

enum Constants {
    
    static let favImage = UIImage(systemName: "heart.fill")!.withTintColor(.red, renderingMode: .automatic)
    static let unFavImage = UIImage(systemName: "heart")!.withTintColor(.red, renderingMode: .automatic)
    static let placeholderImage = UIImage(named: "placeholderCat")
    static let wikiHeader = "Wikipedia link: "
    
    static func emojiFlag(from countryCode: String) -> String {
        let base: UInt32 = 127397
        var result = ""
        
        result.unicodeScalars += countryCode
            .uppercased()
            .unicodeScalars
            .compactMap { UnicodeScalar(base + $0.value) }
        return result
    }
}
