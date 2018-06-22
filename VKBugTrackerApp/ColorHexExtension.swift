//
//  HexColor.swift
//  VKBugTrackerApp
//
//  Created by Nick Aroot on 30/12/2017.
//  Copyright © 2017 Nick Aroot. All rights reserved.
//

import UIKit

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
    
    open class var vkBlue: UIColor {
        get {
            return UIColor(hexString: "#5C90C7ff")!
        }
    }
    
    open class var vkBlueAdditive: UIColor {
        get {
            return UIColor(hexString: "#4F83BBff")!
        }
    }
    
    open class var grayBg: UIColor {
        get {
//            return UIColor(hexString: "#E7E8ECff")!
            return UIColor(red: 0.92455, green: 0.928169, blue: 0.94053, alpha: 1.0)
            // UIExtendedSRGBColorSpace 0.92455 0.928169 0.94053 1
        }
    }
}
