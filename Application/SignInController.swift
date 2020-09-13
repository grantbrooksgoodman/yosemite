//
//  SignInController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 16/06/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit

//Third-party Frameworks
import FirebaseAuth

class SignInController: UIViewController, MFMailComposeViewControllerDelegate
{
    //--------------------------------------------------//
    
    /* Interface Builder UI Elements */
    
    //ShadowButtons
    @IBOutlet weak var backButton:           ShadowButton!
    @IBOutlet weak var signInButton:         ShadowButton!
    
    //UIButtons
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    //UITextFields
    @IBOutlet weak var eMailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //Other Elements
    @IBOutlet weak var signInLabel: TranslatedLabel!
    @IBOutlet weak var textFieldEncapsulatingView: UIView!
    
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    //CGFloats
    var originalButtonYOrigin:                     CGFloat!
    var originalSignInLabelYOrigin:                CGFloat!
    var originalTextFieldEncapsulatingViewYOrigin: CGFloat!
    
    //Other Declarations
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
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        eMailTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initialiseController()
        
        //Add a rounded border to the «textFieldEncapsulatingView».
        textFieldEncapsulatingView.layer.borderWidth  = 2
        textFieldEncapsulatingView.layer.cornerRadius = 10
        
        textFieldEncapsulatingView.layer.borderColor = UIColor(hex: 0xE1E0E1).cgColor
        
        textFieldEncapsulatingView.clipsToBounds       = true
        textFieldEncapsulatingView.layer.masksToBounds = true
        
        backButton.initialiseLayer(animateTouches: true,
                                   backgroundColour: UIColor(hex: 0xE95A53),
                                   customBorderFrame: nil,
                                   customCornerRadius: nil,
                                   shadowColour: UIColor(hex: 0xD5443B).cgColor,
                                   instanceName: nil)
        
        signInButton.initialiseLayer(animateTouches: true,
                                     backgroundColour: UIColor(hex: 0x60C129),
                                     customBorderFrame: nil,
                                     customCornerRadius: nil,
                                     shadowColour: UIColor(hex: 0x3B9A1B).cgColor,
                                     instanceName: nil)
        
        //Set appropriate tags for each text field.
        eMailTextField.tag    = aTagFor("eMailTextField")
        passwordTextField.tag = aTagFor("passwordTextField")
        
        //Add keyboard appearance Observer.
        NotificationCenter.default.addObserver(self, selector: #selector(SignInController.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        originalButtonYOrigin = signInButton.frame.origin.y
        originalSignInLabelYOrigin = signInLabel.frame.origin.y
        originalTextFieldEncapsulatingViewYOrigin = textFieldEncapsulatingView.frame.origin.y
        
        forgotPasswordButton.layer.borderColor = UIColor.systemBlue.cgColor
        forgotPasswordButton.layer.borderWidth = 1.5
        forgotPasswordButton.layer.cornerRadius = forgotPasswordButton.frame.size.width / 2
        forgotPasswordButton.layer.masksToBounds = false
        
        #warning("FOR DEBUG ONLY")
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(350)) {
            UserSerialiser().getRandomUsers(amountToGet: 1) { (wrappedUserIdentifiers, getRandomUsersErrorDescriptor) in
                if let userIdentifiers = wrappedUserIdentifiers
                {
                    UserSerialiser().getUser(withIdentifier: userIdentifiers[0]) { (wrappedUser, getUserErrorDescriptor) in
                        if let returnedUser = wrappedUser
                        {
                            self.eMailTextField.text = returnedUser.emailAddress
                            self.passwordTextField.text = "123456"
                        }
                        else
                        {
                            report(getUserErrorDescriptor ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                        }
                    }
                }
                else
                {
                    report(getRandomUsersErrorDescriptor ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        buildInfoController?.view.isHidden = false
    }
    
    //--------------------------------------------------//
    
    /* Interface Builder Actions */
    
    @IBAction func backButton(_ sender: Any)
    {
        performSegue(withIdentifier: "welcomeFromSignInSegue", sender: self)
    }
    
    @IBAction func sendFeedbackButton(_ sender: Any)
    {
        PresentationManager().feedbackController(withFileName: #file)
    }
    
    @IBAction func signInButton(_ sender: Any)
    {
        //If the e-mail and password text fields aren't blank.
        if eMailTextField.text!.noWhiteSpaceLowerCaseString != "" && passwordTextField.text!.noWhiteSpaceLowerCaseString != ""
        {
            //If the e-mail text field contains a valid e-mail address.
            if isValidEmail(eMailTextField.text!)
            {
                //If the password is 6 or more characters long.
                if passwordTextField.text!.length > 5
                {
                    //Dismiss the keyboard.
                    findAndResignFirstResponder()
                    
                    //Remove the keyboard appearance Observer.
                    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
                    
                    signIn()
                }
                else //The password is not long enough.
                {
                    PresentationManager().errorAlertController(withTitle: "Invalid Password Length", withMessage: "Passwords must be 6 characters at minimum. Please try again.", extraneousInformation: nil, withCancelButtonTitle: nil, withAlternateSelectors: nil, preferredActionIndex: nil, withFileName: #file, withLineNumber: #line, withFunctionTitle: #function, networkDependent: false, canFileReport: false)
                }
            }
            else //The e-mail address is invalid.
            {
                PresentationManager().errorAlertController(withTitle: "Invalid E-Mail", withMessage: "The e-mail you entered appears to be invalid. Please correct it and try again.", extraneousInformation: nil, withCancelButtonTitle: nil, withAlternateSelectors: nil, preferredActionIndex: nil, withFileName: #file, withLineNumber: #line, withFunctionTitle: #function, networkDependent: false, canFileReport: true)
            }
        }
        else //All fields must be evaluated.
        {
            PresentationManager().errorAlertController(withTitle: "Evaluate All Fields", withMessage: "All fields must be evaluated before you can continue.", extraneousInformation: nil, withCancelButtonTitle: nil, withAlternateSelectors: nil, preferredActionIndex: nil, withFileName: #file, withLineNumber: #line, withFunctionTitle: #function, networkDependent: false, canFileReport: false)
        }
    }
    
    //--------------------------------------------------//
    
    /* Independent Functions */
    
    /**
     Determines whether a given String is a valid e-mail address or not.
     
     - Parameter withString: The String whose e-mail address status will be determined.
     */
    func isValidEmail(_ withString: String) -> Bool
    {
        return NSPredicate(format:"SELF MATCHES[c] %@", "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$").evaluate(with: withString)
    }
    
    /**
     Called when the keyboard begins displaying.
     
     - Parameter withNotification: The Notification calling the function.
     */
    @objc func keyboardDidShow(_ withNotification: Notification)
    {
        //Get the keyboard's frame.
        if let keyboardFrame: NSValue = withNotification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        {
            //Convert the keyboard frame to a CGRect.
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            //Get the point where the keyboard begins.
            let minimumValue = keyboardRectangle.origin.y
            
            //If the keyboard obscures part of the view.
            if minimumValue < signInButton.frame.maxY + 10
            {
                //While the keyboard obscures part of the view.
                while minimumValue < signInButton.frame.maxY + 10
                {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.backButton.frame.origin.y -= 1
                        self.signInButton.frame.origin.y -= 1
                        self.signInLabel.frame.origin.y -= 1
                        self.textFieldEncapsulatingView.frame.origin.y -= 1
                    })
                }
            }
            else //If the keyboard does not obscure the view.
            {
                UIView.animate(withDuration: 0.3, animations: {
                    self.backButton.frame.origin.y = self.originalButtonYOrigin
                    self.signInButton.frame.origin.y = self.originalButtonYOrigin
                    self.signInLabel.frame.origin.y = self.originalSignInLabelYOrigin
                    self.textFieldEncapsulatingView.frame.origin.y = self.originalTextFieldEncapsulatingViewYOrigin
                })
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        buildInstance.handleMailComposition(withController: controller, withResult: result, withError: error)
    }
    
    func signIn()
    {
        Auth.auth().signIn(withEmail: eMailTextField.text!, password: passwordTextField.text!) { (wrappedResult, signInError) in
            if let returnedResult = wrappedResult
            {
                GenericSerialiser().isShelter(withIdentifier: returnedResult.user.uid) { (isShelter) in
                    if isShelter
                    {
                        print("it's a shelter... UNIMPLIMENTED")
                    }
                    else
                    {
                        accountIdentifier = returnedResult.user.uid
                        
                        UserSerialiser().getUser(withIdentifier: returnedResult.user.uid) { (wrappedUser, getUserErrorDescriptor) in
                            if let returnedUser = wrappedUser
                            {
                                currentUser = returnedUser
                                
                                self.performSegue(withIdentifier: "cardFromSignInSegue", sender: self)
                            }
                            else
                            {
                                if getUserErrorDescriptor!.hasPrefix("No user exists")
                                {
                                    PresentationManager().errorAlertController(withTitle: "Invalid Credentials",
                                                                               withMessage: "No user exists with that e-mail address. Please try again.",
                                                                               extraneousInformation: nil,
                                                                               withCancelButtonTitle: nil,
                                                                               withAlternateSelectors: nil,
                                                                               preferredActionIndex: nil,
                                                                               withFileName: #file,
                                                                               withLineNumber: #line,
                                                                               withFunctionTitle: #function,
                                                                               networkDependent: true,
                                                                               canFileReport: false)
                                    
                                    self.eMailTextField.becomeFirstResponder()
                                }
                                else
                                {
                                    PresentationManager().errorAlertController(withTitle: nil,
                                                                               withMessage: nil,
                                                                               extraneousInformation: getUserErrorDescriptor!,
                                                                               withCancelButtonTitle: nil,
                                                                               withAlternateSelectors: nil,
                                                                               preferredActionIndex: nil,
                                                                               withFileName: #file,
                                                                               withLineNumber: #line,
                                                                               withFunctionTitle: #function,
                                                                               networkDependent: true,
                                                                               canFileReport: true)
                                    
                                    self.eMailTextField.becomeFirstResponder()
                                }
                                
                                report(getUserErrorDescriptor ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                            }
                        }
                    }
                }
            }
            else if let returnedError = signInError
            {
                if returnedError.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted."
                {
                    PresentationManager().errorAlertController(withTitle: "Invalid Credentials",
                                                               withMessage: "No user exists with that e-mail address. Please try again.",
                                                               extraneousInformation: nil,
                                                               withCancelButtonTitle: nil,
                                                               withAlternateSelectors: nil,
                                                               preferredActionIndex: nil,
                                                               withFileName: #file,
                                                               withLineNumber: #line,
                                                               withFunctionTitle: #function,
                                                               networkDependent: true,
                                                               canFileReport: false)
                    
                    self.eMailTextField.becomeFirstResponder()
                }
                else if returnedError.localizedDescription == "The password is invalid or the user does not have a password."
                {
                    PresentationManager().errorAlertController(withTitle: "Invalid Credentials",
                                                               withMessage: "The password was incorrect. Please try again.",
                                                               extraneousInformation: nil,
                                                               withCancelButtonTitle: nil,
                                                               withAlternateSelectors: nil,
                                                               preferredActionIndex: nil,
                                                               withFileName: #file,
                                                               withLineNumber: #line,
                                                               withFunctionTitle: #function,
                                                               networkDependent: true,
                                                               canFileReport: false)
                    
                    self.passwordTextField.becomeFirstResponder()
                }
                else
                {
                    PresentationManager().errorAlertController(withTitle: nil,
                                                               withMessage: nil,
                                                               extraneousInformation: returnedError.localizedDescription,
                                                               withCancelButtonTitle: nil,
                                                               withAlternateSelectors: nil,
                                                               preferredActionIndex: nil,
                                                               withFileName: #file,
                                                               withLineNumber: #line,
                                                               withFunctionTitle: #function,
                                                               networkDependent: true,
                                                               canFileReport: true)
                    
                    self.eMailTextField.becomeFirstResponder()
                }
                
                report(returnedError.localizedDescription, errorCode: (returnedError as NSError).code, isFatal: false, metadata: [#file, #function, #line])
            }
            else
            {
                report("An unknown error occurred.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
            }
        }
    }
}

extension SignInController: UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        //If the user is trying to insert a space.
        if string != string.components(separatedBy: NSCharacterSet(charactersIn: " ") as CharacterSet).joined(separator: "")
        {
            //If the text field is «eMailTextField».
            if textField.keyboardType == .emailAddress
            {
                //Don't allow a space to be inserted.
                return false
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField.tag == aTagFor("eMailTextField") //If the text field returning is «eMailTextField».
        {
            //Make «passwordTextField» the first responder.
            passwordTextField.becomeFirstResponder()
        }
        else if textField.tag == aTagFor("passwordTextField") //If the text field returning is «passwordTextField».
        {
            //Dismiss the keyboard.
            findAndResignFirstResponder()
            
            UIView.animate(withDuration: 0.3, animations: {
                self.backButton.frame.origin.y = self.originalButtonYOrigin
                self.signInButton.frame.origin.y = self.originalButtonYOrigin
                self.signInLabel.frame.origin.y = self.originalSignInLabelYOrigin
                self.textFieldEncapsulatingView.frame.origin.y = self.originalTextFieldEncapsulatingViewYOrigin
            }) { (_) in
                self.signInButton(self.signInButton!)
            }
        }
        
        return true
    }
}
