//
//  Attachments.swift
//  VKBugTrackerApp
//
//  Created by Nick Aroot on 08/01/2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

struct Attachment {
    let ownerId: String!
    let docId: String!
    let image: UIImage!
    var animated: Bool!
}

var attachments = [Attachment]()
