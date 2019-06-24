//
//  SwiftExtension.swift
//  Gocco
//
//  Created by Carlos Santana on 17/06/2019.
//  Copyright © 2019 Carlos Santana. All rights reserved.
//

import Foundation

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
