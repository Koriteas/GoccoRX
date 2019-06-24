//
//  Filter.swift
//  Gocco
//
//  Created by Carlos Santana on 16/06/2019.
//  Copyright © 2019 Carlos Santana. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum FilterType: String, Codable {
    
    case text = "text"
    case image = "image"
    case range = "range"
}

protocol FilterGeneric: Codable {

    var name: String { get }
    var type: FilterType { get }
    var reference: String { get }
}

class FilterOption: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "label"
        case imageURL = "imageUrl"
    }
    
    let id: Int
    let name: String
    let imageURL: URL?
    var image: BehaviorSubject<UIImage?>
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = Int(try container.decode(String.self, forKey: .id)) ?? 0
        name = try container.decode(String.self, forKey: .name)
        imageURL = try container.decodeIfPresent(URL.self, forKey: .imageURL)
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

class Filter: FilterGeneric {

    enum CodingKeys: String, CodingKey {
        case name = "label"
        case type
        case reference = "filterName"
    }
    
    let name: String
    let type: FilterType
    let reference: String
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(FilterType.self, forKey: .type)
        reference = try container.decode(String.self, forKey: .reference)
    }
}

class OptionFilter: Filter {
    
    enum OptionCodingKeys: String, CodingKey {
        case options
    }
    
    var options: [FilterOption]
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OptionCodingKeys.self)
        options = try container.decode([FilterOption].self, forKey: .options)
        
        try super.init(from: decoder)
    }
}

class RangePriceFilter: Filter {
    
    enum RangeCodingKeys: String, CodingKey {
        case min
        case max
        case currency
    }
    
    let minPrice: Money
    let maxPrice: Money
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RangeCodingKeys.self)
        let currency = try container.decode(Currency.self, forKey: .currency)
        let min = try container.decode(Double.self, forKey: .min)
        let max = try container.decode(Double.self, forKey: .max)
        
        minPrice = Money(amount: min, currency: currency)
        maxPrice = Money(amount: max, currency: currency)
        try super.init(from: decoder)
    }
}
