//
//  ReportComments.swift
//  VKBugTrackerApp
//
//  Created by Nick Arut on 16.03.2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

struct CommentRemove {
    var id: String
    var hash: String
}

struct ReportComment {
    let avatar: URL
    var avatarImage: UIImage?
    let authorName: String
    let authorId: String?
    let meta: Bool
    let text: String
    let date: String
    let remove: CommentRemove?
}
