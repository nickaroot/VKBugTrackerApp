//
//  Reports.swift
//  VKBugTrackerApp
//
//  Created by Nick Aroot on 15/01/2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

struct Tag {
    let id: Int
    let type: String
    let productId: Int
    let title: String
    var size: CGSize
}

enum StatusStyle {
    case open
    case closed
}

struct Status {
    let style: StatusStyle
    let title: String
}

struct Report {
    var id: Int?
    var title: String?
    var date: String?
    var hash: String?
    var comments: String?
    var author: String?
    var status: Status?
    var product: Tag?
    var tags: [Tag]
    
    init( id: Int? = nil,
        title: String? = nil,
        date: String? = nil,
        hash: String? = nil,
        comments: String? = nil,
        author: String? = nil,
        status: Status? = nil,
        product: Tag? = nil,
        tags: [Tag] = [Tag]() ) {
        
        self.id = id
        self.title = title
        self.date = date
        self.hash = hash
        self.comments = comments
        self.author = author
        self.status = status
        self.product = product
        self.tags = tags
        
    }
}

var reports = [Report]()
var reportsSearching = [Report]()
var isSearching = false
