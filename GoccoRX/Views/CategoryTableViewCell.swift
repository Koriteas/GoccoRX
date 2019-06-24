//
//  CategoryTableViewCell.swift
//  GoccoRX
//
//  Created by Carlos Santana on 24/06/2019.
//  Copyright © 2019 Carlos Santana. All rights reserved.
//

import UIKit
import RxSwift

class CategoryTableViewCell: UITableViewCell {

    var disposeBag = DisposeBag()

    lazy var categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 2
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        stackView.addArrangedSubview(categoryImageView)
        stackView.addArrangedSubview(titleLabel)
 
        stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -15).isActive = true
        stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        categoryImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        categoryImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        selectionStyle = .none
        accessoryType = .disclosureIndicator
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
}

class CategoryHomeTableViewCell: CategoryTableViewCell {

    override func setup() {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        titleLabel.layer.shadowOffset = CGSize(width: 3, height: 3)
        titleLabel.layer.shadowColor = UIColor.darkGray.cgColor
        titleLabel.layer.shadowRadius = 3
        titleLabel.layer.shadowOpacity = 1
        titleLabel.layer.masksToBounds = false
        categoryImageView.layer.cornerRadius = 10
        
        categoryImageView.addSubview(titleLabel)
        stackView.addArrangedSubview(categoryImageView)
        
        stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -15).isActive = true
        stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        let heightConstraint = stackView.heightAnchor.constraint(equalToConstant: 300)
        heightConstraint.priority = UILayoutPriority(rawValue: 999)
        heightConstraint.isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: categoryImageView.bottomAnchor, constant: -15).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: categoryImageView.centerXAnchor).isActive = true
        
        selectionStyle = .none
        accessoryType = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
}
