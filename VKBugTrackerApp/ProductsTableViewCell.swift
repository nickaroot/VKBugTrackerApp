//
//  ProductsTableViewCell.swift
//  VKBugTrackerApp
//
//  Created by Nick Aroot on 03/01/2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

class ProductsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var pImageView: UIImageView!
    @IBOutlet weak var pTitleLabel: UILabel!
    @IBOutlet weak var pCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.pImageView.layer.cornerRadius = self.pImageView.frame.size.width / 2
        self.pImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
