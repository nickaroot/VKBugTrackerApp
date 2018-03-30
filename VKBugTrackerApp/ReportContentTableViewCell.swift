//
//  ReportContentTableViewCell.swift
//  VKBugTrackerApp
//
//  Created by Nick Arut on 07.03.2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

class ReportContentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var authorAvatar: UIImageView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var authorDate: UILabel!
    @IBOutlet weak var textTitle: UITextView!
    @IBOutlet weak var textContent: UITextView!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var tester: UIView!
    @IBOutlet weak var tester2: UIView!
    
    var imageUrl: URL?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        authorAvatar.layer.cornerRadius = authorAvatar.layer.frame.size.width / 2
        authorAvatar.clipsToBounds = true
        
        DispatchQueue.main.async {
            guard let imageData = try? Data(contentsOf: self.imageUrl!) else {
                print("Avatar Loading Error...")
                return
            }
                self.authorAvatar.image = UIImage(data: imageData)
        }
    }
    
    func bookmark() {
        bookmarkButton.setImage(UIImage(named: "star-filled"), for: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:])
        return false
    }
    
}

