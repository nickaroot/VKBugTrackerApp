//
//  ReportAttachments.swift
//  VKBugTrackerApp
//
//  Created by Nick Arut on 16.03.2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

enum DocType {
    case icon1
    case icon2
    case icon3
    case icon4
    case icon5
    case icon6
    case icon7
    case icon8
}

struct ReportAttachment {
    let type: DocType
    let href: String
}
