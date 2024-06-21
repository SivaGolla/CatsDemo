//
//  Constants.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 21/06/24.
//

import Foundation

enum Constants {
    
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
