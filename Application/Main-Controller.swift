//
//  Main-Controller.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 04/08/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit

//Third-party Frameworks
import PKHUD
import FirebaseAuth
import FirebaseDatabase
import Firebase
import SwiftRandom

class MC: UIViewController, MFMailComposeViewControllerDelegate
{
    //--------------------------------------------------//
    
    /* Interface Builder UI Elements */
    
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
    
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    override var prefersStatusBarHidden:            Bool                 { return false }
    override var preferredStatusBarStyle:           UIStatusBarStyle     { return .lightContent }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .slide }
    
    var buildInstance: Build!
    
    //--------------------------------------------------//
    
    /* Initialiser Function */
    
    func initialiseController()
    {
        //Be sure to change the values below.
        //The build number string when archiving.
        //The code name of the application.
        //The editor header file values.
        //The first digit in the formatted version number.
        //The value of the pre-release application boolean.
        //The value of the prefers status bar boolean.
        
        lastInitialisedController = self
        buildInstance = Build(self)
        currentFile = #file
    }
    
    //--------------------------------------------------//
    
    /* Overridden Functions */
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initialiseController()
        
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.red
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)]
        self.navigationItem.backBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
        
        setBackgroundImage(view, imageName: "Background Image")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            PKHUD.sharedHUD.contentView = PKHUDProgressView(title: nil, subtitle: "Finding User...")
            PKHUD.sharedHUD.show(onView: self.view)
        }
        
        //showProgressHud()
        
        signInUserWithMatches()
        //
        //        if randomInteger(0, maximumValue: 10) % 2 == 0
        //        {
        //            createRandomUser()
        //        }
        
        //        var i = 0
        //        while i < 15
        //        {
        //            createRandomUser()
        //            i += 1
        //        }
    }
    
    func signInUserWithMatches()
    {
        UserSerialiser().getRandomUsers(amountToGet: 1) { (wrappedReturnedUsers, getRandomUsersErrorDescriptor) in
            if let returnedUsers = wrappedReturnedUsers
            {
                UserSerialiser().getUser(withIdentifier: returnedUsers[0]) { (wrappedUser, getUserErrorDescriptor) in
                    if let returnedUser = wrappedUser
                    {
                        if returnedUser.matches == nil
                        {
                            self.signInUserWithMatches()
                        }
                        else
                        {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                                PKHUD.sharedHUD.contentView = PKHUDProgressView(title: nil, subtitle: "Found! Signing in...")
                                PKHUD.sharedHUD.show(onView: self.view)
                                
                                PKHUD.sharedHUD.hide(afterDelay: 0.5) { success in
                                    currentUser = returnedUser
                                    
                                    currentUser!.updateLastActiveDate()
                                    
                                    accountIdentifier = returnedUser.associatedIdentifier
                                    
                                    Database.database().reference().child("allUsers").child(currentUser!.associatedIdentifier!).observe(.childChanged) { (returnedSnapshot) in
                                        if returnedSnapshot.key == "openConversations"
                                        {
                                            if let openConversations = returnedSnapshot.value as? [String]
                                            {
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
                    }
                    else
                    {
                        report(getUserErrorDescriptor ?? "An unknown error occurred.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if informationDictionary["subtitleExpiryString"] == "Evaluation period ended." && preReleaseApplication
        {
            view.addBlur(withActivityIndicator: false, withStyle: .light, withTag: 1)
            view.isUserInteractionEnabled = false
        }
        
        buildInfoController?.view.isHidden = true
    }
    
    //--------------------------------------------------//
    
    /* Interface Builder Actions */
    
    @IBAction func codeNameButton(_ sender: AnyObject)
    {
        buildInstance.codeNameButtonAction()
    }
    
    @IBAction func informationButton(_ sender: AnyObject)
    {
        buildInstance.displayBuildInformation()
    }
    
    @IBAction func sendFeedbackButton(_ sender: Any)
    {
        PresentationManager().feedbackController(withFileName: #file)
    }
    
    @IBAction func subtitleButton(_ sender: Any)
    {
        buildInstance.subtitleButtonAction(withButton: sender as! UIButton)
    }
    
    //--------------------------------------------------//
    
    /* Independent Functions */
    
    func createAccount(email: String, password: String, orderedUserMetaData: [Any], completionHandler: @escaping(_ returnedUser: User?, _ errorDescriptor: String?) -> Void)
    {
        guard let firstName           = orderedUserMetaData[0] as? String    else { completionHandler(nil, "Improperly formatted metadata."); return }
        guard let lastName            = orderedUserMetaData[1] as? String    else { completionHandler(nil, "Improperly formatted metadata."); return }
        guard let phoneNumber         = orderedUserMetaData[2] as? String    else { completionHandler(nil, "Improperly formatted metadata."); return }
        guard let userData            = orderedUserMetaData[3] as? UserData  else { completionHandler(nil, "Improperly formatted metadata."); return }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (wrappedReturnedUser, wrappedReturnedError) in
            if let returnedError = wrappedReturnedError
            {
                completionHandler(nil, errorInformation(forError: (returnedError as NSError)))
            }
            else
            {
                if let returnedUser = wrappedReturnedUser
                {
                    UserSerialiser().createUser(associatedIdentifier: returnedUser.user.uid, emailAddress: email, firstName: firstName, lastName: lastName, userData: userData, phoneNumber: phoneNumber) { (wrappedUser, createUserErrorDescriptor) in
                        if let returnedUser = wrappedUser
                        {
                            completionHandler(returnedUser, nil)
                        }
                        else
                        {
                            completionHandler(nil, createUserErrorDescriptor ?? "An unknown error occurred.")
                        }
                    }
                }
                else
                {
                    completionHandler(nil, "No error, but no returned user either.")
                }
            }
        })
    }
    
    func createRandomUser()
    {
        var imageArray: [UIImage] = [UIImage(named: "download.jpg")!]
        
        var iterator = 0;
        
        while iterator < 29
        {
            iterator += 1;
            imageArray.append(UIImage(named: "download-\(iterator).jpg")!)
        }
        
        var lookingForArray = ["relationship", "something casual", "study buddy", "workout partner", "roommate", "friend", "nothing in particular"]
        lookingForArray = lookingForArray.shuffledValue
        lookingForArray = Array(lookingForArray[0...randomInteger(0, maximumValue: lookingForArray.count - 1)])
        if lookingForArray.count > 1 && lookingForArray.contains("nothing in particular")
        {
            lookingForArray.remove(at: lookingForArray.firstIndex(of: "nothing in particular")!)
        }
        
        let majorArray = ["MET", "Computer science", "Applied math", "Media studies", "Gender & women studies", "Nicotine studies", "Linguistics", "Bioengineering", "Haas", "Environmental econ.", "Polisci"]
        
        var sportsArray = ["Baseball", "Basketball", "Football", "Fencing", "Tennis", "Golf", "Volleyball", "Soccer", "Skiiing", "Surfing"]
        sportsArray = sportsArray.shuffledValue
        sportsArray = Array(sportsArray[0...randomInteger(0, maximumValue: 3)])
        
        let randomDate = masterDateFormatter.date(from: "\(randomInteger(1995, maximumValue: 2002))-01-\(randomInteger(1, maximumValue: 27))")
        
        let userData = UserData(avatarImageData: imageArray.chooseOne.jpegData(compressionQuality: 0.5)?.base64EncodedString(),
                                bioText: Randoms.randomFakeConversation(),
                                birthDate: randomDate!,
                                callsHome: randomInteger(0, maximumValue: 1) == 1 ? Randoms.randomFakeCity() : nil,
                                gender: randomInteger(0, maximumValue: 2),
                                greekLifeOrganisation: randomInteger(0, maximumValue: 1) == 1 ? "ΠΚΦ" : nil,
                                lastActiveDate: Date(),
                                lookingFor: lookingForArray,
                                major: majorArray.chooseOne,
                                profileImageData: ([imageArray.chooseOne.jpegData(compressionQuality: 0.5)?.base64EncodedString(), imageArray.chooseOne.jpegData(compressionQuality: 0.5)?.base64EncodedString()] as! [String]),
                                sexualPreference: 2,
                                sports: randomInteger(0, maximumValue: 1) == 1 ? sportsArray : nil,
                                studentType: randomInteger(0, maximumValue: 2),
                                yearCode: randomInteger(0, maximumValue: 5),
                                yearExplanation: nil)
        
        let randomName = Randoms.randomFakeName()
        
        let randomFirstNameStringCharacters = randomName.components(separatedBy: " ")[0].stringCharacters
        let randomLastNameStringCharacters = randomName.components(separatedBy: " ")[1].stringCharacters
        
        let randomFirstName = "\(randomFirstNameStringCharacters[0...randomInteger(1, maximumValue: randomFirstNameStringCharacters.count - 1)].joined())\(randomLastNameStringCharacters.shuffledValue.joined().lowercased())"
        
        let consonants = "bcdfghjklmnpqrstvwxyz".stringCharacters
        let vowels = "aeiou".stringCharacters
        
        let thing = randomFirstName.stringCharacters[0...randomInteger(1, maximumValue: randomFirstName.length - 1)]
        var random: String!
        
        if consonants.contains(thing.last!.lowercased())
        {
            random = randomFirstName.stringCharacters[0...randomInteger(1, maximumValue: randomFirstName.length - 1)].joined() + vowels.chooseOne
        }
        else
        {
            random = randomFirstName.stringCharacters[0...randomInteger(1, maximumValue: randomFirstName.length - 1)].joined() + consonants.chooseOne + vowels.chooseOne
        }
        
        let metadata: [Any] = ["\(randomName.components(separatedBy: " ")[0])\(vowels.chooseOne)\(consonants.chooseOne)\(vowels.chooseOne)", random!, "818-555-5555", userData]
        
        self.createAccount(email: "\(random.lowercased())@yosemite.app", password: "123456", orderedUserMetaData: metadata) { (wrappedUser, createAccountError) in
            if let returnedUser = wrappedUser
            {
                print(returnedUser.associatedIdentifier!)
            }
            else
            {
                AlertKit().errorAlertController(title: "Create User Failed",
                                                message: createAccountError,
                                                dismissButtonTitle: nil,
                                                additionalSelectors: ["Fine": #selector(MC.goToWelcome)],
                                                preferredAdditionalSelector: 0,
                                                canFileReport: true,
                                                extraInfo: createAccountError,
                                                metadata: [#file, #function, #line],
                                                networkDependent: true)
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        buildInstance.handleMailComposition(withController: controller, withResult: result, withError: error)
    }
    
    //--------------------------------------------------//
    
    /* Selector Functions */
    
    @objc func goToWelcome()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.performSegue(withIdentifier: "welcomeFromMainSegue", sender: self)
        }
    }
}
