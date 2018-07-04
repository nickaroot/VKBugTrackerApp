//
//  RoundedView.swift
//  VKBugTrackerApp
//
//  Created by Nick Arut on 22.06.2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

@IBDesignable class RoundedView: UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = (newValue != 0)
        }
        
        get {
            return layer.cornerRadius
        }
    }
    
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
