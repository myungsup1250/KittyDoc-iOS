//
//  ViewController.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/15.
//

import UIKit

extension String {
//    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
//        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
//    }
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // serveriplable.text = "Bluetooth Alert".localized // "Bluetooth Alert".localized()
    }


}

