//
//  ReportViewController.swift
//  VKBugTracker
//
//  Created by Nick Aroot on 24/12/2017.
//  Copyright © 2017 Nick Aroot. All rights reserved.
//

import UIKit
import WebKit
import Kanna

class ReportViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    var reportTitle: String?,
        reportId: Int?,
        reportsId: Int?,
        reportBookmarkHash: String?,
        bookmark = false,
        reportEditHash: String?
    
    override func viewDidLoad() {
        
        titleLabel.text = reportTitle
        titleLabel.sizeToFitHeight()
        
        descriptionTextView.delegate = self
        
        self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2
        self.avatar.clipsToBounds = true
        
        self.navigationController?.navigationBar.tintColor = .white
        
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().isTranslucent = false
        
        do {
            let contents = try String(contentsOf: URL(string: "https://vk.com/bugtracker?act=show&al=0&al_id=\(userId)&id=\(reportId!)")!, encoding: .windowsCP1251)
            
            let doc = try HTML(html: String(describing: contents), encoding: .windowsCP1251)
            
            let text = doc.at_css(".bt_report_one_descr")?.innerHTML?.replacingOccurrences(of: "<br>", with: "\n")
//            let regex = try! NSRegularExpression(pattern: "<.*?>", options: [.caseInsensitive])
//            let range = NSRange(location: 0, length: (text?.count)!)
//            let htmlLessString: String = regex.stringByReplacingMatches(in: text!, options: NSRegularExpression.MatchingOptions(), range:range, withTemplate: "")
            self.descriptionTextView.text = String(htmlEncodedString: text!)
            
            if (doc.at_css("._header_extra a") != nil) {
                let editContents = try String(contentsOf: URL(string: "https://vk.com/bugtracker?act=edit&al=0&al_id=\(userId)&id=\(reportId!)")!, encoding: .windowsCP1251)
                
                let editDoc = try HTML(html: String(describing: editContents), encoding: .windowsCP1251)
                
                let removeBtn = editDoc.at_css(".bt_hform_submit_block .secondary")
                
                reportEditHash = matches(for: "(?<=').*(?=')", in: removeBtn!["onclick"]!)[0]
            }
            
            if (doc.at_css(".bt_report_one_fav")?.className?.contains("bt_report_fav_checked"))! {
                self.bookmarkButton.setImage(UIImage(named: "star-filled"), for: .normal)
                self.bookmark = true
            }
            
            self.title = doc.at_css(".ui_crumb")?.text!
            
            self.authorLabel.text = doc.at_css(".bt_report_one_author_content a")?.text!
            
            self.dateLabel.text = doc.at_css(".bt_report_one_author_date")?.text!
            
            let imageSrc = doc.at_css(".bt_report_one_author__img")!["src"]!
            
            let imageUrl: URL!
            
            if imageSrc == "/images/camera_50.png" {
                imageUrl = URL(string: "https://vk.com\(imageSrc)")!
            } else {
                imageUrl = URL(string: imageSrc)!
            }
            
            DispatchQueue.main.async {
                let imageData = try! Data(contentsOf: imageUrl)
                self.avatar.image = UIImage(data: imageData)
            }
            
            self.activityIndicator.stopAnimating()
        } catch {
            
        }
    }
    
    func textView(_ descriptionTextView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:])
        return false
    }
    
    
    @IBAction func actionsButtonTouchDown(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let copyButton = UIAlertAction(title: "Скопировать ссылку", style: .default, handler: { (action) -> Void in
            let linkString = "https://vk.com/bugtracker?act=show&id=\(self.reportId!)"
            UIPasteboard.general.string = linkString
        })
        
        if (reportEditHash != nil) {
            
            let editButton = UIAlertAction(title: "Редактировать", style: .default, handler: { (action) -> Void in
                print("Edit button tapped")
            })
            
            let  deleteButton = UIAlertAction(title: "Удалить", style: .destructive, handler: { (action) -> Void in
                var request = URLRequest(url: URL(string: "https://vk.com/bugtracker")!)
                request.httpMethod = "POST"
                let postString = "act=a_remove_bugreport&id=\(self.reportId!)&hash=\(self.reportEditHash!)"
                request.httpBody = postString.data(using: .utf8)
                request.addValue("XMLHttpRequest", forHTTPHeaderField: "x-requested-with")
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print("error=\(String(describing: error))")
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(String(describing: response))")
                        
                    }
                    
                    let responseString = String(data: data, encoding: .windowsCP1251)
                }
                task.resume()
                
                reports.remove(at: self.reportsId!)
                
                self.navigationController?.popViewController(animated: true)
            })
            
            alertController.addAction(editButton)
            alertController.addAction(deleteButton)
        }
        
        let cancelButton = UIAlertAction(title: "Отменить", style: .cancel, handler: { (action) -> Void in
            
        })
        
        alertController.addAction(copyButton)
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func bookmarkTouchUp(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        var request = URLRequest(url: URL(string: "https://vk.com/bugtracker")!)
        request.httpMethod = "POST"
        let postString = "act=a_subscribe&v=\((!bookmark).hashValue)&id=\(reportId!)&hash=\(reportBookmarkHash!)"
        request.httpBody = postString.data(using: .utf8)
        request.addValue("XMLHttpRequest", forHTTPHeaderField: "x-requested-with")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                
            }
            
            let responseString = String(data: data, encoding: .windowsCP1251)
            
        }
        task.resume()
        
        if !bookmark {
            
            let originalTransform = self.bookmarkButton.transform
            let scaledTransform = originalTransform.scaledBy(x: 0, y: 0)
            
            self.bookmarkButton.transform = scaledTransform
            
            self.bookmarkButton.setImage(UIImage(named: "star-filled"), for: .normal)
            self.bookmark = true
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                
                self.bookmarkButton.transform = originalTransform
                
            }, completion: nil)
            
        } else {
            let originalTransform = self.bookmarkButton.transform
            let scaledTransform = originalTransform.scaledBy(x: 0, y: 0)
            
            self.bookmarkButton.transform = scaledTransform
            
            self.bookmarkButton.setImage(UIImage(named: "star"), for: .normal)
            self.bookmark = false
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                
                self.bookmarkButton.transform = originalTransform
                
            }, completion: nil)
        }
    }
}
