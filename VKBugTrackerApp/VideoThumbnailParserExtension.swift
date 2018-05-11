//
//  VideoThumbnailParser.swift
//  VKBugTrackerApp
//
//  Created by Nick Aroot on 10/01/2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

extension AVAsset{
    var videoThumbnail:UIImage?{
        
        let assetImageGenerator = AVAssetImageGenerator(asset: self)
        assetImageGenerator.appliesPreferredTrackTransform = true
        
        var time = self.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            let thumbNail = UIImage.init(cgImage: imageRef)
            
            return thumbNail
            
        } catch {
            
            print("Error getting thumbnail video")
            return nil
            
            
        }
        
    }
}
