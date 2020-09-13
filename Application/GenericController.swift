//
//  GenericController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 20/08/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit

class GenericController: UIViewController
{
    //--------------------------------------------------//
    
    /* Interface Builder UI Elements */
    
    @IBOutlet weak var titleLabel: TranslatedLabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    var titleText: String!
    var content: String!
    
    //--------------------------------------------------//
    
    /* Overridden Functions */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        for subview in view.subviews
        {
            subview.updateFrame()
        }
        
        view.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        titleLabel.text = titleText
        contentLabel.text = content
        
        view.alpha = 1
        view.tag += 1
    }
    
    //--------------------------------------------------//
    
    /* Interface Builder Actions */
    
    //--------------------------------------------------//
    
    /* Independent Functions */
}
