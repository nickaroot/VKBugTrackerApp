//
//  BugTracker.swift
//  VKBugTrackerApp
//
//  Created by Nick Arut on 08.06.2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit
import Kanna

class BugTracker {
    
    static let domain = URL(string: "https://vk.com/bugtracker")!
    
    struct Error {
        let code: Int
        let description: String
    }
    
    // Error Codes
    // 100 – Request Errors
    // 200 – Parsing Errors
    // 300 – Method Errors
    
    enum Data {
        case requestData(
            html: String,
            timestamp: String
        )
        case parseData(
            reports: [Report]
        )
        case reportsListData(
            reports: [Report]
        )
    }
    
    struct Response {
        let success: Bool
        let error: Error?
        let data: Data?
    }
    
    final class ReportsList {
        
        var maxTimestamp = ""
        var minTimestamp = ""
        var query = ""
        
        func requestReports(min: String, max: String, completion: @escaping (_ response: Response) -> Void) {
            
            var request = URLRequest(url: domain)
            
            request.httpMethod = "POST"
            
            let postString = "al=1&load=1&min_udate=\(min)&max_udate=\(max)&q=\(self.query)"
            
            
            request.httpBody = postString.data(using: .utf8)
            request.addValue("XMLHttpRequest", forHTTPHeaderField: "x-requested-with")
            
            (URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                guard let data = data, error == nil else {
                    completion(Response(success: false, error: Error(code: 100, description: error.debugDescription), data: nil))
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    completion(Response(success: false, error: Error(code: 101, description: "HTTP Status Code is \(httpStatus.statusCode)"), data: nil))
                    return
                }
                
                let responseString = String(data: data, encoding: .windowsCP1251)!
                
                let timestampRegexed = responseString.matchingStrings(regex: "[0-9]+$")
                
                var timestampParsed: String!
                
                if timestampRegexed.count > 0 {
                    timestampParsed = String(Int(timestampRegexed[0][0])! - 1)
                } else {
                    completion(Response(success: false, error: Error(code: 102, description: "Can't Parse Timestamp\n\(responseString)"), data: nil))
                    return
                }
                
                if timestampParsed == "-1" {
                    completion(Response(success: false, error: Error(code: 103, description: "No More Reports to Load"), data: nil))
                    return
                }
                
                completion(Response(success: true, error: nil, data: .requestData(html: responseString, timestamp: timestampParsed)))
                return
                
            }).resume()
                
        }
        
        func parseReports(html: String!, completion: @escaping (_ response: Response) -> Void) {
            
            var loadedReports = [Report]()
            
            do {
                
                let doc = try HTML(html: html, encoding: .windowsCP1251)
                
                for reportsRow in doc.css(".bt_report_row") {
                    var report = Report()
                    
                    if let reportsRowTitle = reportsRow.at_css(".bt_report_title a") {
                        report.id = Int(String(describing: ((reportsRowTitle["href"]!.split(separator: "&")[1]).split(separator: "=")[1])))!
                        report.title = reportsRowTitle.text!
                    }
                    
                    if let reportsRowInfoDetails = reportsRow.at_css(".bt_report_info_details") {
                        report.date = String(describing: (reportsRowInfoDetails.innerHTML?.split(separator: "<")[0])!)
                        if let authorRow = reportsRowInfoDetails.at_css("a") {
//                            report.comments = commentsRow.text!.matchingStrings(regex: "[0-9]+")[0][0]
                            report.author = authorRow.text!
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
                        
                        if !(["product"].contains(type)) {
                            report.tags.append(Tag(id: Int(ids[0])!, type: type, productId: Int(ids[1])!, title: reportsRowTag.text!, size: CGSize(width: 1, height: 17)))
                        } else if type == "product" {
                            report.product = Tag(id: Int(ids[0])!, type: type, productId: Int(ids[1])!, title: reportsRowTag.text!, size: CGSize(width: 1, height: 17))
                        }
                        
                    }
                    
                    loadedReports.append(report)
                }
                
                if (loadedReports.count > 0) {
                    completion(Response(success: true, error: nil, data: .parseData(reports: loadedReports)))
                    return
                } else {
                    completion(Response(success: false, error: Error(code: 201, description: "Parsed Reports List is Empty"), data: nil))
                    return
                }
                
            } catch {
                completion(Response(success: false, error: Error(code: 200, description: "Parsing Error"), data: nil))
                return
            }
            
        }
        
        func updateReports(completion: @escaping (_ response: Response) -> Void) {
            
            self.requestReports(min: minTimestamp, max: "") { (requestResponse) in
                
                if requestResponse.success {
                    
                    if case .requestData(let html, _)? = requestResponse.data {
                        
                        self.parseReports(html: html, completion: { (parseResponse) in
                            
                            if parseResponse.success {
                                
                                self.minTimestamp = String(describing: Int(NSDate().timeIntervalSince1970))
                                
                                if case .parseData(let reports)? = parseResponse.data {
                                    completion(Response(success: true, error: nil, data: .reportsListData(reports: reports)))
                                    return
                                }
                                
                            } else {
                                completion(parseResponse)
                                return
                            }
                            
                        })
                        
                    }
                    
                } else {
                    completion(requestResponse)
                    return
                }
                
            }
            
        }
        
        func loadMoreReports(completion: @escaping (_ response: Response) -> Void) {
            
            self.requestReports(min: "", max: self.maxTimestamp) { (requestResponse) in
                
                if requestResponse.success {
                    
                    if case .requestData(let html, let timestamp)? = requestResponse.data {
                        
                        print(timestamp)
                        print(self.maxTimestamp)
                        print("---")
                        
                        if timestamp != self.maxTimestamp {
                            
                            self.maxTimestamp = timestamp
                            
                            self.parseReports(html: html, completion: { (parseResponse) in
                                
                                if parseResponse.success {
                                    
                                    if case .parseData(let reports)? = parseResponse.data {
                                        completion(Response(success: true, error: nil, data: .reportsListData(reports: reports)))
                                        return
                                    }
                                    
                                } else {
                                    completion(parseResponse)
                                    return
                                }
                                
                            })
                            
                        } else {
                            completion(Response(success: false, error: Error(code: 300, description: "Parsed Timestamp and Last Timestamp is Equal"), data: nil))
                            return
                        }
                        
                    }
                    
                } else {
                    completion(requestResponse)
                    return
                }
                
            }
            
        }
        
        init(query: String, completion: @escaping (_ response: Response) -> Void) {
            
            reports = [
                
                Report(id: 0, title: "Не обновляются проголосовавшие в опросе в личке после его редактирования", date: "сегодня в 22:30", hash: "6ab310b2e6a54fdb34", comments: "3", author: "Динар Хайруллин", status: Status(style: .open, title: "Открыт"), product: Tag(id: 20, type: "product", productId: 20, title: "VK для iPhone", size: CGSize(width: 1, height: 1)), tags: [
                        Tag(id: 113, type: "tag", productId: 20, title: "Беседы", size: CGSize(width: 1, height: 1)),
                        Tag(id: 187, type: "tag", productId: 20, title: "API", size: CGSize(width: 1, height: 1))
                    ]),
                
                Report(id: 0, title: "Текст сообщения остаётся в поле ввода после определённых действий", date: "сегодня в 16:42", hash: "2410438999e6a5d433", comments: "3", author: "Иван Лосев", status: Status(style: .open, title: "Открыт"), product: Tag(id: 1, type: "product", productId: 1, title: "VK Messenger", size: CGSize(width: 1, height: 1)), tags: [
                    Tag(id: 11, type: "tag", productId: 1, title: "Стикеры", size: CGSize(width: 1, height: 1)),
                    Tag(id: 96, type: "tag", productId: 1, title: "Сообщения сообществ", size: CGSize(width: 1, height: 1)),
                    Tag(id: 4, type: "tag", productId: 1, title: "Сообщения", size: CGSize(width: 1, height: 1))
                    ])
            
            ]
            
            #if targetEnvironment(simulator)
            completion(Response(success: true, error: nil, data: .reportsListData(reports: reports))) // TEST ONLY
            #endif
            
            self.query = query
            
            self.requestReports(min: minTimestamp, max: maxTimestamp) { (requestResponse) in
                
                if requestResponse.success {
                    
                    if case .requestData(let html, let timestamp)? = requestResponse.data {
                        
                        self.parseReports(html: html, completion: { (parseResponse) in
                            
                            if parseResponse.success {
                                
                                if case .parseData(let reports)? = parseResponse.data {
                                    self.maxTimestamp = timestamp
                                    completion(Response(success: true, error: nil, data: .reportsListData(reports: reports)))
                                    return
                                }
                                
                            } else {
                                completion(parseResponse)
                                return
                            }
                            
                        })
                    
                        
                    }
                    
                } else {
                    completion(requestResponse)
                    return
                }
                
            }
            
        }
        
    }
}
