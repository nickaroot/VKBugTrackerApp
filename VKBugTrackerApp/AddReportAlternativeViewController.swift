//
//  AddReportAlternativeViewController.swift
//  VKBugTrackerApp
//
//  Created by Nick Arut on 03.05.2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

class AddReportAlternativeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentCellHeight = CGFloat(),
        keyboardSize: CGSize?
    
    let staticRowsOffset = 4

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return staticRowsOffset
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.item == 0) {
            let cell = Bundle.main.loadNibNamed("AddReportProductTableViewCell", owner: self, options: nil)?.first as! AddReportProductTableViewCell
            cell.selectionStyle = .none
            
            currentCellHeight = cell.contentView.frame.size.height
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
            
            return cell
            
        } else if (indexPath.item == 1) {
            let cell = Bundle.main.loadNibNamed("AddReportTitleTableViewCell", owner: self, options: nil)?.first as! AddReportTitleTableViewCell
            cell.selectionStyle = .none
            
            currentCellHeight = cell.contentView.frame.size.height
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
            
            return cell
            
        } else {
            let cell = UITableViewCell()
            currentCellHeight = 8
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
            return cell
        }
        
    }
}
