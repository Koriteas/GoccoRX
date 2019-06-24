//
//  Router.swift
//  Gocco
//
//  Created by Carlos Santana on 13/06/2019.
//  Copyright © 2019 Carlos Santana. All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {

    case home(storeID: Int)
    case searchItems(storeID: Int, parameters: Parameters)
    
    static let baseURLString = "https://private-anon-465aa76908-gocco.apiary-mock.com"
    
    var method: HTTPMethod {
        switch self {
        default:
            return .get
            
        }
    }
    
    var path: String {
        switch self {
        case .home(let storeID):
            return "/stores/\(storeID)/home"
            
        case .searchItems(let storeID, _):
            return "/stores/\(storeID)/products/search"
    
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try Router.baseURLString.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .searchItems(_, let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
            
        default:
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
            
        }
        
        return urlRequest
    }
}
