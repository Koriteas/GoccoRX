//
//  SearchResult.swift
//  Gocco
//
//  Created by Carlos Santana on 16/06/2019.
//  Copyright © 2019 Carlos Santana. All rights reserved.
//

import Foundation

struct SearchResult: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case items = "results"
        case filters
        case count = "resultsCount"
    }
    
    let items: [Item]
    let filters: [FilterGeneric]
    let count: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decode([Item].self, forKey: .items)
        count = try container.decode(Int.self, forKey: .count)
        
        var filterTypes = try container.nestedUnkeyedContainer(forKey: .filters)
        var filters = [FilterGeneric]()
        
        var auxFilters = filterTypes
        while !filterTypes.isAtEnd {
            let filter = try filterTypes.nestedContainer(keyedBy: Filter.CodingKeys.self)
            let filterType = try filter.decode(FilterType.self, forKey: Filter.CodingKeys.type)
            
            switch filterType {
            case .text, .image:
                filters.append(try auxFilters.decode(OptionFilter.self))
                
            case .range:
                filters.append(try auxFilters.decode(RangePriceFilter.self))

            }
        }
        
        self.filters = filters
    }
}
