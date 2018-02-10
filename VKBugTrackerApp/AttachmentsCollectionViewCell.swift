//
//  AttachmentsCollectionViewCell.swift
//  VKBugTrackerApp
//
//  Created by Nick Aroot on 07/01/2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

class AttachmentsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var docImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        closeButton.layer.shadowColor = UIColor.black.cgColor
//        closeButton.layer.shadowOffset = CGSize(width: 3, height: 3)
//        closeButton.layer.shadowOpacity = 0.5
//        closeButton.layer.shadowRadius = (closeButton.layer.frame.width/2)
    }

}
