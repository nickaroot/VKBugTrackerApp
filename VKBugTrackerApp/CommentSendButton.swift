//
//  CommentTextField.swift
//  
//
//  Created by Nick Arut on 02.05.2018.
//

import UIKit

@IBDesignable class CommentSendButton: UIButton {
    
    @IBInspectable var rounded: Bool {
        set {
            layer.cornerRadius = frame.size.height / 2 * CGFloat(integerLiteral: newValue.hashValue)
            layer.masksToBounds = newValue
        }
        
        get {
            return (layer.cornerRadius != 0)
        }
    }
        
}
