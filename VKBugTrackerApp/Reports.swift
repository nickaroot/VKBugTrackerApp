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

struct Report {
    var id: Int?
    var title: String?
    var date: String?
    var hash: String?
    var comments: String?
    var status: String?
    var tags: [Tag]
    
    init( id: Int? = nil,
        title: String? = nil,
        date: String? = nil,
        hash: String? = nil,
        comments: String? = nil,
        status: String? = nil,
        tags: [Tag] = [Tag]() ) {
        
        self.id = id
        self.title = title
        self.date = date
        self.hash = hash
        self.comments = comments
        self.status = status
        self.tags = tags
        
    }
}

var reports = [Report]()
var reportsSearching = [Report]()
var isSearching = false
