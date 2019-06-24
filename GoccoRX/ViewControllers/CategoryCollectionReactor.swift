//
//  CategoryCollectionReactor.swift
//  GoccoRX
//
//  Created by Carlos Santana on 24/06/2019.
//  Copyright © 2019 Carlos Santana. All rights reserved.
//

import Foundation
import RxSwift
import ReactorKit

class CategoryCollectionReactor: Reactor {

    enum Action {
        case loadCategories
    }
    
    enum Mutation {
        case setCategories([Category])
    }
    
    struct State {
        var title: String
        var categories: [Category]
        var isHome: Bool
    }

    let initialState: State
    let initialCategories: [Category]

    init(title: String, isHome: Bool = true, categories: [Category]?) {
        self.initialCategories = categories ?? []
        self.initialState = State(title: title,
                                  categories: categories ?? [],
                                  isHome: isHome)
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadCategories:
            return GoccoAPI.shared.getHomeCategories()
                    .asObservable()
                    .catchErrorJustReturn([])
                    .map(Mutation.setCategories)
            
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .setCategories(let categories):
            state.categories = categories

        }
        
        return state
    }
}
