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

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.width)
    }
}

extension UILabel {
    
    func setLineHeight(lineHeight: CGFloat, labelWidth: CGFloat) -> CGFloat {
        let text = self.text
        if let text = text {
            let attributeString = NSMutableAttributedString(string: text)
            let style = NSMutableParagraphStyle()
            
            style.lineSpacing = lineHeight
            attributeString.addAttribute(.paragraphStyle, value: style, range: NSMakeRange(0, text.characters.count))
            self.attributedText = attributeString
            return self.sizeThatFits(CGSize(width: labelWidth, height: 20)).height
        }
        return 0
    }
}
