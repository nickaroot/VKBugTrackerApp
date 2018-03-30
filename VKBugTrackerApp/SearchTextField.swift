//
//  AppDelegate.swift
//  VKBugTrackerApp
//
//  Created by Nick Aroot on 21/03/2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

class SearchTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35);
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        if (self.textAlignment == .center) {
            var textRect = super.leftViewRect(forBounds: bounds)
            textRect.origin.x += (UIScreen.main.bounds.width / 2) - 84
            return textRect
        } else {
            var textRect = super.leftViewRect(forBounds: bounds)
            textRect.origin.x += 15
            return textRect
        }
    }
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let image = leftImage {
            leftViewMode = UITextFieldViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            imageView.alpha = 0.7
            leftView = imageView
        } else {
            leftViewMode = UITextFieldViewMode.never
            leftView = nil
        }
    }
}
