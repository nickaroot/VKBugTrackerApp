//
//  sizeToFitHeight.swift
//  VKBugTrackerApp
//
//  Created by Nick Aroot on 29/12/2017.
//  Copyright © 2017 Nick Aroot. All rights reserved.
//

import UIKit

extension UILabel {
    func sizeToFitHeight() {
        let size: CGSize = self.sizeThatFits(CGSize.init(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        var frame: CGRect = self.frame
        frame.size.height = size.height
        self.frame = frame
    }
}

extension UITextView {
    func sizeToFitHeight() {
        let size: CGSize = self.sizeThatFits(CGSize.init(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        var frame: CGRect = self.frame
        frame.size.height = size.height
        self.frame = frame
    }
    
    func adjustHeight()
    {
//        self.translatesAutoresizingMaskIntoConstraints = true
        self.sizeToFitHeight()
    }
}
