//
//  UserSession.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 21/06/24.
//

import Foundation
import UIKit

class UserSession {
    static var imageCache = NSCache<NSString, UIImage>()
    
    static var activeSession: URLSession = {
        let config:URLSessionConfiguration = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }()
}
