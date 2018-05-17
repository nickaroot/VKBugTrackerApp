//
//  VKDelegate.swift
//  VKBugTrackerApp
//
//  Created by Nick Aroot on 04/01/2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit
import SwiftyVK

final class VKDelegate: SwiftyVKDelegate {

    let appId = "6320346"
    let scopes: Scopes = [.docs, .offline]

    init() {
        VK.setUp(appId: appId, delegate: self)
    }

    func vkNeedsScopes(for sessionId: String) -> Scopes {
        return scopes
    }

    func vkNeedToPresent(viewController: VKViewController) {
        
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            rootController.present(viewController, animated: true)
        }
        
    }

    func vkTokenCreated(for sessionId: String, info: [String : String]) {
//        print("token created in session \(sessionId) with info \(info)")
        accessToken = info["access_token"]!
        userId = info["user_id"]!
        
        APIWorker.userInfo()
    }

    func vkTokenUpdated(for sessionId: String, info: [String : String]) {
//        print("token updated in session \(sessionId) with info \(info)")
        accessToken = info["access_token"]!
    }

    func vkTokenRemoved(for sessionId: String) {
//        print("token removed in session \(sessionId)")
    }
}

