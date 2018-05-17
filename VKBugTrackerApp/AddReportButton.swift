//
//  AddReportButton.swift
//  
//
//  Created by Nick Arut on 03.05.2018.
//

import UIKit

@IBDesignable class AddReportButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = (newValue != 0)
        }
        
        get {
            return layer.cornerRadius
        }
    }
    
}
