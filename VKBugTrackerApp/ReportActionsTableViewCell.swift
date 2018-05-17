//
//  ReportActionsTableViewCell.swift
//  VKBugTrackerApp
//
//  Created by Nick Arut on 02.05.2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit
import Kanna

class ReportActionsTableViewCell: UITableViewCell {

    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var productCover: AvatarImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bookmark() {
        bookmarkButton.setImage(UIImage(named: "star-filled"), for: .normal)
    }
    
}
