//
//  APIWorker.swift
//  VKBugTrackerApp
//
//  Created by Nick Aroot on 04/01/2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit
import SwiftyVK

final class APIWorker {
    
    class func action(_ tag: Int, sender: AnyObject) {
        switch tag {
        case 1:
            authorize(sender: sender)
        case 2:
            logout(sender: sender)
//        case 3:
//            captcha()
//        case 4:
//            usersGet()
//        case 5:
//            friendsGet()
//        case 6:
//            uploadPhoto(sender: sender)
//        case 7:
//            validation()
//        case 8:
//            share()
        default:
            print("Unrecognized action!")
        }
    }
    
    class func authorize(sender: AnyObject) {
        VK.sessions.default.logIn(
            onSuccess: { info in
//                print("SwiftyVK: success authorize with", info)
                if let s = sender as? AuthViewController {
                    s.loadReportsViewController()
                }
        },
            onError: { error in
//                print("SwiftyVK: authorize failed with", error)
        }
        )
    }
    
    class func logout(sender: AnyObject) {
        VK.sessions.default.logOut()
        print("SwiftyVK: LogOut")
    }
    
//    class func captcha() {
//        VK.API.Custom.method(name: "captcha.force")
//            .onSuccess { print("SwiftyVK: captcha.force successed with \n \(JSON($0))") }
//            .onError { print("SwiftyVK: captcha.force failed with \n \($0)") }
//            .send()
//    }
//
//    class func validation() {
//        VK.API.Custom.method(name: "account.testValidation")
//            .onSuccess { print("SwiftyVK: account.testValidation successed with \n \(JSON($0))") }
//            .onError { print("SwiftyVK: account.testValidation failed with \n \($0)") }
//            .send()
//    }
//
//    class func usersGet() {
//        VK.API.Users.get(.empty)
//            .configure(with: Config.init(httpMethod: .POST))
//            .onSuccess { print("SwiftyVK: users.get successed with \n \(JSON($0))") }
//            .onError { print("SwiftyVK: friends.get fail \n \($0)") }
//            .send()
//    }
//
//    class func friendsGet() {
//        VK.API.Friends.get(.empty)
//            .onSuccess { print("SwiftyVK: friends.get successed with \n \(JSON($0))") }
//            .onError { print("SwiftyVK: friends.get failed with \n \($0)") }
//            .send()
//    }

    class func removeDocument(sender: AnyObject, item: Int, completion: @escaping (Bool?) -> Swift.Void) {
        
        VK.API.Docs.delete([.ownerId: attachments[item].ownerId, .docId: attachments[item].docId])
            .onSuccess {
                
                do {
                    let data = try! JSONSerialization.jsonObject(with: $0, options: .mutableContainers)
                    let dict = data as! [String : Bool]
                    let response = dict["response"]
                    
                    completion(response)
                }
            }
            .onError({
                print($0)
                completion(nil)
            })
        .send()
    }
    
    class func uploadDocument(sender: AnyObject, doc: Data, thumbnail: UIImage?, completion: @escaping (String?, String?, UIImage?) -> Swift.Void) {
        
        let sender = sender as! AttachmentsViewController
        
        if thumbnail == nil {
            
            let media = Media.image(data: doc, type: .png)
            
            VK.API.Upload.document(media)
                .onSuccess {
                    
                    let response = try JSONSerialization.jsonObject(with: $0)
                    let arr = response as? [Any]
                    let dict = arr![0] as? [String: Any]
                    
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3, animations: {
                            sender.loadingProgress.alpha = 0
                        })
                        
                        sender.loadingProgress.setProgress(0, animated: true)
                    }
                    
                    let cover = UIImage(data: doc)
                    completion("\(dict!["owner_id"]!)", "\(dict!["id"]!)", cover)
                    
                }
                .onError {_ in
                    DispatchQueue.main.async {
                        sender.loadingProgress.progressTintColor = .red
                        sender.loadingProgress.setProgress(1, animated: true)
                    }
                    completion(nil, nil, nil)
                }
                .onProgress {
                    
                    let progress: Float!
                    
                    switch $0 {
                    case let .sent(current, of):
                        progress = Float(current/of)
                    case let .recieve(current, of):
                        progress = Float(current/of)
                    }
                    
                    DispatchQueue.main.async {
                        sender.loadingProgress.setProgress(progress, animated: true)
                    }
                    
                }
                .send()
            
        } else {
            
            let media = Media.document(data: doc, type: "mp4")
            
            VK.API.Upload.document(media)
                .onSuccess {
                    
                    let response = try JSONSerialization.jsonObject(with: $0)
                    let arr = response as? [Any]
                    let dict = arr![0] as? [String: Any]
                    
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3, animations: {
                            sender.loadingProgress.alpha = 0
                        })
                        
                        sender.loadingProgress.setProgress(0, animated: true)
                    }
                    
//                    let cover = UIImage(named: "video-player")
                    completion("\(dict!["owner_id"]!)", "\(dict!["id"]!)", thumbnail)
                    
                }
                .onError {_ in
                    completion(nil, nil, nil)
                }
                .onProgress {
                    
                    let progress: Float!
                    
                    switch $0 {
                    case let .sent(current, of):
                        progress = Float(current/of)
                    case let .recieve(current, of):
                        progress = Float(current/of)
                    }
                    
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3, animations: {
                            sender.loadingProgress.alpha = 1
                        })
                        
                        sender.loadingProgress.setProgress(Float(progress), animated: true)
                    }
                    
                }
                .send()
            
        }
    }
}
