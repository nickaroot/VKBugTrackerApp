//
//  ReportAttachmentsTableViewCell.swift
//  VKBugTrackerApp
//
//  Created by Nick Arut on 08.03.2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit
import AVKit

class ReportAttachmentsTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var docsCollection: UICollectionView!
    
    var reportAttachments = [ReportAttachment]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        docsCollection.dataSource = self
        docsCollection.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reportAttachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.register(UINib(nibName: "ReportAttachmentsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ReportAttachmentsCollectionViewCell
        
        cell.attachment = reportAttachments[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            UIApplication.shared.open(URL(string: "https://vk.com\(reportAttachments[indexPath.item].href)")!, options: [:])
    }
}
