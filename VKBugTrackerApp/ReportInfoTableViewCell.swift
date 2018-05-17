//
//  ReportInfoTableViewCell.swift
//  VKBugTrackerApp
//
//  Created by Nick Arut on 09.04.2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

class ReportInfoTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var infoTitle: LabelPadding!
    @IBOutlet weak var infoValuesCollectionView: UICollectionView!
    
    var values = [String](),
        currentCellSize: CGSize?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        infoTitle.layer.cornerRadius = 5
        infoTitle.layer.masksToBounds = true
        
        self.infoValuesCollectionView.delegate = self
        self.infoValuesCollectionView.dataSource = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return values.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.register(UINib(nibName: "ReportInfoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ReportInfoCollectionViewCell
        
        cell.value.text = values[indexPath.item]
        cell.value.sizeToFit()
        cell.value.layer.frame.size = CGSize(width: cell.value.frame.size.width + collectionView.contentSize.height - 3, height: collectionView.contentSize.height - 1)
        cell.layer.frame.size = cell.value.layer.frame.size
        currentCellSize = cell.layer.frame.size
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return currentCellSize!
    }
    
}
