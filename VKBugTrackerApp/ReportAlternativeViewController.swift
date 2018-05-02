//
//  ReportAlternativeViewController.swift
//  VKBugTracker
//
//  Created by Nick Aroot on 07/03/2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit
import WebKit
import Kanna

class ReportAlternativeViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentBackgroundView: UIView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var reportTitle: String?,
        reportId: Int?,
        reportCommentHash: String?,
        reportsId: Int?,
        reportBookmarkHash: String?,
        bookmark = false,
        reportEditHash: String?,
        keyboardHidden = false,
        keyboardShowed = false,
        timer: Timer!,
        refreshControl: UIRefreshControl!
    
    var reportDescription: String?,
        reportAuthor: String?,
        reportDate: String?,
        imageUrl: URL!,
        reportAttachments = [ReportAttachment](),
        reportComments = [ReportComment](),
        reportInfo = [ReportInfo](),
        currentAuthorId: String?,
        error = false
    
    var currentCellHeight = CGFloat(),
        keyboardSize: CGSize?,
        currentSelectedCommentId: Int?
    
    let staticRowsOffset = 3
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportComments.count + reportInfo.count + staticRowsOffset
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (error) {
            
            if isSearching {
                reportsSearching.remove(at: reportsId!)
            } else {
                reports.remove(at: reportsId!)
            }
            
            let alert = UIAlertController(title: "Ошибка", message: "Отчет удален", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (alertAction) in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            
            present(alert, animated: true)
            
            let cell = UITableViewCell()
            
            currentCellHeight = 0
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
            
            return cell
            
        } else {
            if (indexPath.item == 0) {
                let cell = Bundle.main.loadNibNamed("ReportContentTableViewCell", owner: self, options: nil)?.first as! ReportContentTableViewCell
                cell.selectionStyle = .none
                
                cell.textTitle.textContainerInset = UIEdgeInsets.zero;
                cell.textContent.textContainerInset = UIEdgeInsets.zero;
                
                cell.textTitle.text = reportTitle
                cell.textTitle.frame.size.width = tableView.frame.size.width - 34
                cell.textTitle.adjustHeight()
                cell.textContent.text = reportDescription
                cell.textContent.frame.size.width = tableView.frame.size.width - 34
                cell.textContent.adjustHeight()
                cell.authorName.text = reportAuthor
                cell.authorDate.text = reportDate
                cell.imageUrl = imageUrl
                
                if bookmark {
                    cell.bookmark()
                }
                
                cell.contentView.frame.size.height = 0
                cell.tester.frame.size.height = 0
                
                cell.contentView.frame.size.height += 8
                cell.tester.frame.size.height += 8
                
                cell.contentView.frame.size.height += cell.authorAvatar.frame.size.height
                cell.tester.frame.size.height += cell.authorAvatar.frame.size.height
                
                cell.contentView.frame.size.height += 8
                cell.tester.frame.size.height += 8
                
                cell.contentView.frame.size.height += cell.textTitle.frame.size.height
                cell.tester.frame.size.height += cell.textTitle.frame.size.height
                //            cell.tester2.frame.size = cell.textTitle.frame.size
                
                cell.contentView.frame.size.height += 8
                cell.tester.frame.size.height += 8
                
                cell.contentView.frame.size.height += cell.textContent.frame.size.height
                cell.tester.frame.size.height += cell.textContent.frame.size.height
                cell.tester2.frame.size = cell.textContent.frame.size
                
                cell.contentView.frame.size.height += 8
                //            cell.tester.frame.size.height += 8
                
                cell.contentView.layoutIfNeeded()
                
                currentCellHeight = cell.contentView.frame.size.height
                cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
                
                cell.bookmarkButton!.addTarget(self, action: #selector(bookmarkTouchUp(_:)), for: .touchUpInside)
                
                return cell
                
            } else if (indexPath.item == 1) {
                if (reportAttachments.count != 0) {
                    let cell = Bundle.main.loadNibNamed("ReportAttachmentsTableViewCell", owner: self, options: nil)?.first as! ReportAttachmentsTableViewCell
                    cell.selectionStyle = .none
                    
                    cell.reportAttachments = reportAttachments
                    
                    currentCellHeight = cell.contentView.frame.size.height
                    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
                    
                    if (reportComments.count == 0) {
                        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
                    }
                    
                    return cell
                    
                } else {
                    let cell = UITableViewCell()
                    currentCellHeight = 8
                    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
                    
                    if (reportComments.count == 0) {
                        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
                    }
                    
                    return cell
                }
                
            } else if (indexPath.item >= staticRowsOffset && indexPath.item < staticRowsOffset + reportInfo.count) {
                let cell = Bundle.main.loadNibNamed("ReportInfoTableViewCell", owner: self, options: nil)?.first as! ReportInfoTableViewCell
                cell.selectionStyle = .none
                
                cell.infoTitle.text = reportInfo[indexPath.item - staticRowsOffset].label
                cell.values = reportInfo[indexPath.item - staticRowsOffset].value.trimmingCharacters(in: .whitespaces).split(separator: ",").map(String.init)
                
                currentCellHeight = cell.contentView.frame.size.height
                cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
                
                if (indexPath.item == staticRowsOffset + reportInfo.count - 1) {
                    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
                }
                
                return cell
                
            } else if (indexPath.item >= staticRowsOffset + reportInfo.count) {
                let cell = Bundle.main.loadNibNamed("ReportCommentTableViewCell", owner: self, options: nil)?.first as! ReportCommentTableViewCell
                
                let reportComment = reportComments[indexPath.item - staticRowsOffset - reportInfo.count]
                
                if reportComment.avatarImage == nil {
                    DispatchQueue.main.async {
                        guard let imageData = try? Data(contentsOf: reportComment.avatar) else {
                            print("Avatar Loading Error...")
                            return
                        }
                        
                        self.reportComments[indexPath.item - self.staticRowsOffset - self.reportInfo.count].avatarImage = UIImage(data: imageData)!
                        cell.authorAvatar.image = self.reportComments[indexPath.item - self.staticRowsOffset - self.reportInfo.count].avatarImage
                    }
                } else {
                    cell.authorAvatar.image = reportComment.avatarImage
                }
                
                cell.commentAuthor.text = reportComment.authorName
                cell.commentText.text = reportComment.text
                cell.commentDate.text = reportComment.date
                
                if reportComment.meta {
                    cell.commentText.textColor = UIColor.vkBlue
                }
                
                cell.commentText.textContainerInset = UIEdgeInsets.zero;
                
                cell.commentText.frame.size.width = tableView.frame.size.width - 76
                cell.commentText.adjustHeight()
                
                cell.contentView.frame.size.height = 0
                
                cell.contentView.frame.size.height += 8
                
                cell.contentView.frame.size.height += cell.commentAuthor.frame.size.height
                
                cell.contentView.frame.size.height += 4
                
                cell.contentView.frame.size.height += cell.commentText.frame.size.height
                
                cell.contentView.frame.size.height += 4
                
                cell.contentView.frame.size.height += cell.commentDate.frame.size.height
                
                cell.contentView.frame.size.height += 8
                
                cell.contentView.layoutIfNeeded()
                
                cell.separatorInset = UIEdgeInsetsMake(0, 65, 0, 0)
                
                if (indexPath.item == staticRowsOffset + reportInfo.count + reportComments.count - 1) {
                    cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
                }
                
                currentCellHeight = cell.contentView.frame.size.height
                
                return cell
                
            } else {
                
                let cell = UITableViewCell()
                
                currentCellHeight = 0
                cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
                
                return cell
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return currentCellHeight
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.item >= 2 {
            return indexPath
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.item >= self.staticRowsOffset + reportInfo.count) {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let item = indexPath.item - self.staticRowsOffset - reportInfo.count
            
            if let remove = self.reportComments[item].remove {
                
                let removeButton = UIAlertAction(title: "Удалить", style: .destructive, handler: { (action) -> Void in
                    self.removeComment(id: remove.id, hash: remove.hash, item: indexPath.item)
                })
                
                alertController.addAction(removeButton)
                
                let editButton = UIAlertAction(title: "Редактировать", style: .default) { (action) in
                    self.currentSelectedCommentId = indexPath.item - self.staticRowsOffset;
                    self.performSegue(withIdentifier: "showEditComment", sender: self)
                }
                
                alertController.addAction(editButton)
                
            } else {
                
                if commentTextField.isEnabled {
                    let replyButton = UIAlertAction(title: "Ответить", style: .default, handler: { (action) -> Void in
                        self.commentTextField.text = "\(self.reportComments[item].authorName), \(self.commentTextField.text!)"
                        self.commentTextField.becomeFirstResponder()
                    })
                    
                    alertController.addAction(replyButton)
                }
                
            }
            
            let copyButton = UIAlertAction(title: "Скопировать", style: .default, handler: { (action) -> Void in
                UIPasteboard.general.string = self.reportComments[item].text
            })
            alertController.addAction(copyButton)
            
            self.currentAuthorId = self.reportComments[item].authorId
            
            if self.currentAuthorId != nil {
                
                let authorButton = UIAlertAction(title: "\(reportComments[item].authorName)", style: .default, handler: { (action) -> Void in
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showProfileFromReportAlt", sender: self)
                    }
                    
                })
                
                alertController.addAction(authorButton)
                
            }
            
            let cancelButton = UIAlertAction(title: "Отменить", style: .cancel, handler: { (action) -> Void in
                
            })
            
            alertController.addAction(cancelButton)
            
            self.navigationController!.present(alertController, animated: true, completion: nil)
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @IBAction func commentTextFieldEditingChanged(_ sender: Any) {
        if (commentTextField.text != "") {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showProfileFromReportAlt" {
            let profileViewController: ProfileViewController = segue.destination as! ProfileViewController
            
            profileViewController.profileId = currentAuthorId
            profileViewController.isModal = true
            
        } else if segue.identifier == "showEditComment" {
            let editCommentViewController: EditCommentViewController = segue.destination as! EditCommentViewController
            
            editCommentViewController.commentText = reportComments[currentSelectedCommentId!].text
        }
    }
    
    override func viewDidLoad() {
        
        self.navigationController?.navigationBar.tintColor = .white
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().isTranslucent = false
        
        self.tabBarController?.tabBar.clipsToBounds = true
        
        let border = CALayer()
        border.backgroundColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: 0, width: commentView.frame.size.width, height: 0.5)
        commentView.layer.addSublayer(border)
        
        sendButton.layer.cornerRadius = sendButton.frame.width / 2
        
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
        super.viewWillAppear(animated)
        getValues()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                                         name: NSNotification.Name.UIKeyboardWillShow,
                                                         object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                                         name: NSNotification.Name.UIKeyboardWillHide,
                                                         object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        
        let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue?
        
        if !keyboardShowed {
            
            keyboardSize = frame?.cgRectValue.size
            
            let animationTime = (userInfo[UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
            
            UIView.animate(withDuration: animationTime!) {
                self.view.frame.origin.y = self.view.frame.origin.y - (self.keyboardSize?.height)! + (self.tabBarController?.tabBar.frame.size.height)!
            }
            
            keyboardShowed = true
            
        } else {
            
            let keyboardHeightOffset = (frame?.cgRectValue.size.height)! - (keyboardSize?.height)!
            keyboardSize = frame?.cgRectValue.size
            
            self.view.frame.origin.y = self.view.frame.origin.y - keyboardHeightOffset
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if (keyboardHidden) {
            keyboardHidden = false
        } else {
            let userInfo = notification.userInfo!
            
            let animationTime = (userInfo[UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
            
            UIView.animate(withDuration: animationTime!) {
                self.view.frame.origin.y = self.view.frame.origin.y + (self.keyboardSize?.height)! - (self.tabBarController?.tabBar.frame.size.height)!
            }
            
            keyboardHidden = true
            keyboardShowed = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            self.reportComments.removeAll()
            self.reportAttachments.removeAll()
            self.getValues()
            self.tableView.reloadData()
            timer = Timer.scheduledTimer(timeInterval: 2, target: self,   selector: (#selector(ReportAlternativeViewController.refreshControlEndRefreshing)), userInfo: nil, repeats: true)
        }
    }
    
    @objc func refreshControlEndRefreshing() {
        
        self.refreshControl.endRefreshing()
        
        timer = Timer()
    }
    
    func getValues() {
        do {
            let contents = try String(contentsOf: URL(string: "https://vk.com/bugtracker?act=show&al=0&al_id=\(userId!)&id=\(reportId!)")!, encoding: .windowsCP1251)
            
            let doc = try HTML(html: String(describing: contents), encoding: .windowsCP1251)
            
            if (doc.at_css(".message_page_title")?.text != nil) {
                error = true
            }
            
            if (!error) {
                
                let text = doc.at_css(".bt_report_one_descr")?.innerHTML
                reportDescription = String(htmlEncodedString: text!)
                
                if doc.at_css(".bt_comment_form_unavailable")?.text == nil {
                    reportCommentHash = (doc.body?.innerHTML?.matchingStrings(regex: "cur.bugreportHash = '(.*)'"))![0][1]
                } else {
                    commentTextField.isEnabled = false
                    sendButton.isEnabled = false
                }
                
                if (doc.at_css("._header_extra a") != nil) {
                    let editContents = try String(contentsOf: URL(string: "https://vk.com/bugtracker?act=edit&al=0&al_id=\(userId!)&id=\(reportId!)")!, encoding: .windowsCP1251)
                    
                    let editDoc = try HTML(html: String(describing: editContents), encoding: .windowsCP1251)
                    
                    let removeBtn = editDoc.at_css(".bt_hform_submit_block .secondary")
                    
                    reportEditHash = (removeBtn!["onclick"]!).matchingStrings(regex: "(?<=').*(?=')")[0][0]
                }
                
                if (doc.at_css(".bt_report_one_fav")?.className?.contains("bt_report_fav_checked"))! {
                    self.bookmark = true
                }
                
                for crumb in doc.css(".ui_crumb") {
                    if crumb["href"] != "bugtracker" {
                        self.title = crumb.text!
                    }
                }
                
                reportAuthor = doc.at_css(".bt_report_one_author_content a")?.text!
                
                reportDate = doc.at_css(".bt_report_one_author_date")?.text!
                
                let imageSrc = doc.at_css(".bt_report_one_author__img")!["src"]!
                
                if imageSrc[imageSrc.index(imageSrc.startIndex, offsetBy: 0)] == "/" {
                    imageUrl = URL(string: "https://vk.com\(imageSrc)")!
                } else {
                    imageUrl = URL(string: imageSrc)!
                }
                
                for docsRow in doc.css(".media_desc__doc") {
                    let docIcon = docsRow.at_css(".page_doc_icon")!
                    let docHref = docIcon["href"]!
                    let docTypeString = String((docIcon.className?.split(separator: " ")[1])!)
                    
                    var docType = DocType.icon1
                    
                    switch (docTypeString) {
                    case "page_doc_icon2":
                        docType = .icon2
                        break;
                    case "page_doc_icon3":
                        docType = .icon3
                        break;
                    case "page_doc_icon4":
                        docType = .icon4
                        break;
                    case "page_doc_icon5":
                        docType = .icon5
                        break;
                    case "page_doc_icon6":
                        docType = .icon6
                        break;
                    case "page_doc_icon7":
                        docType = .icon7
                        break;
                    case "page_doc_icon8":
                        docType = .icon8
                        break;
                    default:
                        break;
                    }
                    
                    let reportAttachment = ReportAttachment(type: docType, href: docHref)
                    reportAttachments.append(reportAttachment)
                    
                }
                
                for infoRow in doc.css(".bt_report_one_info_row") {
                    let label = infoRow.at_css(".bt_report_one_info_row_label")?.text!
                    let value = infoRow.at_css(".bt_report_one_info_row_value")?.text!
                    
                    let info = ReportInfo(label: label!, value: value!, size: CGSize(width: 1, height: 21))
                    reportInfo.append(info)
                }
                
                /*
                sendComment: function() {
                    if (cur.bugreportId && cur.bugreportHash) {
                        var b = ge("bt_comment_form_submit"),
                        t = ge("bt_comment_form_text"),
                        m = trim(val(t)),
                        attachs = [];
                        return each(cur.btNewCommentMedia.getMedias(), function(e, t) {
                            attachs.push(t[0] + "," + t[1])
                        }), m || attachs.length ? void ajax.post("bugtracker?act=a_send_comment", {
                        report_id: cur.bugreportId,
                        hash: cur.bugreportHash,
                        message: m,
                        attachs: attachs,
                        hidden: +isChecked("bt_comment_hidden")
                        }, {
                        showProgress: lockButton.pbind(b),
                        hideProgress: unlockButton.pbind(b),
                        onDone: function(html, js) {
                        domReplaceEl(ge("bt_report_one_section"), se(html)), js && eval(js)
                        }
                        }) : notaBene(t)
                    }
                }
                 <div class="reply_edit_button reply_action fl_r" onclick="BugTracker.editComment('50918_1','7db551564aff342af0', [], cur.btCommentMediaTypes, 'bugs60902552')" data-title="Редактировать" onmouseover="showTitle(this);" aria-label="Редактировать" tabindex="0" role="link"></div>
                 */
                
                for commentsRow in doc.css(".bt_report_cmt") {
                    let avatarSrc = commentsRow.at_css(".bt_report_cmt_img")!["src"]!
                    let author = commentsRow.at_css(".bt_report_cmt_author .bt_report_cmt_author_a")!
                    let authorText = author.text!
                    let authorId = author["href"]?.matchingStrings(regex: "act=reporter&id=(.*)")[0][1]
                    var text = String(htmlEncodedString: commentsRow.at_css(".bt_report_cmt_text")!.innerHTML!)
                    let date = commentsRow.at_css(".bt_report_cmt_info .bt_report_cmt_date")!.text!
                    
                    var avatarUrl: URL
                    
                    if avatarSrc[avatarSrc.index(avatarSrc.startIndex, offsetBy: 0)] == "/" {
                        avatarUrl = URL(string: "https://vk.com\(avatarSrc)")!
                    } else {
                        avatarUrl = URL(string: avatarSrc)!
                    }
                    
                    var meta = false
                    
                    for metaRow in commentsRow.css(".bt_report_cmt_meta_row") {
                        
                        meta = true
                        
                        let metaText = String(htmlEncodedString: metaRow.text!)
                        
                        if text != "" {
                            text = "\(metaText)\n\(text)"
                        } else {
                            
                            text = metaText
                        }
                    }
                    
                    let deleteButton = commentsRow.at_css(".reply_delete_button")
                    
                    var remove: CommentRemove?
                    
                    if deleteButton != nil {
                        
                        let deleteIdAndHash = deleteButton!["onclick"]!.matchingStrings(regex: "'([^']+)'")
                        let deleteId = deleteIdAndHash[0][1]
                        let deleteHash = deleteIdAndHash[1][1]
                        
                        remove = CommentRemove(id: deleteId, hash: deleteHash)
                    }
                    
                    let reportComment = ReportComment(avatar: avatarUrl, avatarImage: nil, authorName: authorText, authorId: authorId, meta: meta, text: text, date: date, remove: remove)
                    reportComments.append(reportComment)
                }
            }
            
//            self.activityIndicator.stopAnimating()
        } catch {
            
        }
    }
    
    
    @IBAction func sendButtonTouchUpInside(_ sender: Any) {
        submitComment(text: commentTextField.text!)
        commentTextField.text = ""
        sendButton.isEnabled = false
    }
    
    func submitComment(text: String) {
        var request = URLRequest(url: URL(string: "https://vk.com/bugtracker")!)
        request.httpMethod = "POST"
        let postString = "act=a_send_comment&report_id=\(reportId!)&hash=\(reportCommentHash!)&message=\(commentTextField.text!)"
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
            
//            let currentDateTime = Date()
//
//            let formatter = DateFormatter()
//            formatter.timeStyle = .short
//            formatter.dateStyle = .none
//
//            let time = formatter.string(from: currentDateTime)
//
//            let reportComment = ReportComment(avatar: userAvatarUrl!, avatarImage: userAvatar!, authorName: "\(userFirstName!) \(userLastName!)", authorUrl: URL(string: "https://vk.com/bugtracker?act=reporter&id=\(userId!)")!, meta: false, text: text, date: "сегодня, \(time)", remove: nil)
//            self.reportComments.append(reportComment)
            
            DispatchQueue.main.async {
                self.reportComments.removeAll()
                self.getValues()
                self.tableView.reloadData()
                self.view.endEditing(true)
            }
        }
        task.resume()
    }
    
    func removeComment(id: String, hash: String, item: Int) {
        var request = URLRequest(url: URL(string: "https://vk.com/bugtracker")!)
        request.httpMethod = "POST"
        let postString = "act=remove_comment&id=\(id)&hash=\(hash)"
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
            
            self.reportComments.remove(at: item - self.reportInfo.count - self.staticRowsOffset)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        task.resume()
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
    
    @objc func bookmarkTouchUp(_ sender: UIButton!) {
        
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
            
            let originalTransform = sender.transform
            let scaledTransform = originalTransform.scaledBy(x: 0, y: 0)
            
            sender.transform = scaledTransform
            
            sender.setImage(UIImage(named: "star-filled"), for: .normal)
            self.bookmark = true
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                
                sender.transform = originalTransform
                
            }, completion: nil)
            
        } else {
            let originalTransform = sender.transform
            let scaledTransform = originalTransform.scaledBy(x: 0, y: 0)
            
            sender.transform = scaledTransform
            
            sender.setImage(UIImage(named: "star"), for: .normal)
            self.bookmark = false
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                
                sender.transform = originalTransform
                
            }, completion: nil)
        }
    }
}

