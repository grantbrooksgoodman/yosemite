//
//  GenericController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 20/08/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import MessageUI
import UIKit

class GenericController: UIViewController {
    
    //==================================================//
    
    /* MARK: - Interface Builder UI Elements */
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    //==================================================//
    
    /* MARK: - Class-level Variable Declarations */
    
    var titleText: String!
    var content: String!
    
    //==================================================//
    
    /* MARK: - Overridden Functions */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentLabel.tag = aTagFor("contentLabel")
        
        //        for subview in view.subviews {
        //            if subview.tag != aTagFor("contentLabel") {
        //                subview.updateFrame()
        //            } else {
        //                if UIScreen.main.bounds.height == f.screenHeight(.fourInch) {
        //                    subview.frame.size.height = f.height(subview.frame.size.height)
        //                    subview.frame.size.width = f.width(subview.frame.size.width)
        //                    subview.center.x = view.center.x
        //                    subview.center.y = view.center.y - 200
        //                } else if UIScreen.main.bounds.height == f.screenHeight(.fiveFiveInch) {
        //                    subview.frame.size.height = f.height(subview.frame.size.height)
        //                    subview.frame.size.width = f.width(subview.frame.size.width)
        //                    subview.center.x = view.center.x - 10
        //                    subview.center.y = view.center.y - 290
        //                } else if UIScreen.main.bounds.height == f.screenHeight(.sixInch) {
        //                    subview.frame.size.height = f.height(subview.frame.size.height)
        //                    subview.frame.size.width = f.width(subview.frame.size.width)
        //                    subview.center.x = view.center.x - 10
        //                    subview.center.y = view.center.y - 370
        //                }
        //            }
        //        }
        
        view.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        titleLabel.text = titleText
        contentLabel.text = content
        
        view.alpha = 1
        view.tag += 1
    }
}
