//
//  EditCommentViewController.swift
//  VKBugTrackerApp
//
//  Created by Nick Arut on 27.03.2018.
//  Copyright © 2018 Nick Aroot. All rights reserved.
//

import UIKit

class EditCommentViewController: UIViewController {
    
    var commentText: String?

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.text = commentText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelTouchDown(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
