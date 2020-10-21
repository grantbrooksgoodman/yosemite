//
//  Main-Controller.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 04/08/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import AVFoundation
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
    
    @IBOutlet weak var needLabel: UILabel!
    @IBOutlet weak var fillLabel: UILabel!
    @IBOutlet weak var getLabel: UILabel!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    let rowTitles = ["studdy buddy", "roommate", "something casual", "relationship", "friend", "workout partner", "it"]
    let rowColours: [UIColor] = [.orange, .green, .systemPink, .red, .blue, .brown, .white]
    let delayValues = [0.37, 0.5, 0.5, 0.2, 0.13, 0.25, 0.4, 0.5, 0.2, 0.3, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2]
    
    override var prefersStatusBarHidden:            Bool                 { return false }
    override var preferredStatusBarStyle:           UIStatusBarStyle     { return .lightContent }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .slide }
    
    var buildInstance: Build!
    
    var currentFrame = 0
    var adTimer: Timer?
    var position = 0
    
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
    }
    
    //--------------------------------------------------//
    
    /* Overridden Functions */
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initialiseController()
        
        //animateAd()
        
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.red
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)]
        self.navigationItem.backBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
        
        //setBackgroundImage(view, imageName: "Background Image")
        view.backgroundColor = .black
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            PKHUD.sharedHUD.contentView = PKHUDProgressView(title: nil, subtitle: "Finding User...")
            PKHUD.sharedHUD.show(onView: self.view)
        }
        
        //showProgressHud()
        
        //signInUserWithMatches()
        signInRandomUser()
        
        if randomInteger(0, maximumValue: 10) % 2 == 0
        {
            createRandomUser()
        }
        
        //        var i = 0
        //        while i < 15
        //        {
        //            createRandomUser()
        //            i += 1
        //        }
    }
    
    func signInRandomUser()
    {
        UserSerialiser().getRandomUsers(amountToGet: 1) { (wrappedReturnedUsers, getRandomUsersErrorDescriptor) in
            if let returnedUsers = wrappedReturnedUsers
            {
                UserSerialiser().getUser(withIdentifier: returnedUsers[0]) { (wrappedReturnedUser, getUserError) in
                    if let returnedUser = wrappedReturnedUser
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
                    else
                    {
                        report(getUserError ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                    }
                }
            }
            else
            {
                report(getRandomUsersErrorDescriptor ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
            }
        }
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
            view.addBlur(withActivityIndicator: false, withStyle: .light, withTag: 1, alpha: 1)
            view.isUserInteractionEnabled = false
        }
        
        currentFile = #file
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
        guard let factoidData        = orderedUserMetaData[0] as? FactoidData    else { completionHandler(nil, "Improperly formatted metadata."); return }
        guard let userData           = orderedUserMetaData[1] as? UserData    else { completionHandler(nil, "Improperly formatted metadata."); return }
        guard let firstName           = orderedUserMetaData[2] as? String    else { completionHandler(nil, "Improperly formatted metadata."); return }
        guard let lastName            = orderedUserMetaData[3] as? String    else { completionHandler(nil, "Improperly formatted metadata."); return }
        guard let phoneNumber         = orderedUserMetaData[4] as? String    else { completionHandler(nil, "Improperly formatted metadata."); return }
        
        var questionsAnswered: [String:String]?
        
        if let unwrappedQuestionsAnswered = orderedUserMetaData[5] as? [String:String],
            unwrappedQuestionsAnswered != ["!":"!"]
        {
            questionsAnswered = unwrappedQuestionsAnswered
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (wrappedReturnedUser, wrappedReturnedError) in
            if let returnedError = wrappedReturnedError
            {
                completionHandler(nil, errorInformation(forError: (returnedError as NSError)))
            }
            else
            {
                if let returnedUser = wrappedReturnedUser
                {
                    UserSerialiser().createUser(associatedIdentifier: returnedUser.user.uid,
                                                emailAddress: email,
                                                factoidData: factoidData,
                                                userData: userData,
                                                firstName: firstName,
                                                lastName: lastName,
                                                phoneNumber: phoneNumber,
                                                questionsAnswered: questionsAnswered) { (wrappedUser, createUserErrorDescriptor) in
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
        
        //gender, major, year code, year ex.
        
        let quickFacts: [String:Any] = ["gender": randomInteger(0, maximumValue: 2), "major": majorArray.chooseOne, "yearCode": randomInteger(0, maximumValue: 5), "yearExplanation": "!"]
        
        let homeShown = Randoms.randomBool()
        let gloShown = Randoms.randomBool()
        let sportsShown = Randoms.randomBool()
        
        let willBeShown = [homeShown, gloShown, sportsShown]
        
        var shuffled = [0, 1, 2]
        
        for item in willBeShown
        {
            if item == false
            {
                shuffled.removeLast()
            }
        }
        
        shuffled = shuffled.shuffled()
        
        let homePosition = homeShown ? shuffled.randomElement() ?? 0 : 9
        
        shuffled = shuffled.filter({$0 != homePosition})
        
        let gloPosition = gloShown ? shuffled.randomElement() ?? 0 : 9
        
        shuffled = shuffled.filter({$0 != homePosition && $0 != gloPosition})
        
        let sportsPosition = sportsShown ? shuffled.randomElement() ?? 0 : 9
        
        let callsHome = homeShown ? ((homePosition, false), Randoms.randomFakeCity()) : nil
        let glo = gloShown ? ((gloPosition, false), "ΑΒΞΔΕΦΓΗΚΛΜΝΠΘΡΣΤΥΩΧΨΖ".map({String($0)}).shuffled()[0...2].joined()) : nil
        let sports = sportsShown ? ((sportsPosition, false), sportsArray) : nil
        
        let factoidData = FactoidData(callsHome: callsHome,
                                      greekLifeOrganisation: glo,
                                      lookingFor: lookingForArray[0] == "nothing in particular" ? nil : lookingForArray,
                                      quickFacts: quickFacts,
                                      sports: sports)
        
        let userData = UserData(bioText: Randoms.randomFakeConversation(),
                                birthDate: randomDate!,
                                lastActiveDate: Date(),
                                profileImageData: ([imageArray.chooseOne.jpegData(compressionQuality: 0.5)?.base64EncodedString(), imageArray.chooseOne.jpegData(compressionQuality: 0.5)?.base64EncodedString()] as! [String]),
                                sexualPreference: 2,
                                studentType: randomInteger(0, maximumValue: 2))
        
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
        
        let metadata: [Any] = [factoidData, userData, "\(randomName.components(separatedBy: " ")[0])\(vowels.chooseOne)\(consonants.chooseOne)\(vowels.chooseOne)", random!, "818-555-5555", ["Who do you think you are?":"YOUR MOM", "It's a perfect match if": Randoms.randomFakeName()]]
        
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
    
    func animateAd()
    {
        pickerView.alpha = 0
        fillLabel.alpha = 0
        getLabel.alpha = 0
        needLabel.alpha = 0
        
        if let soundURL = Bundle.main.url(forResource: "lovesick(2)", withExtension: "m4a")
        {
            var playableSound: SystemSoundID = 0
            
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &playableSound)
            AudioServicesPlaySystemSound(playableSound)
        }
        
        adTimer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(MC.advanceFrame), userInfo: nil, repeats: true)
    }
    
    @objc func advanceFrame()
    {
        //relationship
        //something casual
        //study buddy
        //workout partner
        //roommate
        //friend
        //cuffing season date
        
        UIView.animate(withDuration: 0.2, delay: 0.2, options: [], animations: {
            self.needLabel.alpha = 1
            self.pickerView.alpha = 1
        })
        
        if currentFrame < 7 && adTimer?.timeInterval == 0.8
        {
            pickerView.selectRow(currentFrame, inComponent: 0, animated: true)
            needLabel.textColor = rowColours[currentFrame]
            getLabel.textColor = rowColours[currentFrame]
            
            currentFrame += 1
        }
        else
        {
            self.getLabel.alpha = 1
            
            adTimer?.invalidate()
            adTimer = nil
            adTimer = Timer.scheduledTimer(timeInterval: delayValues[position], target: self, selector: #selector(MC.advanceFrame), userInfo: nil, repeats: true)
            
            if position == 16
            {
                position = 0
            }
            else
            {
                position += 1
            }
            
            if currentFrame == 0
            {
                currentFrame = 6
            }
            else
            {
                currentFrame -= 1
            }
            
            pickerView.selectRow(currentFrame, inComponent: 0, animated: false)
            needLabel.textColor = rowColours[currentFrame]
            getLabel.textColor = rowColours[currentFrame]
        }
    }
    
    //    func animateAppearance(of labels: [UILabel], with colour: UIColor)
    //    {
    //        UIView.animate(withDuration: 0.15) {
    //            for label in labels
    //            {
    //                label.textColor = colour
    //                label.alpha = 1
    //            }
    //        }
    //    }
    
    //--------------------------------------------------//
    
    /* Selector Functions */
    
    @objc func goToWelcome()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.performSegue(withIdentifier: "welcomeFromMainSegue", sender: self)
        }
    }
}

extension MC: UIPickerViewDataSource, UIPickerViewDelegate
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return 7
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return 80
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        var pickerLabel = view as? UILabel
        
        if pickerLabel == nil
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "AppleGaramond", size: 40)
            pickerLabel?.textAlignment = .center
        }
        
        pickerLabel?.textColor = rowColours[row]
        
        pickerLabel?.text = rowTitles[row]
        
        pickerLabel?.adjustsFontSizeToFitWidth = true
        
        return pickerLabel!
    }
}
