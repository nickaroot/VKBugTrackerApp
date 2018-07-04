//
//  UITextViewFixed.swift
//  VKBugTrackerApp
//
//  Created by Nick Arut on 22.06.2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

@IBDesignable class UITextViewFixed: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}
