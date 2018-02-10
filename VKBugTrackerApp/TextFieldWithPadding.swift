//
//  TextFieldWithPadding.swift
//  VKBugTrackerApp
//
//  Created by Nick Aroot on 30/12/2017.
//  Copyright © 2017 Nick Aroot. All rights reserved.
//
import UIKit

class TextFieldWithPadding: UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds,
                                     UIEdgeInsetsMake(0, 15, 0, 15))
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds,
                                     UIEdgeInsetsMake(0, 15, 0, 15))
    }
}
