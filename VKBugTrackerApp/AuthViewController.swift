//
//  AuthViewController.swift
//  VKBugTracker
//
//  Created by Nick Aroot on 24/12/2017.
//  Copyright © 2017 Nick Aroot. All rights reserved.
//

import UIKit
import WebKit
import SwiftyVK

class AuthViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        let url = URL(string: "https://vk.com/bugtracker")
        let request = URLRequest(url: url!)
        webView.load(request)
        
    }
    
    func loadReportsViewController() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "AuthComplete", sender: self)
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if (webView.url!.absoluteString == "https://vk.com/bugtracker") {
            
            if VK.sessions.default.state == .authorized {
                loadReportsViewController()
            } else {
                APIWorker.authorize(sender: self)
            }
            
        } else {
            self.activityIndicator.stopAnimating()
            webView.alpha = 1
        }
    }
}

