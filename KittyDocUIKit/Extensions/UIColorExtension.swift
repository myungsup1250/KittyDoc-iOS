//
//  UIColorExtension.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/18.
//

import UIKit

extension UIColor {
    
    convenience init(hex: UInt, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    static let background = UIColor.white
    static let valid = UIColor.systemBlue
    static let nonValid = UIColor.systemGray
    
    static var dark: UIColor {
        return UIColor(red: 42/255, green: 52/255, blue: 58/255, alpha: 1.0)
    }

    static var deeppink: UIColor {
        return UIColor(red: 253/255, green: 63/255, blue: 127/255, alpha: 1.0)
    }

    static var turquoise: UIColor {
        return UIColor(red: 0, green: 206/255, blue: 209/255, alpha: 1.0)
    }

    static var seagreen: UIColor {
        return UIColor(red: 67/255, green: 205/255, blue: 128/255, alpha: 1.0)
    }

    static var violetred: UIColor {
        return UIColor(red: 185/255, green: 29/255, blue: 81/255, alpha: 1.0)
    }

    static var sienna: UIColor {
        return UIColor(red: 204/255, green: 117/255, blue: 54/255, alpha: 1.0)
    }

    static var lightblue: UIColor {
        return UIColor(red: 69/255, green: 176/255, blue: 208/255, alpha: 1.0)
    }

    static var oceanblue: UIColor {
        return UIColor(red: 81/255, green: 110/255, blue: 190/255, alpha: 1.0)
    }
    
    static var yellow1: UIColor { UIColor(hex: 0xfcf9e8) }
    static var yellow2: UIColor { UIColor(hex: 0xf5e6ab) }
    static var yellow3: UIColor { UIColor(hex: 0xf2d675) }
    static var yellow4: UIColor { UIColor(hex: 0xf0c33c) }
    static var yellow5: UIColor { UIColor(hex: 0xdba617) }
    static var yellow_bright: UIColor { UIColor(hex: 0xf6d55c) }
    
    
    
    
}
