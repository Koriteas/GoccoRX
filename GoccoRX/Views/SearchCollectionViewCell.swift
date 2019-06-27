//
//  SearchCollectionViewCell.swift
//  GoccoRX
//
//  Created by Carlos Santana on 25/06/2019.
//  Copyright © 2019 Carlos Santana. All rights reserved.
//

import UIKit
import RxSwift

class SearchCollectionViewCell: UICollectionViewCell {

    var disposeBag = DisposeBag()
    
    lazy var itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    lazy var itemNameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .red
        label.textColor = .black
        label.numberOfLines = 2
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    lazy var itemPriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
 
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        let infoStackView = UIStackView()
        infoStackView.spacing = 5
        infoStackView.axis = .vertical
        infoStackView.distribution = .fill
        infoStackView.alignment = .fill
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.addArrangedSubview(itemNameLabel)
        infoStackView.addArrangedSubview(itemPriceLabel)
        
        stackView.addArrangedSubview(itemImageView)
        stackView.addArrangedSubview(infoStackView)

        stackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        infoStackView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
        itemImageView.heightAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
        itemNameLabel.topAnchor.constraint(equalTo: infoStackView.topAnchor).isActive = true
        itemPriceLabel.bottomAnchor.constraint(equalTo: infoStackView.bottomAnchor).isActive = true
    }
   
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        
        var newFrame = layoutAttributes.frame
        newFrame.size.height = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        frame = newFrame
        layoutAttributes.frame = newFrame
        
        return layoutAttributes
    }
}
