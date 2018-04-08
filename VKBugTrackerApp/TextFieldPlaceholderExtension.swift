//
//  Placeholder.swift
//  VKBugTrackerApp
//
//  Created by Nick Aroot on 18/01/2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

extension UITextField{
    @IBInspectable var placeholderColor: UIColor? {
        get {
            return self.placeholderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
}
