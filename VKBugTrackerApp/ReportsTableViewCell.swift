//
//  ReportsTableViewCell.swift
//  VKBugTrackerApp
//
//  Created by Nick Aroot on 14/01/2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

class ReportsTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagsCollection: UICollectionView!
    @IBOutlet weak var commentLabel: UILabel!
    
    var item: Int?,
        tagsCount = 0,
        tags = [Tag](),
        blocked = false,
        collectionWidth = CGFloat(0),
        collectionViewWidth = CGFloat(0),
        isSearching = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tagsCollection.dataSource = self
        tagsCollection.delegate = self
        
        collectionViewWidth = tagsCollection.frame.size.width
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if (isSearching) {
            if (item! < reportsSearching.count) {
                tags = reportsSearching[item!].tags
                tags.insert(Tag(id: -1, type: "status", productId: -1, title: (reportsSearching[item!].status?.firstUppercased)!, size: CGSize(width: 1, height: tagsCollection.contentSize.height - 1)), at: 0)
            }
        } else {
            tags = reports[item!].tags
            tags.insert(Tag(id: -1, type: "status", productId: -1, title: (reports[item!].status?.firstUppercased)!, size: CGSize(width: 1, height: tagsCollection.contentSize.height - 1)), at: 0)
        }
        
        tagsCount = tags.count
        
//        dateLabel.sizeToFit()
        
        commentLabel.layer.cornerRadius = commentLabel.frame.size.height / 2
        commentLabel.layer.masksToBounds = true
        commentLabel.layer.borderWidth = 0
//        commentLabel.layer.borderColor = UIColor.vkBlue.cgColor
        
        if commentLabel.text == nil {
//            commentLabel.layer.borderWidth = 0
            commentLabel.alpha = 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.register(UINib(nibName: "ReportsTagsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "reportsTagsCell")
        collectionView.register(UINib(nibName: "ReportsStatusCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "reportsStatusCell")
        
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reportsStatusCell", for: indexPath) as! ReportsStatusCollectionViewCell
            
            if !blocked {
                
                cell.statusTitle.text = tags[indexPath.item].title
                cell.statusTitle.sizeToFit()
                cell.statusTitle.layer.frame.size = CGSize(width: cell.statusTitle.frame.size.width, height: tagsCollection.contentSize.height - 1)
                cell.layer.frame.size = CGSize(width: cell.statusIndicator.layer.frame.size.width + 6 + cell.statusTitle.layer.frame.size.width, height: tagsCollection.contentSize.height - 1)
                
                tags[indexPath.item].size = cell.layer.frame.size
            }
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reportsTagsCell", for: indexPath) as! ReportsTagsCollectionViewCell

        if !blocked { // Только для первого прохода

            cell.tagTitle.text = tags[indexPath.item].title
            cell.tagTitle.sizeToFit()
            cell.tagTitle.layer.frame.size = CGSize(width: cell.tagTitle.frame.size.width + tagsCollection.contentSize.height - 3, height: tagsCollection.contentSize.height - 1)
            cell.layer.frame.size = cell.tagTitle.layer.frame.size

            tags[indexPath.item].size = cell.tagTitle.layer.frame.size

            if indexPath.item == tagsCount - 1 {
                blocked = true
                tagsCollection.reloadItems(at: [indexPath])
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        collectionWidth += tags[indexPath.item].size.width
        
        if collectionViewWidth >= collectionWidth {
            return tags[indexPath.item].size
        } else {
            return CGSize.zero
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
