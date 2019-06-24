//
//  Money.swift
//  Gocco
//
//  Created by Carlos Santana on 16/06/2019.
//  Copyright © 2019 Carlos Santana. All rights reserved.
//

import Foundation

enum Currency: String, Codable {
    
    case USD
    case EUR
}

struct Money {

    var money: (NSDecimalNumber, Currency)
    
    static let `default` = Money(amount: 0, currency: .EUR)
    
    static let decimalHandler = NSDecimalNumberHandler(roundingMode: .down, scale: 2, raiseOnExactness: true, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
    
    var amount: Double {
        return money.0.rounding(accordingToBehavior: Money.decimalHandler).doubleValue
    }
    
    var currency: Currency {
        return money.1
    }

    init(amount: Double, currency: Currency) {
        self.init(amount: NSDecimalNumber(value: amount as Double), currency: currency)
    }

    init(amount: Int, currency: Currency) {
        self.init(amount: NSDecimalNumber(value: amount as Int), currency: currency)
    }
    
    init(amount: NSDecimalNumber, currency: Currency) {
        money = (amount, currency)
    }
}

extension Money: CustomStringConvertible {

    var description: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = currency.rawValue
        f.minimumFractionDigits = 0
        return f.string(from: NSNumber(value: amount))!
    }
}

extension Money: Comparable {

    static public func ==(lhs: Money, rhs: Money) -> Bool {
        guard lhs.currency == rhs.currency && lhs.money.0.compare(rhs.money.0) == .orderedSame else { return false }
        return true
    }

    static public func <(lhs: Money, rhs: Money) -> Bool {
        guard lhs.currency == rhs.currency && lhs.amount < rhs.amount else { return false }
        return true
    }
}
