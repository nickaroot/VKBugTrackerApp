//
//  AttachmentsViewController.swift
//  VKBugTrackerApp
//
//  Created by Nick Aroot on 04/01/2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit
import SwiftyVK
import MediaPlayer

class AttachmentsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var outsideView: UIView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var hintIcon: UIImageView!
    @IBOutlet weak var loadingProgress: UIProgressView!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    
    var imagePicker = UIImagePickerController(),
        tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(),
        initialCenter = CGPoint()
    
    @objc func dismissController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 3, height: 3)
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowRadius = 10
        
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        
        addButton.titleLabel?.textColor = UIColor.black.withAlphaComponent(0.7)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissController))
        outsideView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        let piece = panGesture.view!
        let translation = panGesture.translation(in: piece.superview)
        if panGesture.state == .began {
            initialCenter = piece.center
        }
        
        func magnitude(vector: CGPoint) -> CGFloat {
            return sqrt(pow(vector.x, 2) + pow(vector.y, 2))
        }
        
        let totalDistance = magnitude(vector: translation)
        let magVelocity = magnitude(vector: panGesture.velocity(in: self.shadowView))
        let animationDuration: TimeInterval = 1
        let springVelocity: CGFloat = magVelocity / totalDistance / CGFloat(animationDuration)
        
        if translation.y > 0 && panGesture.state != .cancelled {
            let newCenter = CGPoint(x: initialCenter.x, y: initialCenter.y + totalDistance)
            piece.center = newCenter
            if translation.y > 50 && panGesture.state == .ended {
                self.dismissController()
            } else if panGesture.state == .ended {
                UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: springVelocity, options: [], animations: {
                    piece.center = self.initialCenter
                }, completion: nil)
            }
        } else if translation.y < 0 && panGesture.state != .cancelled {
            let newCenter = CGPoint(x: initialCenter.x, y: initialCenter.y - totalDistance)
            piece.center = newCenter
            if panGesture.state == .ended {
                UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: springVelocity, options: [], animations: {
                    piece.center = self.initialCenter
                }, completion: nil)
            }
        } else {
            piece.center = initialCenter
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if attachments.count == 0 {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                self.hintLabel.alpha = 0.7
                self.hintIcon.alpha = 0.7
            }, completion: nil)
        }
        
        return attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.register(UINib(nibName: "AttachmentsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "attachmentsCell")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "attachmentsCell", for: indexPath) as! AttachmentsCollectionViewCell
        
        cell.docImageView.layer.cornerRadius = 10
        cell.docImageView.layer.masksToBounds = true
        cell.docImageView.image = attachments[indexPath.item].image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        APIWorker.removeDocument(sender: self, item: indexPath.item) { (complete) in
            if (complete)! {
                
                attachments.remove(at: indexPath.item)
                
                DispatchQueue.main.async {
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    self.collectionView.reloadData()
                }
                
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addAttachmentButtonDown(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.mediaTypes = ["public.image", "public.movie"]
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let _ = info["UIImagePickerControllerReferenceURL"] as? URL,
            imageUrl = info["UIImagePickerControllerImageURL"] as? URL,
            mediaUrl = info["UIImagePickerControllerMediaURL"] as? URL,
            mediaType = info["UIImagePickerControllerMediaType"] as? String
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
            self.hintLabel.alpha = 0
            self.hintIcon.alpha = 0
            self.loadingProgress.alpha = 1
        }, completion: nil)
        
        if mediaType == "public.image" {
            
            do {
                let doc = try! Data(contentsOf: imageUrl!)
                
                APIWorker.uploadDocument(sender: self, doc: doc, thumbnail: nil, completion: {
                    (ownerId, docId, image) in
                    
                    if (ownerId != nil && docId != nil && image != nil) {
                        attachments.append(Attachment(ownerId: ownerId!, docId: docId!, image: image!, animated: true))
                    }
                    
                    DispatchQueue.main.async {
                        self.collectionView.collectionViewLayout.invalidateLayout()
                        self.collectionView.reloadData()
                    }
                })
                
            }
            
        } else if mediaType == "public.movie" {
            
            do {
                let doc = try! Data(contentsOf: mediaUrl!)
                
                let thumbnail = AVAsset(url: mediaUrl!).videoThumbnail
                
                APIWorker.uploadDocument(sender: self, doc: doc, thumbnail: thumbnail!, completion: {
                    (ownerId, docId, image) in
                    
                    if (ownerId != nil && docId != nil && image != nil) {
                        attachments.append(Attachment(ownerId: ownerId!, docId: docId!, image: image!, animated: true))
                    }
                    
                    DispatchQueue.main.async {
                        self.collectionView.collectionViewLayout.invalidateLayout()
                        self.collectionView.reloadData()
                    }
                    
                    //            geByClass1("ms_item_doc").click()
                    //            ge("docs_file_\(doc!)").click()
                    //            geByClass1("box_x_button").click()
                    
                    //            domQuery1("#pam1_doc\(doc!) .page_media_x_wrap").click()
                })
                
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
