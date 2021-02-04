//
//  onOffButton.swift
//  KittyDocUIKit
//
//  Created by JEN Lee on 2021/01/24.
//

import Foundation
import UIKit

class onOffButton: UIButton {
    
    enum btnState {
        case On
        case Off
    }
    
    
    var isOn: btnState = .Off {
        didSet {
            setting()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setting() {
        switch isOn {
        case .On:
            self.isEnabled = true
            self.alpha = 1.0
        case .Off:
            self.isEnabled = false
            self.alpha = 0.5
        }
    }
    
    
}
