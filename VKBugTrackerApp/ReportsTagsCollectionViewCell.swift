//
//  ReportsTagsCollectionViewCell.swift
//  VKBugTrackerApp
//
//  Created by Nick Aroot on 14/01/2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

class ReportsTagsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tagTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.layer.cornerRadius = 4
//        self.layer.masksToBounds = true
        
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0
    }

}
