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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    struct Product {
        let id: Int
        let title: String
        let cover: String
        let count: String
    }
    
    var products = [Product]()
    
    override func viewDidLoad() {
        
        self.navigationController?.navigationBar.shouldRemoveShadow(true)
        self.edgesForExtendedLayout = .bottom
        
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2
        self.avatarImageView.clipsToBounds = true
        
        productsTableView.delegate = self
        productsTableView.dataSource = self
        productsTableView.layer.cornerRadius = 10
        productsTableView.layer.masksToBounds = true
        
        self.productsTableView.rowHeight = 60
        
        getValues()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let product = products[indexPath.row]
        let cell = Bundle.main.loadNibNamed("ProductsTableViewCell", owner: self, options: nil)?.first as! ProductsTableViewCell
        
        cell.pImageView.image = UIImage(data: try! Data(contentsOf: URL(string: product.cover)!))
        cell.pTitleLabel.text = product.title
        cell.pCountLabel.text = product.count
        return cell
    }
    
    func getValues() {
        DispatchQueue.main.async {
            do {
                let contents = try String(contentsOf: URL(string: "https://vk.com/"+profileURL)!, encoding: .windowsCP1251)
                
                let doc = try HTML(html: String(describing: contents), encoding: .windowsCP1251)
                
                let name = doc.at_css(".mem_link")?.text!
                let stat = String(describing: (doc.at_css(".bt_reporter_content_block")?.text!)!.split(separator: " ")[0])
//                let counter = String(describing: (doc.at_css(".bt_reporter_content_block a")?.text!)!.split(separator: " ")[0])
                let avatar = doc.at_css(".bt_reporter_icon_img")!["src"]
                
                self.navigationItem.title = name
                self.statLabel.text = stat
                self.avatarImageView.image = UIImage(data: try! Data(contentsOf: URL(string: avatar!)!))
                
                for productRow in doc.css(".bt_reporter_product") {
                    let cover = productRow.at_css(".bt_reporter_product_img")?["src"]
                    let title = productRow.at_css(".bt_reporter_product_title")?.text!
                    let id = Int(String(describing: (productRow.at_css(".bt_reporter_product_title")?["href"]!.split(separator: "&")[1])!.split(separator: "=")[1]))
                    let count = String(describing: (productRow.at_css(".bt_reporter_product_nreports")?.text!)!.split(separator: " ")[0])
                    
                    self.products.append(Product(id: id!, title: title!, cover: cover!, count: count))
                }
                
                self.activityIndicator.stopAnimating()
                
                self.productsTableView.reloadData()
                
            } catch {
                
            }
        }
    }
}
