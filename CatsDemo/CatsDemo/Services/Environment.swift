//
//  Environment.swift
//  CatsDemo
//
//  Created by Venkata Sivannarayana Golla on 20/06/24.
//

import Foundation

/// Supported Application Environments
enum Environment {
    case dev, uat, prod
}

extension Environment {
    
    /// Points to current environment based on running target
    static var current: Environment {
        let targetName = Bundle.main.infoDictionary?["TargetName"] as? String

        switch targetName {
        case "CatsDemo":
            return Environment.prod
        case "CatsDemo-Uat":
            return Environment.uat
        default:
            return Environment.dev
        }
    }
    
    /// end point base url
    var baseUrlPath: String {
        switch self {
        case .prod:
            return "https://api.thecatapi.com/v1/images/search?"
        default:
            return "https://api.thecatapi.com/v1/images/search?"
        }
    }
    
    /// api key
    var apiKey: String {
        switch self {
        case .prod:
            return "live_FnELHMSHJG1IndcB0GUbULoJvTondVDgic1SmNhbFDUjIeXEKMTcrWKRtdVRVJAo"
        default:
            return "live_FnELHMSHJG1IndcB0GUbULoJvTondVDgic1SmNhbFDUjIeXEKMTcrWKRtdVRVJAo"
            
        }
    }
}


// MARK: All Service Endpoints
extension Environment {
    
    /// Cat List end point
    /// Ex: https://api.thecatapi.com/v1/images/search?api_key=live_FnELHMSHJG1IndcB0GUbULoJvTondVDgic1SmNhbFDUjIeXEKMTcrWKRtdVRVJAo
    static let catList = Environment.current.baseUrlPath + "api_key=\(Environment.current.apiKey)"
}