//
//  UserSession.swift
//  CatsDemo-Dev
//
//  Created by Venkata Sivannarayana Golla on 24/06/24.
//

import Foundation
import UIKit

class UserSession {
    static var imageCache = NSCache<NSString, UIImage>()
    
    static var activeSession: URLSessionProtocol = MockURLSession()
}
