//
//  SampleController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 04/08/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit

class SampleController: UIViewController, MFMailComposeViewControllerDelegate
{
    //--------------------------------------------------//
    
    /* Interface Builder UI Elements */
    
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    var buildInstance: Build!
    
    //--------------------------------------------------//
    
    /* Initialiser Function */
    
    func initialiseController()
    {
        lastInitialisedController = self
        buildInstance = Build(self)
    }
    
    //--------------------------------------------------//
    
    /* Overridden Functions */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initialiseController()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        currentFile = #file
        buildInfoController?.view.isHidden = false
    }
    
    //--------------------------------------------------//
    
    /* Interface Builder Actions */
    
    //--------------------------------------------------//
    
    /* Independent Functions */
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        buildInstance.handleMailComposition(withController: controller, withResult: result, withError: error)
    }
}
