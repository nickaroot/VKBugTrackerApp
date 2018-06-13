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
        infiniteControl: UIActivityIndicatorView!,
        timer: Timer!,
        minTimestampLast = "",
        maxTimestampLast = "",
        searchingMinTimestampLast = "",
        searchingMaxTimestampLast = "",
        lastQuery = "",
        keyboardShowed = false,
        reportsIsLoaded = 0,
        cellHeight: CGFloat = 79,
        cellBuffer: CGFloat = 2,
        loadInProgress = false,
        tableHeight = 0
    
    var reportsList: BugTracker.ReportsList?,
        reportsListSearching: BugTracker.ReportsList?
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.shouldRemoveShadow(true)
//        self.edgesForExtendedLayout = .bottom
        tableView.alpha = 0
        view.backgroundColor = .white
        self.tableView.rowHeight = cellHeight
        
        tableHeight = Int(tableView.frame.size.height)
        
        refreshControl = UIRefreshControl()
        
        refreshControl.backgroundColor = .vkBlue
        refreshControl.tintColor = .white
        
        infiniteControl = UIActivityIndicatorView(activityIndicatorStyle: .white)
        infiniteControl.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 44)
        
        infiniteControl.backgroundColor = .vkBlue
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        tableView.tableFooterView = infiniteControl
        
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
//            self.parseReports(self.minTimestampLast, "", query: "")
            self.getReportsList(.update)
        }
        keyboardShowed = false
    }
    
    @IBAction func searchBarPrimaryAction(_ sender: Any) {
//        self.searchingMaxTimestampLast = ""
//        self.parseReports("", "", query: searchField.text!)
        
        isSearching = true
        getReportsListSearching(.init, query: searchField.text!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.isUserInteractionEnabled = true
        addReportButton.isUserInteractionEnabled = true
        
        self.tabBarController?.tabBar.clipsToBounds = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        DispatchQueue.main.async {
            if (isSearching) {
//                self.parseReports(self.searchingMinTimestampLast, "", query: self.searchField.text!)
                
                self.getReportsListSearching(.update, query: nil)
                
            } else {
//                self.parseReports(self.minTimestampLast, "", query: "")
                
                self.reportsList == nil ? self.getReportsList(.init) : self.getReportsList(.update)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
//            parseReports(minTimestampLast, "", query: lastQuery)
            
            isSearching ? getReportsListSearching(.update, query: nil) : getReportsList(.update)
            
            timer = Timer.scheduledTimer(timeInterval: 2, target: self,   selector: (#selector(ReportsViewController.refreshControlEndRefreshing)), userInfo: nil, repeats: true)
        }
    }
    
    func parseReports(_ minTimestamp: String, _ maxTimestamp: String, query: String) {
        
        var loadedReports = [Report]()
        
        var request = URLRequest(url: URL(string: "https://vk.com/bugtracker")!)
        request.httpMethod = "POST"
        let postString = "al=1&load=1&min_udate=\(minTimestamp)&max_udate=\(maxTimestamp)&q=\(query)"
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
//            print(responseString)
            
            var maxTimestampParsed = ""
            
            let maxTimestampRegexed = responseString?.matchingStrings(regex: "[0-9]+$")
            
            if maxTimestampRegexed!.count > 0 {
                maxTimestampParsed = String(Int(maxTimestampRegexed![0][0])! - 1)
            }
            
            if (maxTimestampParsed != self.maxTimestampLast && query == "") || (maxTimestampParsed != self.searchingMaxTimestampLast && query != "") {
                
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
                                report.comments = commentsRow.text!.matchingStrings(regex: "[0-9]+")[0][0]
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
    //                    if (self.reportsIsLoaded != 2) {
    //                        self.reportsIsLoaded += 1
    //                        self.parseReports(minTimestamp, maxTimestamp, query: query)
    //                    } else {
    //                        print("Parsing Error")
    //                    }
                    }
                    
                    if (maxTimestamp == "") {
                        if (query == "") { // Not searching
                            isSearching = false
                            
                            self.maxTimestampLast = maxTimestampParsed
                            
                            reports.insert(contentsOf: loadedReports, at: 0)
                            
                            if self.isCellsFitsTableView(r: reports) {
                                self.tableView.backgroundColor = .vkBlue
                            } else {
                                self.tableView.backgroundColor = .white
                            }
                        } else { // Searching
                            isSearching = true
                            
                            if (query == self.lastQuery) { // Same Search
                                
                                self.searchingMaxTimestampLast = maxTimestampParsed
                                
                                print(self.searchingMaxTimestampLast)
                                
                                if maxTimestamp == "" { // Refresh
                                    reportsSearching.insert(contentsOf: loadedReports, at: 0)
                                } else { // Infinite Scrolling
                                    reportsSearching.append(contentsOf: loadedReports)
                                }
                            } else { // New Search
                                reportsSearching = loadedReports
                            }
                            
                            if self.isCellsFitsTableView(r: reportsSearching) {
                                self.tableView.backgroundColor = .vkBlue
                            } else {
                                self.tableView.backgroundColor = .white
                            }
                        }
                    } else {
                        reports.append(contentsOf: loadedReports)
                    }
                    
                    self.lastQuery = query
                    
                    DispatchQueue.main.async {
                        
                        if (loadedReports.count > 0) {
                            self.tableView.reloadData()
                        }
                        
                        self.loadInProgress = false
                        self.infiniteControl.stopAnimating()
                        self.activityIndicator.stopAnimating()
                        UIView.animate(withDuration: 0.5, animations: {
                            self.tableView.alpha = 1
                        })
                    }
                    
                } catch {
                    print("Parsing Error")
                }
                
            } else {
                DispatchQueue.main.async {
                    self.infiniteControl.backgroundColor = .white
                }
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
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ReportsTableViewCell", owner: self, options: nil)?.first as! ReportsTableViewCell
        
        cell.isSearching = isSearching
        
        if isSearching {
            cell.titleLabel.text = reportsSearching[indexPath.row].title
//            cell.dateLabel.text = reportsSearching[indexPath.row].date
            cell.commentLabel.text = reportsSearching[indexPath.row].comments
        } else {
            cell.titleLabel.text = reports[indexPath.row].title
//            cell.dateLabel.text = reports[indexPath.row].date
            cell.commentLabel.text = reports[indexPath.row].comments
        }
        
        cell.item = indexPath.item
        cell.selectionStyle = .none
        
        cell.titleLabel.sizeToFitHeight()
        
        let titleHeight = cell.titleLabel.frame.size.height //20 * (cell.titleLabel.frame.size.height / 20.3333333333333)
        cellHeight = 14 + titleHeight + 10 + cell.tagsCollection.layer.frame.size.height + 14 + 7
        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let top: CGFloat = 0
        let bottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
        let buffer: CGFloat = self.cellBuffer * self.cellHeight
        let scrollPosition = scrollView.contentOffset.y
        
        if (scrollPosition > bottom - buffer) && !loadInProgress {
            loadInProgress = true
            infiniteControl.startAnimating()
            
            self.infiniteControl.backgroundColor = .vkBlue
            
//            if !isSearching {
//                parseReports("", maxTimestampLast, query: lastQuery)
//            } else {
//                parseReports("", searchingMaxTimestampLast, query: lastQuery)
//            }
            
            isSearching ? getReportsListSearching(.infinite, query: nil) : getReportsList(.infinite)
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
    
    func isCellsFitsTableView(r: [Report]) -> Bool {
        return (r.count * Int(cellHeight) >= tableHeight)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.isEmpty)! {
            isSearching = false
            self.tableView.reloadData()
        } else {
            isSearching = true
        }
    }
    
    ////////
    //////
    ////
    //
    
    enum reportsListAction {
        case `init`
        case update
        case infinite
    }
    
    func getReportsList(_ action: reportsListAction) {
        switch action {
        case .init:
            self.reportsList = BugTracker.ReportsList(query: "", completion: { (response) in
                
                if response.success {
                    
                    if case .reportsListData(let loadedReports)? = response.data {
                        
                        reports.insert(contentsOf: loadedReports, at: 0)
                        
                        if self.isCellsFitsTableView(r: reports) {
                            self.tableView.backgroundColor = .vkBlue
                        } else {
                            self.tableView.backgroundColor = .white
                        }
                        
                        self.reportsTableReload()
                        
                    }
                    
                } else {
                    
                    print(response.error!.description)
                    
                }
                
            })
            
        case .update:
            self.reportsList?.updateReports(completion: { (response) in
                
                if response.success {
                    
                    if case .reportsListData(let loadedReports)? = response.data {
                        
                        reports.insert(contentsOf: loadedReports, at: 0)
                        
                        if self.isCellsFitsTableView(r: reports) {
                            self.tableView.backgroundColor = .vkBlue
                        } else {
                            self.tableView.backgroundColor = .white
                        }
                        
                        self.reportsTableReload()
                        
                    }
                    
                } else {
                    
                    print(response.error!.description)
                    
                }
                
            })
            
        case .infinite:
            self.reportsList?.loadMoreReports(completion: { (response) in
                
                if response.success {
                    
                    if case .reportsListData(let loadedReports)? = response.data {
                        
                        reports.append(contentsOf: loadedReports)
                        
                        if self.isCellsFitsTableView(r: reports) {
                            self.tableView.backgroundColor = .vkBlue
                        } else {
                            self.tableView.backgroundColor = .white
                        }
                        
                        self.reportsTableReload()
                        
                    }
                    
                } else {
                    
                    if response.error?.code == 103 {
                        DispatchQueue.main.async {
                            self.loadInProgress = false
                            self.infiniteControl.stopAnimating()
                        }
                    } else {
                        print(response.error!.description)
                    }
                    
                }
                
            })
        }
    }
    
    func getReportsListSearching(_ action: reportsListAction, query: String?) {
        switch action {
        case .init:
            self.reportsListSearching = BugTracker.ReportsList(query: query!, completion: { (response) in
                
                if response.success {
                    
                    if case .reportsListData(let loadedReports)? = response.data {
                        
                        reportsSearching.insert(contentsOf: loadedReports, at: 0)
                        
                        if self.isCellsFitsTableView(r: reportsSearching) {
                            self.tableView.backgroundColor = .vkBlue
                        } else {
                            self.tableView.backgroundColor = .white
                        }
                        
                        self.reportsTableReload()
                        
                    }
                    
                } else {
                    
                    print(response.error!.description)
                    
                }
                
            })
            
        case .update:
            self.reportsListSearching?.updateReports(completion: { (response) in
                
                if response.success {
                    
                    if case .reportsListData(let loadedReports)? = response.data {
                        
                        reportsSearching.insert(contentsOf: loadedReports, at: 0)
                        
                        if self.isCellsFitsTableView(r: reportsSearching) {
                            self.tableView.backgroundColor = .vkBlue
                        } else {
                            self.tableView.backgroundColor = .white
                        }
                        
                        self.reportsTableReload()
                        
                    }
                    
                } else {
                    
                    print(response.error!.description)
                    
                }
                
            })
            
        case .infinite:
            self.reportsListSearching?.loadMoreReports(completion: { (response) in
                
                if response.success {
                    
                    if case .reportsListData(let loadedReports)? = response.data {
                        
                        reportsSearching.append(contentsOf: loadedReports)
                        
                        if self.isCellsFitsTableView(r: reportsSearching) {
                            self.tableView.backgroundColor = .vkBlue
                        } else {
                            self.tableView.backgroundColor = .white
                        }
                        
                        self.reportsTableReload()
                        
                    }
                    
                } else {
                    
                    print(response.error!.description)
                    
                }
                
            })
        }
    }
    
    func reportsTableReload() {
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            
            self.loadInProgress = false
            self.infiniteControl.stopAnimating()
            self.activityIndicator.stopAnimating()
            UIView.animate(withDuration: 0.5, animations: {
                self.tableView.alpha = 1
            })
        }
    }
}
