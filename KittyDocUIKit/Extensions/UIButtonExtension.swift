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
            return isEnabled && alpha == 1.0
        }
        set {
            alpha = newValue ? 1.0 : 0.5
            isEnabled = newValue
        }
    }
}
