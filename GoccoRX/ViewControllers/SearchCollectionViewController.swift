//
//  SearchCollectionViewController.swift
//  GoccoRX
//
//  Created by Carlos Santana on 25/06/2019.
//  Copyright © 2019 Carlos Santana. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class SearchCollectionViewController: UICollectionViewController, View {
    
    var disposeBag = DisposeBag()
    
    lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.placeholder = "Search products".localized
        return search
    }()
    
    lazy var headerView = SearchHeaderStackView()
    
    init(reactor: SearchCollectionReactor) {
        super.init(collectionViewLayout: SearchCollectionViewFlowLayout())
        
        navigationItem.title = "Search".localized
        
        collectionView?.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "ItemCell")
        collectionView?.backgroundColor = .white
        collectionView?.dataSource = nil
        collectionView?.delegate = self
        collectionView?.addSubview(headerView)
        headerView.widthAnchor.constraint(equalTo: collectionView.widthAnchor).isActive = true
        self.reactor = reactor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: SearchCollectionReactor) {
        reactor.state
            .filter { $0.initialCategory != nil }
            .map { $0.initialCategory?.name }
            .asDriver(onErrorJustReturn: nil)
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        reactor.state
            .filter { !$0.hideSearchBar }
            .map { $0.hideSearchBar }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigationItem.searchController = self.searchController
                self.navigationItem.hidesSearchBarWhenScrolling = false
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.items }
            .asDriver(onErrorJustReturn: [])
            .drive(collectionView.rx.items(cellIdentifier: "ItemCell", cellType: SearchCollectionViewCell.self)) { _, item, cell in
                cell.itemNameLabel.text = item.name
                cell.itemPriceLabel.text = item.price.price.description
                
                item.images
                    .filter { $0 != nil }
                    .map { $0?.first }
                    .bind(to: cell.itemImageView.rx.image)
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .filter { $0.initialCategory != nil }
            .take(1)
            .map { _ in Reactor.Action.searchByCategory }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.text.orEmpty
            .throttle(.milliseconds(3), scheduler: MainScheduler.instance)
            .filter { $0.count > 2 }
            .map(Reactor.Action.search)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        collectionView.rx.contentOffset
            .observeOn(MainScheduler.instance)
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.collectionView.isNearBottomEdge()
            }
            .map { _ in Reactor.Action.loadNext }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

class SearchCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override init() {
        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        scrollDirection = .vertical
        sectionInset = .zero
        minimumLineSpacing = .leastNonzeroMagnitude
        minimumInteritemSpacing = .leastNonzeroMagnitude
        scrollDirection = .vertical
        estimatedItemSize = CGSize(width: UIScreen.main.bounds.width / 2, height: 300)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        return attributes.map { element in
            let elementCopy = element.copy() as! UICollectionViewLayoutAttributes
            
            if elementCopy.representedElementCategory == .cell {
                elementCopy.frame.size.width = UIScreen.main.bounds.width / 2
                
                if let siblingElement = attributes.filter({ ceil($0.frame.midY) == ceil(elementCopy.frame.midY) && $0 != elementCopy }).first {
                    elementCopy.frame.origin.y = min(elementCopy.frame.origin.y, siblingElement.frame.origin.y)
                    elementCopy.frame.size.height = max(elementCopy.frame.size.height, siblingElement.frame.size.height)
                }
            }
            
            return elementCopy
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
       return collectionView?.bounds.size != .some(newBounds.size)
    }
}

class SearchHeaderStackView: UIStackView {
    
    lazy var filterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Filters", comment: ""), for: .normal)
        button.setImage(#imageLiteral(resourceName: "filter"), for: .normal)
        button.contentEdgeInsets.left = 15
        button.titleEdgeInsets.left = 10
        button.titleEdgeInsets.right = -10
        button.contentHorizontalAlignment = .left
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        return button
    }()
    
    lazy var sortButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Sort by", comment: ""), for: .normal)
        button.setImage(#imageLiteral(resourceName: "sortBy"), for: .normal)
        button.contentEdgeInsets.right = 15
        button.imageEdgeInsets.left = -10
        button.imageEdgeInsets.right = 10
        button.contentHorizontalAlignment = .right
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }

    func setup() {
        axis = .horizontal
        alignment = .fill
        distribution = .equalSpacing
        spacing = 10
        translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(filterButton)
        divider()
        addArrangedSubview(sortButton)
        
        let line = UIView(frame: CGRect(x: 0.0, y: bounds.height, width: bounds.width, height: 0.5))
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = .lightGray
        addSubview(line)
        
        let views = ["line": line]
        let metrics = ["height": 0.5]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[line]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[line(==height)]|", options: [], metrics: metrics, views: views))
    }
}
