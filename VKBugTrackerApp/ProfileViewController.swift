//
//  ProfileViewController.swift
//  VKBugTracker
//
//  Created by Nick Aroot on 24/12/2017.
//  Copyright © 2017 Nick Aroot. All rights reserved.
//

import UIKit
import Kanna

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var productsTableView: UITableView!
    @IBOutlet weak var statLabel: UILabel!
    @IBOutlet weak var overallLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var closeButton: UIButton!
    
    var lastProfileId: String?,
        profileId: String?,
        isModal = false
    
    struct Product {
        let id: Int
        let title: String
        let cover: UIImage
        let count: String
    }
    
    var products = [Product]()
    
    @IBAction func closeButtonTouchDown(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        overallLabel.isHidden = true
        
        productsTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: productsTableView.frame.size.width, height: 1))
        productsTableView.separatorColor = UIColor.clear
        
        self.navigationController?.navigationBar.shouldRemoveShadow(true)
        self.edgesForExtendedLayout = .bottom
        
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2
        self.avatarImageView.clipsToBounds = true
        
        productsTableView.delegate = self
        productsTableView.dataSource = self
        
        self.productsTableView.rowHeight = 60
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if profileId == nil {
            profileId = userId
        }
        
        if lastProfileId != profileId {
            products.removeAll()
            getProfile()
            getProducts()
        }
        
        closeButton.isHidden = !isModal
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        lastProfileId = profileId
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let product = products[indexPath.row]
        let cell = Bundle.main.loadNibNamed("ProductsTableViewCell", owner: self, options: nil)?.first as! ProductsTableViewCell
        
//        cell.pImageView.image = UIImage(data: try! Data(contentsOf: URL(string: product.cover)!)) // BAD PRACTICE !! SELF ABUSED
        cell.pImageView.image = product.cover
        cell.pTitleLabel.text = product.title
        cell.pCountLabel.text = product.count
        return cell
    }
    func getProfile() {
        DispatchQueue.main.async {
            do {
                let contents = try String(contentsOf: URL(string: "https://vk.com/bugtracker?act=reporter&al=0&al_id=\(userId!)&id=\(self.profileId!)")!, encoding: .windowsCP1251)
                
                let doc = try HTML(html: String(describing: contents), encoding: .windowsCP1251)
                
                dump(doc)
                
                let name = doc.at_css(".mem_link")?.text!
                let stat = String(describing: (doc.at_css(".bt_reporter_content_block")?.text!)!.split(separator: " ")[0])
                self.statLabel.text = stat
                self.productsTableView.isHidden = true
                if stat == "Исключён" {
                    self.overallLabel.text = "из программы."
                } else if stat == "Не" {
                    self.statLabel.text = self.statLabel.text! + " участвует"
                    self.overallLabel.text = "в программе."
                } else if stat == "Подал" {
                    self.statLabel.text = self.statLabel.text! + " заявку"
                    self.overallLabel.text = "на вступление в программу."
                } else {
                    self.overallLabel.text = "в общем рейтинге"
                    self.productsTableView.isHidden = false
                }
                //                let counter = String(describing: (doc.at_css(".bt_reporter_content_block a")?.text!)!.split(separator: " ")[0])
                var avatar = doc.at_css(".bt_reporter_icon_img")!["src"]
                if (avatar != nil && avatar == "/images/camera_200.png") {
                    avatar = "https://vk.com\(avatar!)"
                }
                self.navigationItem.title = name
                self.avatarImageView.image = UIImage(data: try! Data(contentsOf: URL(string: avatar!)!))
                
            } catch {
                
            }
        }
    }
    
    func getProducts() {
        DispatchQueue.main.async {
            do {
                let contents = try String(contentsOf: URL(string: "https://vk.com/bugtracker?act=reporter_products&al=0&al_id=\(userId!)&id=\(self.profileId!)")!, encoding: .windowsCP1251)
                
                let doc = try HTML(html: String(describing: contents), encoding: .windowsCP1251)
                
                for productRow in doc.css(".bt_reporter_product:not(.bt_reporter_product_unavailable)") {
                    let cover = UIImage(data: try! Data(contentsOf: URL(string: (productRow.at_css(".bt_reporter_product_img")?["src"])!)!))
                    let title = productRow.at_css(".bt_reporter_product_title a")?.text!
                    let id = Int(String(describing: (productRow.at_css(".bt_reporter_product_title a")?["href"]!.split(separator: "&")[1])!.split(separator: "=")[1]))
                    let count = String(describing: (productRow.at_css(".bt_reporter_product_nreports")?.text!)!.split(separator: " ")[0])
                    
                    self.products.append(Product(id: id!, title: title!, cover: cover!, count: count))
                }
                
                self.activityIndicator.stopAnimating()
                
                self.productsTableView.reloadData()
                self.overallLabel.isHidden = false
                self.productsTableView.separatorColor = UIColor.lightGray
            } catch {
                
            }
        }
    }
}
