//
//  SearchCollectionReactor.swift
//  GoccoRX
//
//  Created by Carlos Santana on 25/06/2019.
//  Copyright © 2019 Carlos Santana. All rights reserved.
//

import Foundation
import RxSwift
import ReactorKit

enum SearchPage {
    case nextPage(Int)
    case limit
}

class SearchCollectionReactor: Reactor {
    
    enum Action {
        case search(String)
        case searchByCategory
        case loadNext
    }
    
    enum Mutation {
        case setQuery(String)
        case search(SearchResult)
        case reset
    }
    
    struct State {
        var initialCategory: Category?
        var query: String?
        var items: [Item]
        var filters: [FilterGeneric]
        var nextPage: SearchPage
        var hideSearchBar: Bool
    }
    
    let initialState: State
    
    init(parent category: Category?, hideSearchBar: Bool = false) {
        self.initialState = State(initialCategory: category,
                                  query: nil,
                                  items: [],
                                  filters: [],
                                  nextPage: .nextPage(1),
                                  hideSearchBar: hideSearchBar)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .search(let query):
            return GoccoAPI.shared.searchItems(by: query)
                    .asObservable()
                    .map { .search($0) }
                    .takeUntil(self.action)
                    .startWith(.reset)
                    .startWith(.setQuery(query))
            
        case .searchByCategory:
            guard let category = currentState.initialCategory else { return .empty() }

            return GoccoAPI.shared.searchItems(by: nil, categoryID: category.id)
                    .asObservable()
                    .map { .search($0) }
                    .takeUntil(self.action)

        case .loadNext:
            guard case .nextPage(let page) = currentState.nextPage, currentState.query?.isNotBlank ?? false || currentState.initialCategory != nil else { return .empty() }
            
            return GoccoAPI.shared.searchItems(by: currentState.query, categoryID: currentState.initialCategory?.id, page: page)
                    .asObservable()
                    .map { .search($0) }
                    .takeUntil(self.action)
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .setQuery(let query):
            state.query = query
            
        case .search(let result):
            state.items.append(contentsOf: result.items)
            state.filters = result.filters
            
            if case .nextPage(let page) = state.nextPage {
                state.nextPage = result.count < 10 ? .limit : .nextPage(page + 1)
            }
            
        case .reset:
            state.items = []
            state.filters = []
            state.nextPage = .nextPage(1)
            
        }
        
        return state
    }
}
