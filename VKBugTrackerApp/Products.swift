//
//  Products.swift
//  VKBugTrackerApp
//
//  Created by Nick Arut on 12.05.2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

struct Product {
    let id: Int
    let title: String
    var coverUrl: URL?
    var coverImage: UIImage?
}

var products = [Product]()

var productsAvatars = [Int: UIImage?]()
