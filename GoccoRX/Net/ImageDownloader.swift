//
//  ImageDownloader.swift
//  Gocco
//
//  Created by Carlos Santana on 13/06/2019.
//  Copyright © 2019 Carlos Santana. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire
import AlamofireImage

class ImageConnector {

    static let shared = ImageConnector()

    private let cacheImage = ImageDownloader()
    
    func getImage(by url: String, filter: ImageFilter? = nil) -> Single<UIImage> {
        guard let url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
            let completeURL = try? url.asURL() else {
                return Single.create { single in single(.error(RequestError.unknown)); return Disposables.create() }
        }

        return getImage(by: completeURL, filter: filter)
    }
    
    func getImage(by url: URL, filter: ImageFilter? = nil) -> Single<UIImage> {
        return Single.create { [weak self] single in
            guard let self = self else { single(.error(RequestError.unknown)); return Disposables.create() }
            
            // HACK: Generate random image
            let hackURL = URL(string: "https://picsum.photos/1000?\(UUID().description)")!
            
            let request = self.cacheImage.download(URLRequest(url: hackURL), filter: filter) { response in
                switch response.result {
                case .success(let image):
                    single(.success(image))
                    
                case .failure(let error):
                    single(.error(RequestError.request(code: response.response?.statusCode ?? 400 , error: error)))
                    
                }
            }
            
            return Disposables.create {
                guard let request = request else { return }
                self.cacheImage.cancelRequest(with: request)
            }
        }
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
}
