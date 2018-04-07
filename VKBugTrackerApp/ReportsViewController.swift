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

class ReportsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addReportButton: UIButton!
    @IBOutlet weak var searchField: UITextField!
    
    var selectedId: Int?,
        refreshControl: UIRefreshControl!,
        timer: Timer!,
        minTimestampLast = "",
        maxTimestampLast = "",
        lastQuery = "",
        keyboardShowed = false,
        reportsIsLoaded = 0
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.shouldRemoveShadow(true)
//        self.edgesForExtendedLayout = .bottom
        tableView.alpha = 0
        view.backgroundColor = UIColor.white
        self.tableView.rowHeight = 60
        
        refreshControl = UIRefreshControl()
        
        refreshControl.backgroundColor = .vkBlue
        refreshControl.tintColor = .white
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        customizeSearchBar()
    }
    
    func customizeSearchBar() {
        searchField.frame.size.height = 32
        searchField.frame.size.width = UIScreen.main.bounds.width - 84
        searchField.layer.cornerRadius = 16
        searchField.layer.masksToBounds = true
    }
    
    
    @IBAction func searchBarEditingDidBegin(_ sender: Any) {
        searchField.textAlignment = .left
        keyboardShowed = true
    }
    
    
    @IBAction func searchBarEditingDidEnd(_ sender: Any) {
        if (searchField.text == "") {
            searchField.textAlignment = .center
            isSearching = false
            self.parseReports(self.minTimestampLast, "", query: "")
        }
        keyboardShowed = false
    }
    
    @IBAction func searchBarPrimaryAction(_ sender: Any) {
        self.parseReports("", "", query: searchField.text!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.isUserInteractionEnabled = true
        addReportButton.isUserInteractionEnabled = true
        
        self.tabBarController?.tabBar.clipsToBounds = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        DispatchQueue.main.async {
            if (isSearching) {
                self.parseReports("", "", query: self.searchField.text!)
            } else {
                self.parseReports(self.minTimestampLast, "", query: "")
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            parseReports(minTimestampLast, "", query: lastQuery)
            timer = Timer.scheduledTimer(timeInterval: 2, target: self,   selector: (#selector(ReportsViewController.refreshControlEndRefreshing)), userInfo: nil, repeats: true)
        }
    }
    
    func parseReports(_ minTimestamp: String, _ maxTimestamp: String, query: String) {
        
        var request = URLRequest(url: URL(string: "https://vk.com/bugtracker")!)
        request.httpMethod = "POST"
        let postString = "al=1&load=1&min_udate=\(minTimestamp)&q=\(query)"
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
            dump(responseString!)
            
            var loadedReports = [Report]()
            
            do {
                
                let doc = try HTML(html: responseString!, encoding: .windowsCP1251)
                
                for reportsRow in doc.css(".bt_report_row") {
                    var report = Report(id: 0, title: "", date: "", hash: "", comments: "", status: "", tags: [])
                    
                    if let reportsRowTitle = reportsRow.at_css(".bt_report_title a") {
                        report.id = Int(String(describing: ((reportsRowTitle["href"]!.split(separator: "&")[1]).split(separator: "=")[1])))!
                        report.title = reportsRowTitle.text!
                    }
                    
                    if let reportsRowInfoDetails = reportsRow.at_css(".bt_report_info_details") {
                        report.date = String(describing: (reportsRowInfoDetails.innerHTML?.split(separator: "<")[0])!)
                        if let commentsRow = reportsRowInfoDetails.at_css("a") {
                            report.comments = commentsRow.text!
                        }
                    }
                    
                    if let reportsRowInfoStatus = reportsRow.at_css(".bt_report_info_status .bt_report_info__value") {
                        report.status = reportsRowInfoStatus.text!.lowercased()
                    }
                    
                    if let reportsRowFav = reportsRow.at_css(".bt_report_fav") {
                        report.hash = (reportsRowFav["onclick"]!).matchingStrings(regex: "(?<=').*(?=')")[0][0]
                    }
                    
                    for reportsRowTag in reportsRow.css(".bt_report_tags .bt_tag_label") {
                        var ids = (reportsRowTag["onclick"]!).matchingStrings(regex: "[0-9]+")[0]
                        
                        if ids.count == 1 {
                            ids.append(ids[0])
                        }
                        
                        let type = (reportsRowTag["onclick"]!).matchingStrings(regex: "(?<=').*(?=')")[0][0]
                        if !(["version", "platform", "platform_version"].contains(type)) {
                            report.tags.append(Tag(id: Int(ids[0])!, type: type, productId: Int(ids[1])!, title: reportsRowTag.text!, size: CGSize(width: 1, height: 17) ))
                        }
                    }
                    
                    loadedReports.append(report)
                }
                
                if (loadedReports.count > 0) {
                    self.minTimestampLast = String(describing: Int(NSDate().timeIntervalSince1970))
                } else {
                    if (self.reportsIsLoaded != 2) {
                        self.reportsIsLoaded += 1
                        self.parseReports(minTimestamp, maxTimestamp, query: query)
                    } else {
                        print("Parsing Error")
                    }
                }
                
                if (query == "") {
                    isSearching = false
                    reports.insert(contentsOf: loadedReports, at: 0)
                } else {
                    isSearching = true
                    
                    if (query == self.lastQuery) {
                        reportsSearching.insert(contentsOf: loadedReports, at: 0)
                    } else {
                        reportsSearching = loadedReports
                    }
                }
                
                self.lastQuery = query
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.5, animations: {
                        self.tableView.alpha = 1
                    })
                    
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
        
        if segue.identifier == "showSelectedReportAlt" {
            let reportAltViewController: ReportAlternativeViewController = segue.destination as! ReportAlternativeViewController
            
            reportAltViewController.keyboardHidden = keyboardShowed
            
            if isSearching {
                reportAltViewController.reportsId = selectedId
                reportAltViewController.reportId = reportsSearching[selectedId!].id
                reportAltViewController.reportTitle = reportsSearching[selectedId!].title
                reportAltViewController.reportBookmarkHash = reportsSearching[selectedId!].hash
            } else {
                reportAltViewController.reportsId = selectedId
                reportAltViewController.reportId = reports[selectedId!].id
                reportAltViewController.reportTitle = reports[selectedId!].title
                reportAltViewController.reportBookmarkHash = reports[selectedId!].hash
            }
        } else if segue.identifier == "showAddReport" {
            return
        }
    }
    
    var data = Array<Array<String>>()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return reportsSearching.count
        } else {
            return reports.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ReportsTableViewCell", owner: self, options: nil)?.first as! ReportsTableViewCell
        
        cell.isSearching = isSearching
        
        if isSearching {
            cell.titleLabel.text = reportsSearching[indexPath.row].title
            cell.dateLabel.text = reportsSearching[indexPath.row].date
            cell.commentLabel.text = reportsSearching[indexPath.row].comments
            cell.statusLabel.text = reportsSearching[indexPath.row].status
        } else {
            cell.titleLabel.text = reports[indexPath.row].title
            cell.dateLabel.text = reports[indexPath.row].date
            cell.commentLabel.text = reports[indexPath.row].comments
            cell.statusLabel.text = reports[indexPath.row].status
        }
        
        cell.item = indexPath.item
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        tableView.isUserInteractionEnabled = false
        
        selectedId = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showSelectedReportAlt", sender: self)
        }
    }
    
    @IBAction func addReportButtonDown(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        addReportButton.isUserInteractionEnabled = false
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showAddReport", sender: self)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.isEmpty)! {
            isSearching = false
            self.tableView.reloadData()
        } else {
            isSearching = true
        }
    }
}
