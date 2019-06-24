//
//  Item.swift
//  Gocco
//
//  Created by Carlos Santana on 16/06/2019.
//  Copyright © 2019 Carlos Santana. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct ItemSize: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id = "variantId"
        case name
        case stock = "stockQty"
    }
    
    let id: Int
    let name: String
    let stock: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = Int(try container.decode(String.self, forKey: .id)) ?? 0
        name = try container.decode(String.self, forKey: .name)
        stock = try container.decode(Int.self, forKey: .stock)
    }
}

struct ItemPrice {
    
    enum ItemPriceType: String, Codable {
        case original = "ORIGINAL"
        case final = "FINAL"
    }

    let priceType: ItemPriceType
    let price: Money
    let originalPrice: Money
}

class Item: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id = "modelId"
        case name
        case type
        case sku
        case description
        case url
        case color
        case composition
        case care
        case originalPrice
        case finalPrice
        case finalPriceType
        case currency
        case images
        case sizes
    }
    
    let id: Int
    let name: String
    let description: String
    let type: String
    let sku: String
    let price: ItemPrice
    let color: String?
    let url: URL?
    let composition: String?
    let care: URL?
    let imageURLs: [URL]?
    let images: BehaviorSubject<[UIImage]?>
    let sizes: [ItemSize]?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = Int(try container.decode(String.self, forKey: .id)) ?? 0
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        type = try container.decode(String.self, forKey: .type)
        sku = try container.decode(String.self, forKey: .sku)
        color = try container.decode(String.self, forKey: .color)
        composition = try container.decode(String.self, forKey: .composition)
        url = try container.decodeIfPresent(URL.self, forKey: .url)
        care = try container.decodeIfPresent(URL.self, forKey: .care)
        imageURLs = try container.decodeIfPresent([URL].self, forKey: .images)
        sizes = try container.decodeIfPresent([ItemSize].self, forKey: .sizes)
        images = BehaviorSubject(value: nil)
        
        // Price decode
        let priceType = try container.decode(ItemPrice.ItemPriceType.self, forKey: .finalPriceType)
        let currency = try container.decode(Currency.self, forKey: .currency)
        let finalPrice = try container.decode(Double.self, forKey: .finalPrice)
        let originalPrice = try container.decode(Double.self, forKey: .originalPrice)
        price = ItemPrice(priceType: priceType,
                          price: Money(amount: finalPrice * 0.01, currency: currency),
                          originalPrice: Money(amount: originalPrice * 0.01, currency: currency))
        
        loadImages()
    }
    
    func loadImages() {
        guard let imageURLs = imageURLs else { return }
        
        let imagesObservable = imageURLs.map { ImageConnector.shared.getImage(by: $0).asObservable().catchErrorJustReturn(UIImage()) }
        
        _ = Observable.zip(imagesObservable).bind(to: images)
    }
}
