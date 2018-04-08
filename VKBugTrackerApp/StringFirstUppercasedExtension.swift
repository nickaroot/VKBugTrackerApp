//
//  StringFirstUppercasedExtension.swift
//  VKBugTrackerApp
//
//  Created by Nick Arut on 07.04.2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

extension StringProtocol {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}
