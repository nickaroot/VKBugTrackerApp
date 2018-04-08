//
//  NavigationBarHideShadow.swift
//  VKBugTrackerApp
//
//  Created by Nick Aroot on 30/12/2017.
//  Copyright © 2017 Nick Aroot. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    func shouldRemoveShadow(_ value: Bool) -> Void {
        if value {
            self.setValue(true, forKey: "hidesShadow")
        } else {
            self.setValue(false, forKey: "hidesShadow")
        }
    }
}
