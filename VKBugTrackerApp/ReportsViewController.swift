//
//  ReportsViewController.swift
//  VKBugTracker
//
//  Created by Nick Aroot on 24/12/2017.
//  Copyright © 2017 Nick Aroot. All rights reserved.
//

import UIKit
import WebKit
import Kanna

class ReportsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addReportButton: UIButton!
    
    var isSearching = false
    var selectedId: Int?
//    var searchingData = [[String]]()
    var refreshControl: UIRefreshControl!
    var timer: Timer!
    var lastTimestamp = ""
    
    override func viewDidLoad() {
        
        self.navigationController?.navigationBar.shouldRemoveShadow(true)
        self.edgesForExtendedLayout = .bottom
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .white
        textFieldInsideSearchBar?.textAlignment = .center
        
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = .white
        
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = .white
        
        let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.tintColor = .vkBlue
        
        //Constructing tableView.
        self.tableView.rowHeight = 60
        self.tableView.register(ReportsTableViewCell.self, forCellReuseIdentifier: "cell")
        
        refreshControl = UIRefreshControl()
        
        refreshControl.backgroundColor = .vkBlue
        refreshControl.tintColor = .white
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.isUserInteractionEnabled = true
        addReportButton.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        DispatchQueue.main.async {
            self.parseReports(self.lastTimestamp, query: "")
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
//            refreshReportsTableView(self)
            parseReports(lastTimestamp, query: "")
            timer = Timer.scheduledTimer(timeInterval: 2, target: self,   selector: (#selector(ReportsViewController.refreshControlEndRefreshing)), userInfo: nil, repeats: true)
        }
    }
    
    func parseReports(_ timestamp: String, query: String) {
        
        var request = URLRequest(url: URL(string: "https://vk.com/bugtracker")!)
        request.httpMethod = "POST"
        let postString = "al=1&load=1&min_udate=\(timestamp)&q=\(query)"
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
            
            var loadedReports = [Report]()
            
            do {
                
                let doc = try HTML(html: responseString!, encoding: .windowsCP1251)
                
                for reportsRow in doc.css(".bt_report_row") {
                    var report = Report(id: 0, title: "", date: "", hash: "", tags: [])
                    
                    if let reportsRowTitle = reportsRow.at_css(".bt_report_title a") {
                        report.id = Int(String(describing: ((reportsRowTitle["href"]!.split(separator: "&")[1]).split(separator: "=")[1])))!
                        report.title = reportsRowTitle.text!
                    }
                    
                    if let reportsRowTime = reportsRow.at_css(".bt_report_info_details") {
                        report.date = String(describing: (reportsRowTime.innerHTML?.split(separator: "<")[0])!)
                    }
                    
                    if let reportsRowFav = reportsRow.at_css(".bt_report_fav") {
                        report.hash = matches(for: "(?<=').*(?=')", in: reportsRowFav["onclick"]!)[0]
                    }
                    
                    for reportsRowTag in reportsRow.css(".bt_report_tags .bt_tag_label") {
                        let ids = matches(for: "[0-9]+", in: reportsRowTag["onclick"]!)
                        let type = matches(for: "(?<=').*(?=')", in: reportsRowTag["onclick"]!)[0]
                        if !(["version", "platform", "platform_version"].contains(type)) {
                            report.tags.append(Tag(id: Int(ids[0])!, type: type, productId: Int(ids[1])!, title: reportsRowTag.text!, size: CGSize(width: 1, height: 17) ))
                        }
                    }
                    
                    loadedReports.append(report)
                }
                
                self.lastTimestamp = String(describing: Int(NSDate().timeIntervalSince1970))
                
                reports.insert(contentsOf: loadedReports, at: 0)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
                
            } catch {
                print("Parsing Error")
            }
            
        }
        task.resume()
    }
    
    @objc func refreshControlEndRefreshing() {
        
        self.refreshControl.endRefreshing()
        
        timer = Timer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSelectedReport" {
            let DestViewController: ReportViewController = segue.destination as! ReportViewController
            if isSearching {
//                DestViewController.reportId = searchingData[selectedId!][1]
//                DestViewController.reportTitle = searchingData[selectedId!][0]
//                DestViewController.reportBookmarkHash = data[selectedId!][2]
            } else {
                DestViewController.reportsId = selectedId
                DestViewController.reportId = reports[selectedId!].id
                DestViewController.reportTitle = reports[selectedId!].title
                DestViewController.reportBookmarkHash = reports[selectedId!].hash
            }
        } else if segue.identifier == "showAddReport" {
            return
        }
    }
    
    var data = Array<Array<String>>()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
//            return searchingData.count
            return reportsSearching.count
        } else {
            return reports.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ReportsTableViewCell", owner: self, options: nil)?.first as! ReportsTableViewCell
        
        if isSearching {
//            cell.textLabel?.text = searchingData[indexPath.row][0]
//            cell.detailTextLabel?.text = searchingData[indexPath.row][2]
        } else {
            cell.titleLabel.text = reports[indexPath.row].title
            cell.dateLabel.text = reports[indexPath.row].date
            
            cell.item = indexPath.item
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        tableView.isUserInteractionEnabled = false
        
        selectedId = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        DispatchQueue.main.async {
            self.isSearching = false
            self.performSegue(withIdentifier: "showSelectedReport", sender: self)
        }
    }
    
    @IBAction func addReportButtonDown(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        addReportButton.isUserInteractionEnabled = false
        
        DispatchQueue.main.async {
            self.isSearching = false
            self.performSegue(withIdentifier: "showAddReport", sender: self)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.isEmpty)! {
            isSearching = false
            self.tableView.reloadData()
        } else {
            isSearching = true
//            searchingData.removeAll()
//            for el in data {
//                let currentString = el[0] as String
//                if currentString.lowercased().range(of: searchText.lowercased()) != nil {
//                    searchingData.append(el)
//                }
//            }
        }
    }
}
