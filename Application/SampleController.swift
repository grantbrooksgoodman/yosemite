//
//  SampleController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 04/08/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import MessageUI
import UIKit

class SampleController: UIViewController, MFMailComposeViewControllerDelegate {
    
    //==================================================//
    
    /* MARK: - Interface Builder UI Elements */
    
    //==================================================//
    
    /* MARK: - Class-level Variable Declarations */
    
    var buildInstance: Build!
    
    //==================================================//
    
    /* MARK: - Initializer Function */
    
    func initializeController() {
        lastInitializedController = self
        buildInstance = Build(self)
    }
    
    //==================================================//
    
    /* MARK: - Overridden Functions */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentFile = #file
        buildInfoController?.view.isHidden = !preReleaseApplication
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    //==================================================//
    
    /* MARK: - Interface Builder Actions */
    
    //==================================================//
    
    /* MARK: - Other Functions */
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        buildInstance.handleMailComposition(withController: controller, withResult: result, withError: error)
    }
}
