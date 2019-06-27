//
//  CategoryTableViewController.swift
//  GoccoRX
//
//  Created by Carlos Santana on 24/06/2019.
//  Copyright © 2019 Carlos Santana. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class CategoryTableViewController: UITableViewController, View {
    
    var disposeBag = DisposeBag()
    
    init(reactor: CategoryCollectionReactor, isHome: Bool = false) {
        super.init(style: .plain)
        
        if isHome {
            tableView.register(CategoryHomeTableViewCell.self, forCellReuseIdentifier: "CategoryCell")
            tableView.separatorStyle = .none
        } else {
            tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        }
        
        tableView.tableFooterView = UIView()
        tableView.dataSource = nil
        
        navigationController?.navigationBar.prefersLargeTitles = isHome
        navigationItem.backBarButtonItem = UIBarButtonItem()

        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: CategoryCollectionReactor) {
        reactor.state
            .map { $0.title }
            .asDriver(onErrorJustReturn: "")
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)

        reactor.state
            .filter { $0.isHome }
            .map { $0.categories}
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: "CategoryCell", cellType: CategoryTableViewCell.self)) { _, category, cell in
                
                cell.titleLabel.text = category.name
                category.image
                    .do(onNext: { image in
                        cell.categoryImageView.isHidden = image == nil
                    })
                    .asDriver(onErrorJustReturn: nil)
                    .drive(cell.categoryImageView.rx.image)
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .filter { $0.isHome && $0.categories.isEmpty }
            .map { _ in Reactor.Action.loadCategories }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(Category.self)
            .subscribe(onNext: { [weak self] category in
                guard let self = self else { return }
                
                if let subCategories = category.subCategories, !subCategories.isEmpty {
                    let reactor = CategoryCollectionReactor(title: category.name, categories: subCategories)
                    let controller = CategoryTableViewController(reactor: reactor)
                    self.navigationController?.pushViewController(controller, animated: true)
                } else {
                    let reactor = SearchCollectionReactor(parent: category, hideSearchBar: true)
                    let controller = SearchCollectionViewController(reactor: reactor)
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension CategoryTableViewController {
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
