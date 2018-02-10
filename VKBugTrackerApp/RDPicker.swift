//
//  RDPicker.swift
//  VKBugTrackerApp
//
//  Created by Nick Aroot on 18/01/2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

class RDPickerView: UIPickerView
{
    @IBInspectable var selectorColor: UIColor? = nil
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        if let color = selectorColor
        {
            if subview.bounds.height <= 1.0
            {
                subview.backgroundColor = color
            }
        }
        
    }
}
