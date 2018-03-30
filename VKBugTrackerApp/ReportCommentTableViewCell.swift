//
//  ReportCommentTableViewCell.swift
//  VKBugTrackerApp
//
//  Created by Nick Arut on 11.03.2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

class ReportCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var authorAvatar: UIImageView!
    @IBOutlet weak var commentAuthor: UILabel!
    @IBOutlet weak var commentText: UITextView!
    @IBOutlet weak var commentDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        authorAvatar.layer.cornerRadius = authorAvatar.layer.frame.size.width / 2
        authorAvatar.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
