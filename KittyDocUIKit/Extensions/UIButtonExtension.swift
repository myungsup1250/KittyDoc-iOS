//
//  UIButtonExtension.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/18.
//

import UIKit

extension UIButton {
    var isValid: Bool {
        get {
            return isEnabled && backgroundColor == .valid
        }
        set {
            backgroundColor = newValue ? .valid : .nonValid
            isEnabled = newValue
        }
    }
}
