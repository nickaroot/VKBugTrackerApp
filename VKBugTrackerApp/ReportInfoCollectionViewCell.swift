//
//  ReportInfoCollectionViewCell.swift
//  VKBugTrackerApp
//
//  Created by Nick Arut on 09.04.2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

class ReportInfoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var value: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }

}
