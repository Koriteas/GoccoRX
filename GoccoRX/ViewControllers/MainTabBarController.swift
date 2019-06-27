//
//  MainTabBarController.swift
//  GoccoRX
//
//  Created by Carlos Santana on 24/06/2019.
//  Copyright © 2019 Carlos Santana. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        let homeController = CategoryTableViewController(reactor: CategoryCollectionReactor(title: "Gocco".localized, categories: nil), isHome: true)
        homeController.tabBarItem = UITabBarItem(title: "Gocco", image: #imageLiteral(resourceName: "home"), tag: 0)
        
        let searchController = SearchCollectionViewController(reactor: SearchCollectionReactor(parent: nil))
        searchController.tabBarItem = UITabBarItem(title: "Search", image: #imageLiteral(resourceName: "search"), tag: 0)
        
        viewControllers = [homeController, searchController].map { UINavigationController(rootViewController: $0) }
        selectedIndex = 0
    }
}
