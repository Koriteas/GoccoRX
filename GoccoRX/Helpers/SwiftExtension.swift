//
//  SwiftExtension.swift
//  Gocco
//
//  Created by Carlos Santana on 17/06/2019.
//  Copyright © 2019 Carlos Santana. All rights reserved.
//

import UIKit

extension String {
    
    var isBlank: Bool {
        self.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var isNotBlank: Bool {
        !self.isBlank
    }
    
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

extension UIScrollView {

    func isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return contentOffset.y + frame.size.height + edgeOffset > contentSize.height
    }
}

extension UIStackView {
    
    func divider() {
        let view = UIView()
        addArrangedSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
        view.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    func spacer() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(view)
    }
}
