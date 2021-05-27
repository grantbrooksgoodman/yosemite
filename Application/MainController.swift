//
//  MainController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 04/08/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import MessageUI
import UIKit

/* Third-party Frameworks */
import FirebaseDatabase
import PKHUD

class MainController: UIViewController, MFMailComposeViewControllerDelegate {
    
    //==================================================//
    
    /* MARK: - Interface Builder UI Elements */
    
    //UIButtons
    @IBOutlet weak var codeNameButton:     UIButton!
    @IBOutlet weak var informationButton:  UIButton!
    @IBOutlet weak var sendFeedbackButton: UIButton!
    @IBOutlet weak var subtitleButton:     UIButton!
    
    //UILabels
    @IBOutlet weak var bundleVersionLabel:     UILabel!
    @IBOutlet weak var projectIdentifierLabel: UILabel!
    @IBOutlet weak var skuLabel:               UILabel!
    
    //UIViews
    @IBOutlet weak var extraneousInformationView: UIView!
    @IBOutlet weak var preReleaseInformationView: UIView!
    
    //==================================================//
    
    /* MARK: - Class-level Variable Declarations */
    
    //Overridden Variables
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    //Other Declarations
    var buildInstance: Build!
    
    //==================================================//
    
    /* MARK: - Initializer Function */
    
    func initializeController() {
        /* Be sure to change the values below.
         *      The build number string when archiving.
         *      The code name of the application.
         *      The editor header file values.
         *      The first digit in the formatted version number.
         *      The value of the pre-release application boolean.
         *      The value of the prefers status bar boolean. */
        
        lastInitializedController = self
        buildInstance = Build(self)
    }
    
    //==================================================//
    
    /* MARK: - Overridden Functions */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeController()
        
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.red
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)]
        self.navigationItem.backBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
        
        view.backgroundColor = .black
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            PKHUD.sharedHUD.contentView = PKHUDProgressView(title: nil, subtitle: "Finding User...")
            PKHUD.sharedHUD.show(onView: self.view)
        }
        
        //showProgressHud()
        
        //signInUserWithMatches()
        signInRandomUser()
        
        if Int().random(min: 0, max: 10) % 2 == 0 {
            Testing().createRandomUser()
        }
        
        //        var i = 0
        //        while i < 15 {
        //            Testing().createRandomUser()
        //            i += 1
        //        }
    }
    
    func trashDatabase() {
        AlertKit().confirmationAlertController(title: "Trash Database?",
                                               message: "This will erase all data on the web server.",
                                               cancelConfirmTitles: ["confirm": "Confirm"],
                                               confirmationDestructive: true,
                                               confirmationPreferred: false,
                                               networkDepedent: true) { (didConfirm) in
            
            if let didConfirm = didConfirm,
               didConfirm {
                Database.database().reference().child("/").removeValue(completionBlock: { (error, refer) in
                    if error != nil {
                        report(error?.localizedDescription ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                        
                        AlertKit().errorAlertController(title: nil, message: error?.localizedDescription, dismissButtonTitle: nil, additionalSelectors: nil, preferredAdditionalSelector: nil, canFileReport: true, extraInfo: nil, metadata: [#file, #function, #line], networkDependent: true)
                    } else {
                        AlertKit().successAlertController(withTitle: "Success", withMessage: "Data trashed successfully.", withCancelButtonTitle: nil, withAlternateSelectors: nil, preferredActionIndex: nil)
                    }
                })
            }}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if informationDictionary["subtitleExpiryString"] == "Evaluation period ended." && preReleaseApplication {
            view.addBlur(withActivityIndicator: false, withStyle: .light, withTag: 1, alpha: 1)
            view.isUserInteractionEnabled = false
        }
        
        currentFile = #file
        buildInfoController?.view.isHidden = true
    }
    
    //==================================================//
    
    /* MARK: - Interface Builder Actions */
    
    @IBAction func codeNameButton(_ sender: AnyObject) {
        buildInstance.codeNameButtonAction()
    }
    
    @IBAction func informationButton(_ sender: AnyObject) {
        buildInstance.displayBuildInformation()
    }
    
    @IBAction func sendFeedbackButton(_ sender: Any) {
        AlertKit().feedbackController(withFileName: #file)
    }
    
    @IBAction func subtitleButton(_ sender: Any) {
        buildInstance.subtitleButtonAction(withButton: sender as! UIButton)
    }
    
    //==================================================//
    
    /* MARK: - Other Functions */
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        buildInstance.handleMailComposition(withController: controller, withResult: result, withError: error)
    }
    
    func signInRandomUser() {
        UserSerializer().getRandomUsers(amountToGet: 1) { (wrappedReturnedUsers, getRandomUsersErrorDescriptor) in
            if let returnedUsers = wrappedReturnedUsers {
                UserSerializer().getUser(withIdentifier: returnedUsers[0]) { (wrappedReturnedUser, getUserError) in
                    if let returnedUser = wrappedReturnedUser {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                            PKHUD.sharedHUD.contentView = PKHUDProgressView(title: nil, subtitle: "Found! Signing in...")
                            PKHUD.sharedHUD.show(onView: self.view)
                            
                            PKHUD.sharedHUD.hide(afterDelay: 0.5) { success in
                                currentUser = returnedUser
                                
                                currentUser!.updateLastActiveDate()
                                
                                accountIdentifier = returnedUser.associatedIdentifier
                                
                                Database.database().reference().child("allUsers").child(currentUser!.associatedIdentifier!).observe(.childChanged) { (returnedSnapshot) in
                                    if returnedSnapshot.key == "openConversations" {
                                        if let openConversations = returnedSnapshot.value as? [String] {
                                            currentUser!.openConversations = openConversations
                                        }
                                    }
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                                    self.performSegue(withIdentifier: "cardFromMainSegue", sender: self)
                                    //self.performSegue(withIdentifier: "welcomeFromMainSegue", sender: self)
                                }
                            }
                        }
                    } else {
                        report(getUserError ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                    }
                }
            } else {
                report(getRandomUsersErrorDescriptor ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
            }
        }
    }
    
    func signInUserWithMatches() {
        UserSerializer().getRandomUsers(amountToGet: 1) { (wrappedReturnedUsers, getRandomUsersErrorDescriptor) in
            if let returnedUsers = wrappedReturnedUsers {
                UserSerializer().getUser(withIdentifier: returnedUsers[0]) { (wrappedUser, getUserErrorDescriptor) in
                    if let returnedUser = wrappedUser {
                        if returnedUser.matches == nil {
                            self.signInUserWithMatches()
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                                PKHUD.sharedHUD.contentView = PKHUDProgressView(title: nil, subtitle: "Found! Signing in...")
                                PKHUD.sharedHUD.show(onView: self.view)
                                
                                PKHUD.sharedHUD.hide(afterDelay: 0.5) { success in
                                    currentUser = returnedUser
                                    
                                    currentUser!.updateLastActiveDate()
                                    
                                    accountIdentifier = returnedUser.associatedIdentifier
                                    
                                    Database.database().reference().child("allUsers").child(currentUser!.associatedIdentifier!).observe(.childChanged) { (returnedSnapshot) in
                                        if returnedSnapshot.key == "openConversations" {
                                            if let openConversations = returnedSnapshot.value as? [String] {
                                                currentUser!.openConversations = openConversations
                                            }
                                        }
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                                        self.performSegue(withIdentifier: "cardFromMainSegue", sender: self)
                                        //self.performSegue(withIdentifier: "welcomeFromMainSegue", sender: self)
                                    }
                                }
                            }
                        }
                    } else {
                        report(getUserErrorDescriptor ?? "An unknown error occurred.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
                    }
                }
            }
        }
    }
}
