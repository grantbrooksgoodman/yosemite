//
//  WelcomeController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 23/07/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit

class WelcomeController: UIViewController, MFMailComposeViewControllerDelegate
{
    //--------------------------------------------------//
    
    /* Interface Builder UI Elements */
    
    //ShadowButtons
    @IBOutlet weak var getStartedButton:  ShadowButton!
    @IBOutlet weak var haveAccountButton: ShadowButton!
    
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    var buildInstance: Build!
    
    //--------------------------------------------------//
    
    /* Initialiser Function */
    
    func initialiseController()
    {
        lastInitialisedController = self
        buildInstance = Build(self)
        currentFile = #file
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
        
        darkMode = true
        
        getStartedButton.initialiseLayer(animateTouches: true,
                                         backgroundColour: UIColor(hex: 0x60C129),
                                         customBorderFrame: nil,
                                         customCornerRadius: nil,
                                         shadowColour: UIColor(hex: 0x3B9A1B).cgColor,
                                         instanceName: nil)
        
        haveAccountButton.initialiseLayer(animateTouches: true,
                                          backgroundColour: UIColor(hex: 0x75B6EA),
                                          customBorderFrame: nil,
                                          customCornerRadius: nil,
                                          shadowColour: UIColor(hex: 0x66A0CE).cgColor,
                                          instanceName: nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        buildInfoController?.view.isHidden = false
    }
    
    //--------------------------------------------------//
    
    /* Interface Builder Actions */
    
    @IBAction func getStartedButton(_ sender: Any)
    {
        performSegue(withIdentifier: "createAccountFromWelcomeSegue", sender: self)
    }
    
    @IBAction func haveAccountButton(_ sender: Any)
    {
        performSegue(withIdentifier: "signInFromWelcomeSegue", sender: self)
    }
    
    @IBAction func sendFeedbackButton(_ sender: Any)
    {
        PresentationManager().feedbackController(withFileName: #file)
    }
    
    //--------------------------------------------------//
    
    /* Independent Functions */
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        buildInstance.handleMailComposition(withController: controller, withResult: result, withError: error)
    }
}
