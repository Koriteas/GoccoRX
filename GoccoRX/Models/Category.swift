//
//  Category.swift
//  Gocco
//
//  Created by Carlos Santana on 11/06/2019.
//  Copyright © 2019 Carlos Santana. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Category: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id = "categoryId"
        case name = "label"
        case imageURL = "imageUrl"
        case subCategories = "children"
    }
    
    let id: Int
    let name: String
    let imageURL: URL?
    let image: BehaviorSubject<UIImage?>
    let subCategories: [Category]?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = Int(try container.decode(String.self, forKey: .id)) ?? 0
        name = try container.decode(String.self, forKey: .name)
        imageURL = try container.decodeIfPresent(URL.self, forKey: .imageURL)
        subCategories = try container.decodeIfPresent([Category].self, forKey: .subCategories)
        image = BehaviorSubject<UIImage?>(value: nil)
        
        loadImage()
    }
    
    func loadImage() {
        guard let imageURL = imageURL else { return }
        
        // Get image from server
        _ = ImageConnector.shared.getImage(by: imageURL)
            .asObservable()
            .catchErrorJustReturn(UIImage())
            .bind(to: image)
    }
}
