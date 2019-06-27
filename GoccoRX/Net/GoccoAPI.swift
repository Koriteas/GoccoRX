//
//  GoccoAPI.swift
//  Gocco
//
//  Created by Carlos Santana on 11/06/2019.
//  Copyright © 2019 Carlos Santana. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift

enum RequestError: Error {
    case request(code: Int, error: Error?)
    case unknown
}

class GoccoAPI {
    
    // HACK
    let storeID = 12
    
    static let shared = GoccoAPI()
    
    private let session: Session = {
        return Alamofire.Session.default
    }()
    
    private let retryHandler: (Observable<Error>) -> Observable<Int> = { e in
        return e.enumerated().flatMap { (attempt, error) -> Observable<Int> in
            guard attempt < 3 else { return Observable.error(error) }
            return Observable<Int>.timer(.milliseconds((attempt + 1) / 2), scheduler: MainScheduler.instance).take(1)
        }
    }
    
    func getHomeCategories() -> Single<[Category]> {
        Single.create { [weak self] single in
            guard let self = self else { single(.error(RequestError.unknown)); return Disposables.create() }
            
            let request = self.session
                .request(Router.home(storeID: self.storeID))
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let json):
                        guard let json = json as? [String: Any],
                            let categoriesJSON = json["categories"] else { single(.error(RequestError.unknown)); return }

                        do {
                            let decoder = JSONDecoder()
                            let data = try JSONSerialization.data(withJSONObject: categoriesJSON, options: JSONSerialization.WritingOptions.prettyPrinted)
                            let categories = try decoder.decode([Category].self, from: data)
                            single(.success(categories))
                        } catch {
                            single(.error(RequestError.unknown))
                        }
                       
                    case .failure(let error):
                        single(.error(RequestError.request(code: response.response?.statusCode ?? 400, error: error)))
                        
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .retryWhen(retryHandler)
    }
    
    func searchItems(by query: String? = nil, categoryID: Int? = nil, sort: String = "name", page: Int = 1) -> Single<SearchResult> {
        Single.create {  [weak self] single in
            guard let self = self else { single(.error(RequestError.unknown)); return Disposables.create() }
            
            var parameters: Parameters = [
                "order": sort,
                "page": page
            ]
            
            if let query = query {
                parameters["with_text"] = query
            }
            
            if let categoryID = categoryID {
                parameters["category_id"] = String(categoryID)
            }
            
            let request = self.session
                .request(Router.searchItems(storeID: self.storeID, parameters: parameters))
                .validate()
                .responseDecodable { (response: DataResponse<SearchResult>) in
                    switch response.result {
                    case .success(let search):
                        single(.success(search))

                    case .failure(let error):
                        single(.error(RequestError.request(code: response.response?.statusCode ?? 400, error: error)))

                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .retryWhen(retryHandler)
    }
}
