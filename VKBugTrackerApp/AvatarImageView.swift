//
//  AvatarImageView.swift
//  
//
//  Created by Nick Arut on 03.05.2018.
//

import UIKit

@IBDesignable class AvatarImageView: UIImageView {
    
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
