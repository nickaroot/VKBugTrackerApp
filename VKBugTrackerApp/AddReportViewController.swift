//
//  AddReportViewController.swift
//  VKBugTracker
//
//  Created by Nick Aroot on 24/12/2017.
//  Copyright © 2017 Nick Aroot. All rights reserved.
//

import UIKit
import WebKit

class AddReportViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var descrTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var productsPicker: UIPickerView!
    @IBOutlet weak var levelsPicker: UIPickerView!
    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var descrContainer: UIView!
    @IBOutlet weak var pickersContainer: UIView!
    @IBOutlet weak var vulnerabilitySwitch: UISwitch!
    @IBOutlet weak var vulnerabilityButton: UIButton!
    @IBOutlet weak var tagsTableView: UITableView!
    @IBOutlet weak var globalActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var attachmentsButton: UIButton!
    
    struct Product {
        let title: String
        let id: Int
    }
    
    struct Tag {
        let title: String
        var switched: Bool
        var animate: Bool
        let productId: Int
        let id: Int
        
        mutating func `switch`() {
            switched = !switched
        }
    }
    
    var placeholderColor: UIColor?,
        formTitle: String?, formDescr: String?,
        formSelectedTags = [String](),
        products = [Product](),
        levels = ["Низкий", "Средний", "Высокий", "Критический"],
        tags = [Tag](),
        selectedTags = [Tag](),
        productsCounter = 0,
        submitted = false,
        editMode = false
    
    enum webViewFunction {
        case none
        case submitForm
        case getValues
    }
    
    var wvf: webViewFunction = .none
    
    override func viewDidLoad() {
        
        tagsTableView.delegate = self
        tagsTableView.dataSource = self
        tagsTableView.layer.cornerRadius = 10
        tagsTableView.layer.masksToBounds = true
        
        productsPicker.delegate = self
        productsPicker.dataSource = self
        
        pickersContainer.layer.cornerRadius = 10
        pickersContainer.layer.masksToBounds = true
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        webView.layer.cornerRadius = 10
        webView.layer.masksToBounds = true
        
        doneBtn.layer.cornerRadius = 10
        doneBtn.layer.masksToBounds = true
        
        placeholderColor = descrTextView.textColor
        
        descrTextView.delegate = self
        descrTextView.placeholder = "Расскажите о баге более подробно"
        descrContainer.layer.cornerRadius = 10
        descrContainer.layer.masksToBounds = true
        
        titleContainer.layer.cornerRadius = 10
        titleContainer.layer.masksToBounds = true
        
        self.navigationController?.navigationBar.tintColor = .white
        
        wvf = .getValues
        webView.load(URLRequest(url: URL(string: "https://vk.com/bugtracker?act=add")!))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if reportCache != nil {
            titleTextField.text = reportCache!.title
            descrTextView.text = reportCache!.descr
            descrTextView.hidePlaceholder()
            levelsPicker.selectRow(reportCache!.level, inComponent: 0, animated: true)
            vulnerabilitySwitch.setOn(reportCache!.vulnerability, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if submitted {
            reportCache = nil
        } else {
            reportCache = ReportCache(title: titleTextField.text!, descr: descrTextView.text!, product: productsPicker.selectedRow(inComponent: 0), level: levelsPicker.selectedRow(inComponent: 0), tags: selectedTags.filter({ $0.switched }), vulnerability: vulnerabilitySwitch.isOn)
        }
    }
    
    @IBAction func vulnerabilityButtonDown(_ sender: Any) {
        
        vulnerabilitySwitch.setOn(!vulnerabilitySwitch.isOn, animated: true)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
    }
    
    @IBAction func attachmentsButtonDown(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pvc = storyboard.instantiateViewController(withIdentifier: "AttachmentsViewController") as! AttachmentsViewController
        pvc.modalPresentationStyle = .custom
        
        self.present(pvc, animated: true, completion: nil)
    }
    
    func updateSelectedTags() {
        selectedTags = tags.filter {$0.productId == products[productsPicker.selectedRow(inComponent: 0)].id}
        if reportCache != nil {
            if productsPicker.selectedRow(inComponent: 0) == reportCache!.product {
                let filteredTags = self.selectedTags.filter({ (tag) -> Bool in
                    !(reportCache?.tags.contains(where: { (cacheTag) -> Bool in cacheTag.id == tag.id}))!
                })
                
                reportCache?.tags.forEach({ (cacheTag) in
                    formSelectedTags.append(String(describing: cacheTag.id))
                })
                
                self.selectedTags = reportCache!.tags + filteredTags
            }
        }
        tagsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("TagsTableViewCell", owner: self, options: nil)?.first as! TagsTableViewCell
        
        let tag = selectedTags[indexPath.row]
        
        cell.tagLabel.text = tag.title
        
        if tag.switched {
            if tag.animate {
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    cell.checkboxImageView.alpha = 1
                }, completion: nil)
                selectedTags[indexPath.row].animate = false
            } else {
                cell.checkboxImageView.alpha = 1
            }
        } else {
            if tag.animate {
                cell.checkboxImageView.alpha = 1
                selectedTags[indexPath.row].animate = false
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    cell.checkboxImageView.alpha = 0
                }, completion: nil)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let id = String(describing: selectedTags[indexPath.row].id)
        
        if !selectedTags[indexPath.row].switched {
            selectedTags[indexPath.row].switched = true
            selectedTags[indexPath.row].animate = true
            formSelectedTags.append(id)
            tagsTableView.reloadData()
        } else {
            selectedTags[indexPath.row].switched = false
            selectedTags[indexPath.row].animate = true
            formSelectedTags = formSelectedTags.filter {$0 != id}
            tagsTableView.reloadData()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == productsPicker) {
            return products.count;
        } else if (pickerView == levelsPicker) {
            return levels.count;
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if (pickerView == productsPicker) {
            let titleData = products[row].title
            let t = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
            return t
        } else if (pickerView == levelsPicker) {
            let titleData = levels[row]
            let t = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
            return t
        } else {
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.view.endEditing(true)
        if pickerView == productsPicker {
            updateSelectedTags()
        }
    }
    
    @IBAction func doneBtnDown(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        formTitle = titleTextField.text
        formDescr = descrTextView.text
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.doneBtn.setTitleColor(.white, for: .normal)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
            self.activityIndicator.startAnimating()
        }, completion: nil)
        wvf = .submitForm
        webView.load(URLRequest(url: URL(string: "https://vk.com/bugtracker?act=add")!))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if (wvf == .submitForm) {
            
            submitForm(webView)
            wvf = .none
            
        } else if (wvf == .getValues) {
            
            getValues(webView)
            wvf = .none
            
        }
    }
    
    func getValues(_ webView: WKWebView) {
        
        webView.evaluateJavaScript("JSON.stringify(cur.newBugProductDD.options.defaultItems)") { (pJson: Any?, pError: Error?) in
            
            let pJsonString = String(describing: pJson!)
            let pJsonData = pJsonString.data(using: .utf8)
            
            do {
                let pData = try! JSONSerialization.jsonObject(with: pJsonData!, options: .mutableContainers)
                let pProducts = pData as! Array<Array<Any>>
                
                for pProduct in pProducts {
                    
                    let pProductTitle = pProduct[1] as! String
                    
                    let pProductId = Int(String(describing: pProduct[0]))
                    
                    
                    
                    self.products.append(Product(title: pProductTitle, id: pProductId!))
                }
                
                self.productsPicker.reloadAllComponents()
                
                webView.evaluateJavaScript("JSON.stringify(cur.btFormDDValues)", completionHandler: { (tJson: Any?, tError: Error?) in
                    
                    let tJsonString = String(describing: tJson!)
                    let tJsonData = tJsonString.data(using: .utf8)
                    
                    do {
                        let tData = try! JSONSerialization.jsonObject(with: tJsonData!, options: .mutableContainers)
                        let tProducts = tData as! Dictionary<String, Dictionary<String, Array<Array<Any>>>>
                        
                        for tProduct in tProducts {
                            let tProductId = Int(tProduct.key)
                            for tFields in tProduct.value {
                                if tFields.key == "tags" {
                                    for tRow in tFields.value {
                                        let tTagId = tRow[0] as! Int
                                        let tTagTitle = tRow[1] as! String
                                        self.tags.append(Tag(title: tTagTitle, switched: false, animate: false, productId: tProductId!, id: tTagId))
                                    }
                                }
                            }
                        }
                        self.updateSelectedTags()
                        
                    }
                })
                
                if reportCache != nil {
                    self.productsPicker.selectRow(reportCache!.product, inComponent: 0, animated: true)
                }
                
                self.globalActivityIndicator.stopAnimating()
                
            }
        }
    }
    
    func submitForm(_ webView: WKWebView) {
        
        let formSelectedTagsString = formSelectedTags.joined(separator: ",")
        
        var js = "ge('bt_form_title').value = '\(formTitle!)';"
        
        let fdArr = formDescr?.components(separatedBy: "\n")
        var fdInit = false
        
        js += "ge('bt_form_descr').value = '\(fdArr![0]) \\n'"
        
        for fd in fdArr! {
            
            if !fdInit {
                fdInit = true
            } else {
                js += " + '\(fd) \\n'"
            }
            
        }
        
        js += ";"
        
        js += "domQuery1('#bt_form_tags #selectedItems').value = '\(formSelectedTagsString)';"
        
        js += "domQuery1('.bt_hform_block #selectedItems').value = '\(products[productsPicker.selectedRow(inComponent: 0)].id))';"
        
        js += "domQuery1('#bt_form_severity_block #selectedItems').value = '\(levelsPicker.selectedRow(inComponent: 0)+1))';"
        
        if vulnerabilitySwitch.isOn {
            js += "ge('bt_form_vulnerability').click();"
        }
        
        for attachment in attachments {
            
            js += "cur.btNewMedia.chosenMedias.push(['doc', '\(attachment.ownerId!)_\(attachment.docId!)', undefined, undefined, undefined]);"
        }
        
        js += "ge('bt_report_form__save').click();"
        
        webView.evaluateJavaScript(js) { (res, err) in
            
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                self.activityIndicator.alpha = 0
            }, completion: { (e) in
                attachments = []
                self.submitted = true
                self.activityIndicator.stopAnimating()
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
}
