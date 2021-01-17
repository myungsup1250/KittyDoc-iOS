//
//  StringExtension.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/17.
//

import Foundation

extension String {
//    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
//        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
//    }
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
    }
}
