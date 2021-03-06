//
//  TextFieldExtention.swift
//  KittyDocUIKit
//
//  Created by 곽명섭 on 2021/01/18.
//

import UIKit
import Combine

extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextField } // receiving notifications with objects which are instances of UITextFields
            .map { $0.text ?? "" } // mapping UITextField to extract text
            .eraseToAnyPublisher()
    }
}

class ConstantUITextField: UITextField {
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        //if action == #selector(paste(_:)) {
        //    return true
        //}
        //return super.canPerformAction(action, withSender: sender)
        // Can't perform Paste func
        return false // Disable all funcs
    }
}

