//
//  ReportAttachmentsCollectionViewCell.swift
//  VKBugTrackerApp
//
//  Created by Nick Arut on 08.03.2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

class ReportAttachmentsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var icon: UIImageView!
    
    var attachment: ReportAttachment?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        switch attachment!.type {
        case .icon1:
            icon.center.y -= 0
        case .icon2:
            icon.center.y -= 50
        case .icon3:
            icon.center.y -= 100
        case .icon4:
            icon.center.y -= 100
        case .icon5:
            icon.center.y -= 150
        case .icon6:
            icon.center.y -= 200
        case .icon7:
            icon.center.y -= 250
        case .icon8:
            icon.center.y -= 300
        default:
            break;
        }
    }

}
