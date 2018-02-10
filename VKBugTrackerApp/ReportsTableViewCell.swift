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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagsCollection: UICollectionView!
    
    var item: Int?
    var tagsCount = 0
    var tags = [Tag]()
    var blocked = false
    var collectionWidth = CGFloat(0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tagsCollection.dataSource = self
        tagsCollection.delegate = self
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        tags = reports[item!].tags
        tagsCount = tags.count
        
        dateLabel.sizeToFit()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.register(UINib(nibName: "ReportsTagsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "reportsTagsCell")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reportsTagsCell", for: indexPath) as! ReportsTagsCollectionViewCell
        
        if !blocked {
            
            cell.tagTitle.text = tags[indexPath.item].title
            cell.tagTitle.sizeToFit()
            cell.tagTitle.layer.frame.size = CGSize(width: cell.tagTitle.frame.size.width+12, height: 17)
            cell.layer.frame.size = cell.tagTitle.layer.frame.size

            tags[indexPath.item].size = cell.tagTitle.layer.frame.size

            collectionWidth = collectionWidth+tags[indexPath.item].size.width+15
            
            if indexPath.item == 0 {
                collectionWidth = collectionWidth+1
            }
            
            if indexPath.item == tagsCount-1 {
                blocked = true
                tagsCollection.reloadItems(at: [indexPath])
            }
            
            if tagsCollection.layer.frame.size.width <= collectionWidth {
                tags[indexPath.item].size = CGSize.zero
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return tags[indexPath.item].size
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
