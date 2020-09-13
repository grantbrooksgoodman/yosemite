//
//  SportsController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 20/08/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit

class SportsController: UIViewController
{
    //--------------------------------------------------//
    
    /* Interface Builder UI Elements */
    
    @IBOutlet weak var titleLabel: TranslatedLabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    //--------------------------------------------------//
    
    /* Overridden Functions */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //view.translatesAutoresizingMaskIntoConstraints = false
        
        view.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        let user = (self.parent as! CardPageController).user!
        
        titleLabel.text = "🏈 \(user.firstName.uppercased()) PLAYS..."
        
        view.alpha = 1
        view.tag += 1
    }
    
    //--------------------------------------------------//
    
    /* Interface Builder Actions */
    
    //--------------------------------------------------//
    
    /* Independent Functions */
}
