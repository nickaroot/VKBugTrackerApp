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
        view.backgroundColor = .grayBg
        self.tableView.rowHeight = cellHeight
        
        tableHeight = Int(tableView.frame.size.height)
        
        refreshControl = UIRefreshControl()
        
        refreshControl.backgroundColor = .grayBg
        refreshControl.tintColor = .white
        
        infiniteControl = UIActivityIndicatorView(activityIndicatorStyle: .white)
        infiniteControl.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 44)
        
        infiniteControl.backgroundColor = .grayBg
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        tableView.tableFooterView = infiniteControl
        
        customizeSearchBar()
        
        productsAvatars[0] = UIImage(named: "product_0")
        productsAvatars[1] = UIImage(named: "product_1")
        productsAvatars[3] = UIImage(named: "product_3")
        productsAvatars[15] = UIImage(named: "product_15")
        productsAvatars[20] = UIImage(named: "product_20")
        productsAvatars[22] = UIImage(named: "product_22")
        productsAvatars[32] = UIImage(named: "product_32")
        productsAvatars[50] = UIImage(named: "product_50")
        productsAvatars[60] = UIImage(named: "product_60")
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
            
            timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: (#selector(ReportsViewController.refreshControlEndRefreshing)), userInfo: nil, repeats: true)
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
                        var report = Report(id: 0, title: "", date: "", hash: "", comments: "", status: nil, tags: [])
                        
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
                            report.status = Status(style: .open, title: reportsRowInfoStatus.text!.lowercased())
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
                            
//                            if self.isCellsFitsTableView(r: reports) {
//                                self.tableView.backgroundColor = .vkBlue
//                            } else {
//                                self.tableView.backgroundColor = .white
//                            }
                            
                            self.tableView.backgroundColor = .grayBg
                            
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
                            
//                            if self.isCellsFitsTableView(r: reportsSearching) {
//                                self.tableView.backgroundColor = .vkBlue
//                            } else {
//                                self.tableView.backgroundColor = .white
//                            }
                            
                            self.tableView.backgroundColor = .grayBg
                            
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
                    self.infiniteControl.backgroundColor = .grayBg
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
        
//        let cell = Bundle.main.loadNibNamed("ReportsTableViewCell", owner: self, options: nil)?.first as! ReportsTableViewCell
//
//        cell.isSearching = isSearching
//
//        if isSearching {
//            cell.titleLabel.text = reportsSearching[indexPath.row].title
//            cell.dateLabel.text = reportsSearching[indexPath.row].date
//            cell.commentLabel.text = reportsSearching[indexPath.row].comments
//
//            if productsAvatars[reports[indexPath.row].product!.id] != nil {
//                cell.productAvatarView.image = productsAvatars[reportsSearching[indexPath.row].product!.id]!
//            } else {
//                cell.productAvatarView.image = productsAvatars[0]!
//            }
//
//            cell.productTitleLabel.text = reportsSearching[indexPath.row].product?.title
//            cell.authorLabel.text = reportsSearching[indexPath.row].author
//            cell.statusLabel.text = reportsSearching[indexPath.row].status?.title
//
//            switch (reportsSearching[indexPath.row].status?.style) {
//                case .open?:
//                    cell.statusIndicator.backgroundColor = UIColor.green
//                    break
//                case .closed?:
//                    cell.statusIndicator.backgroundColor = UIColor.red
//                    break
//                case .none:
//                    break
//            }
//
//        } else {
//            cell.titleLabel.text = reports[indexPath.row].title
//            cell.dateLabel.text = reports[indexPath.row].date
//            cell.commentLabel.text = reports[indexPath.row].comments
//
//            if productsAvatars[reports[indexPath.row].product!.id] != nil {
//                cell.productAvatarView.image = productsAvatars[reports[indexPath.row].product!.id]!
//            } else {
//                cell.productAvatarView.image = productsAvatars[0]!
//            }
//
//            cell.productTitleLabel.text = reports[indexPath.row].product?.title
//            cell.authorLabel.text = reports[indexPath.row].author
//        }
//
//        cell.item = indexPath.item
//        cell.selectionStyle = .none
//        let width = UIScreen.main.bounds.size.width - 41
//        let height = cell.titleLabel.text!.height(withConstrainedWidth: width, font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular))
//        let productAvatarHeight = cell.productAvatarView.layer.frame.size.height
//        let tagsCollectionHeight = cell.tagsCollection.layer.frame.size.height
//        let dateLabelHeight = cell.dateLabel.layer.frame.size.height
//
//        let titleHeight = height
//
//        cellHeight = titleHeight + 145
        
        // TEST
        
        let screenWidth = UIScreen.main.bounds.size.width
        
        if indexPath.item == 0 {
            let titleCell = UITableViewCell()
            titleCell.frame.size = CGSize(width: screenWidth, height: 42)
            titleCell.backgroundColor = UIColor(red: 0.906, green: 0.910, blue: 0.925, alpha: 1)
            
            let titleLabel = UILabel()
            titleCell.addSubview(titleLabel)
            
            titleLabel.frame.size = CGSize(width: 100, height: 20)
            titleLabel.frame.origin = CGPoint(x: 12, y: 14)
            titleLabel.text = "Салус"
            titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            titleLabel.textColor = .black
            
            cellHeight = titleCell.frame.size.height
            
            return titleCell
        }
        
        let text = "Не обновляются проголосовавшие в опросе в личке после его редактирования"
        
        let textWidth = screenWidth - 41
        let textHeight = text.height(withConstrainedWidth: textWidth, font: UIFont.systemFont(ofSize: 15, weight: .regular))
        var frameHeight = CGFloat(0)
        let leftOffset = CGFloat(12)
        
        let frameCell = UITableViewCell()
        
        frameCell.selectionStyle = .none
        frameCell.backgroundColor = UIColor(red: 0.906, green: 0.910, blue: 0.925, alpha: 1)

        let roundedView = UIView()
        let roundedViewMargin = CGFloat(6)
        frameCell.addSubview(roundedView)
        frameHeight += roundedViewMargin
        
        roundedView.frame.origin = CGPoint(x: 7, y: frameHeight)
        roundedView.backgroundColor = UIColor.white
        roundedView.layer.cornerRadius = 10
        frameCell.layer.masksToBounds = true
        
        let avatarView = UIImageView()
        let avatarViewHeight = CGFloat(30)
        let avatarViewTopMargin = CGFloat(6)
        roundedView.addSubview(avatarView)
        frameHeight += avatarViewTopMargin
        
        let productAvatar = #imageLiteral(resourceName: "product_20")
        avatarView.frame.size = CGSize(width: 30, height: avatarViewHeight)
        avatarView.frame.origin = CGPoint(x: leftOffset, y: frameHeight)
        avatarView.image = productAvatar
        avatarView.backgroundColor = UIColor(red: 0.906, green: 0.910, blue: 0.925, alpha: 1)
        avatarView.layer.cornerRadius = 15
        avatarView.layer.masksToBounds = true
        
        frameHeight += avatarViewHeight
        
        let productLabel = UILabel()
        roundedView.addSubview(productLabel)
        
        let productText = "VK для iPhone"
        productLabel.frame.size = CGSize(width: productText.width(withConstrainedHeight: 17, font: .systemFont(ofSize: 14)), height: 17)
        productLabel.frame.origin = CGPoint(x: leftOffset + avatarViewHeight + 7, y: (avatarViewHeight + avatarViewTopMargin) / 2)
        productLabel.text = productText
        productLabel.font = .systemFont(ofSize: 14)
        productLabel.textColor = .black
        
        let favoriteButton = UIButton()
        roundedView.addSubview(favoriteButton)
        
        favoriteButton.frame.size = CGSize(width: 78, height: 27)
        favoriteButton.frame.origin = CGPoint(x: screenWidth - 78 - 7 - 19, y: 13)
        favoriteButton.setTitle("В закладки", for: .normal)
        favoriteButton.setTitleColor(UIColor(red: 0.322, green: 0.545, blue: 0.816, alpha: 1), for: .normal)
        favoriteButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        let titleLabel = UILabel()
        let titleLabelTopMargin = CGFloat(8)
        roundedView.addSubview(titleLabel)
        frameHeight += titleLabelTopMargin
        
        titleLabel.frame.size = CGSize(width: textWidth, height: textHeight)
        titleLabel.frame.origin = CGPoint(x: leftOffset + 1, y: frameHeight)
        titleLabel.text = text
        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(ofSize: 15)
        titleLabel.textColor = .black
        titleLabel.frame.size.height = titleLabel.setLineHeight(lineHeight: 3, labelWidth: titleLabel.frame.size.width)
        
        frameHeight += titleLabel.frame.size.height
        
        let collectionView = UIView()
        let collectionViewHeight = CGFloat(21)
        let collectionViewTopMargin = CGFloat(14)
//        roundedView.addSubview(collectionView)
        frameHeight += collectionViewTopMargin
        
        collectionView.frame.size = CGSize(width: screenWidth - 68, height: collectionViewHeight)
        collectionView.frame.origin = CGPoint(x: leftOffset, y: frameHeight)
        collectionView.backgroundColor = UIColor(red: 0.906, green: 0.910, blue: 0.925, alpha: 1)
        
        let collectionViewLabel1 = UILabel()
        roundedView.addSubview(collectionViewLabel1)
        
        let tagText1 = "Музыка"
        collectionViewLabel1.frame.size = CGSize(width: 16 + tagText1.width(withConstrainedHeight: collectionViewHeight - 1, font: .systemFont(ofSize: 10)), height: collectionViewHeight - 1)
        collectionViewLabel1.frame.origin = CGPoint(x: leftOffset, y: frameHeight)
        collectionViewLabel1.text = tagText1
        collectionViewLabel1.textAlignment = .center
        collectionViewLabel1.textColor = UIColor(red: 0.333, green: 0.404, blue: 0.490, alpha: 1)
        collectionViewLabel1.font = .systemFont(ofSize: 10)
        collectionViewLabel1.backgroundColor = UIColor(red: 0.898, green: 0.922, blue: 0.945, alpha: 1)
        collectionViewLabel1.layer.cornerRadius = 10
        collectionViewLabel1.layer.masksToBounds = true
        
        let collectionViewLabel2 = UILabel()
        roundedView.addSubview(collectionViewLabel2)
        
        let tagText2 = "API"
        collectionViewLabel2.frame.size = CGSize(width: (16 + tagText2.width(withConstrainedHeight: collectionViewHeight - 1, font: .systemFont(ofSize: 10))), height: collectionViewHeight - 1)
        collectionViewLabel2.frame.origin = CGPoint(x: (16 + tagText1.width(withConstrainedHeight: collectionViewHeight - 1, font: .systemFont(ofSize: 10))) + 8 + leftOffset, y: frameHeight)
        collectionViewLabel2.text = tagText2
        collectionViewLabel2.textAlignment = .center
        collectionViewLabel2.textColor = UIColor(red: 0.333, green: 0.404, blue: 0.490, alpha: 1)
        collectionViewLabel2.font = .systemFont(ofSize: 10)
        collectionViewLabel2.backgroundColor = UIColor(red: 0.898, green: 0.922, blue: 0.945, alpha: 1)
        collectionViewLabel2.layer.cornerRadius = 10
        collectionViewLabel2.layer.masksToBounds = true
        
        let commentLabel = LabelPadding()
        roundedView.addSubview(commentLabel)
        
        let commentsCount = "2"
        commentLabel.frame.size = CGSize(width: 20, height: collectionViewHeight - 1)
        commentLabel.frame.origin = CGPoint(x: screenWidth - 48, y: frameHeight)
        commentLabel.text = commentsCount
        commentLabel.font = .systemFont(ofSize: 12)
        commentLabel.textAlignment = .center
        commentLabel.textColor = UIColor(red: 0.361, green: 0.565, blue: 0.780, alpha: 1)
        commentLabel.topInset = 0
        commentLabel.bottomInset = 0
        commentLabel.leftInset = 5
        commentLabel.rightInset = 5
        commentLabel.rounded = true
        commentLabel.backgroundColor = UIColor(red: 0.937, green: 0.937, blue: 0.957, alpha: 1)
        
        frameHeight += collectionViewHeight
        
        let separatorView = UIView()
        let separatorViewHeight = CGFloat(1)
        let separatorViewTopMargin = CGFloat(9)
        roundedView.addSubview(separatorView)
        frameHeight += separatorViewTopMargin
        
        separatorView.frame.size = CGSize(width: screenWidth - 40, height: separatorViewHeight)
        separatorView.frame.origin = CGPoint(x: leftOffset + 1, y: frameHeight)
        separatorView.backgroundColor = UIColor(white: 0.929, alpha: 1)
        
        frameHeight += separatorViewHeight
        
        let dateLabel = UILabel()
        let dateLabelHeight = CGFloat(14)
        let dateLabelTopMargin = CGFloat(14)
        let dateLabelBottomMargin = CGFloat(20)
        roundedView.addSubview(dateLabel)
        frameHeight += dateLabelTopMargin
        
        let dateText = "сегодня, в 22:30"
        dateLabel.frame.size = CGSize(width: dateText.width(withConstrainedHeight: 14, font: .systemFont(ofSize: 11, weight: .medium)), height: dateLabelHeight)
        dateLabel.frame.origin = CGPoint(x: leftOffset + 4, y: frameHeight)
        dateLabel.text = dateText
        dateLabel.textColor = UIColor(white: 0.847, alpha: 1)
        dateLabel.font = .systemFont(ofSize: 11, weight: .medium)
        
        let authorLabel = UILabel()
        let authorLabelHeight = CGFloat(14)
        roundedView.addSubview(authorLabel)
        
        let authorText = "Динар Хайруллин"
        authorLabel.frame.size = CGSize(width: authorText.width(withConstrainedHeight: authorLabelHeight, font: .systemFont(ofSize: 11)), height: authorLabelHeight)
        authorLabel.frame.origin = CGPoint(x: screenWidth / 2 - authorLabel.frame.size.width / 2, y: frameHeight)
        authorLabel.text = authorText
        authorLabel.textColor = UIColor(red: 0.608, green: 0.608, blue: 0.616, alpha: 1)
        authorLabel.font = .systemFont(ofSize: 11)
        
        let statusIndicatorView = UIView()
        let statusIndicatorViewHeight = CGFloat(5)
        roundedView.addSubview(statusIndicatorView)
        
        statusIndicatorView.frame.size = CGSize(width: statusIndicatorViewHeight, height: statusIndicatorViewHeight)
        statusIndicatorView.frame.origin = CGPoint(x: screenWidth - 28 - statusIndicatorViewHeight, y: frameHeight + 5)
        statusIndicatorView.backgroundColor = UIColor(red: 0.102, green: 0.824, blue: 0.153, alpha: 1)
        statusIndicatorView.layer.cornerRadius = statusIndicatorViewHeight / 2
        
        let statusLabel = UILabel()
        let statusLabelHeight = CGFloat(14)
        roundedView.addSubview(statusLabel)
        
        let statusText = "Открыт"
        statusLabel.frame.size = CGSize(width: statusText.width(withConstrainedHeight: statusLabelHeight, font: .systemFont(ofSize: 11, weight: .medium)), height: statusLabelHeight)
        statusLabel.frame.origin = CGPoint(x: statusIndicatorView.frame.origin.x - statusLabel.frame.size.width - 4, y: frameHeight)
        statusLabel.text = statusText
        statusLabel.textColor = UIColor(red: 0.102, green: 0.824, blue: 0.153, alpha: 1)
        statusLabel.font = .systemFont(ofSize: 11, weight: .medium)
        
        frameHeight += dateLabelHeight
        frameHeight += dateLabelBottomMargin
        
        frameHeight += roundedViewMargin
        
        roundedView.frame.size = CGSize(width: screenWidth - 14, height: frameHeight - roundedViewMargin * 2)
        frameCell.frame.size = CGSize(width: screenWidth - 14, height: frameHeight)
        
        cellHeight = frameHeight
        
        return frameCell
        
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
            
            self.infiniteControl.backgroundColor = .grayBg
            
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
                        
//                        if self.isCellsFitsTableView(r: reports) {
//                            self.tableView.backgroundColor = .vkBlue
//                        } else {
//                            self.tableView.backgroundColor = .white
//                        }
                        
                        self.tableView.backgroundColor = .grayBg
                        
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
                        
//                        if self.isCellsFitsTableView(r: reports) {
//                            self.tableView.backgroundColor = .vkBlue
//                        } else {
//                            self.tableView.backgroundColor = .white
//                        }
                        
                        self.tableView.backgroundColor = .grayBg
                        
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
                        
//                        if self.isCellsFitsTableView(r: reports) {
//                            self.tableView.backgroundColor = .vkBlue
//                        } else {
//                            self.tableView.backgroundColor = .white
//                        }

                        self.tableView.backgroundColor = .grayBg
                        
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
                        
//                        if self.isCellsFitsTableView(r: reportsSearching) {
//                            self.tableView.backgroundColor = .vkBlue
//                        } else {
//                            self.tableView.backgroundColor = .white
//                        }
                        
                        self.tableView.backgroundColor = .grayBg
                        
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
                        
//                        if self.isCellsFitsTableView(r: reportsSearching) {
//                            self.tableView.backgroundColor = .vkBlue
//                        } else {
//                            self.tableView.backgroundColor = .white
//                        }
                        
                        self.tableView.backgroundColor = .grayBg
                        
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
                        
//                        if self.isCellsFitsTableView(r: reportsSearching) {
//                            self.tableView.backgroundColor = .vkBlue
//                        } else {
//                            self.tableView.backgroundColor = .white
//                        }
                        
                        self.tableView.backgroundColor = .grayBg
                        
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
