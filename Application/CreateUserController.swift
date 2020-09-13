//
//  CreateUserController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 14/05/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

//Third-party Frameworks
import PhoneNumberKit

class CUC: UIViewController
{
    //--------------------------------------------------//
    
    /* Interface Builder UI Elements */
    
    //UITextFields
    @IBOutlet weak var eMailTextField:       UITextField!
    @IBOutlet weak var firstNameTextField:   UITextField!
    @IBOutlet weak var lastNameTextField:    UITextField!
    @IBOutlet weak var passwordTextField:    UITextField!
    @IBOutlet weak var postalCodeTextField:  UITextField!
    
    //Other Elements
    @IBOutlet weak var doneButton: ShadowButton!
    @IBOutlet weak var phoneNumberTextField: PhoneNumberTextField!
    @IBOutlet weak var textFieldEncapsulatingView: UIView!
    
    @IBOutlet weak var backButton: ShadowButton!
    
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    var originalInstructionTextViewFrame: CGRect!
    var originalInstructionTextViewFontSize: CGFloat = 14
    
    //--------------------------------------------------//
    
    /* Overridden Functions */
    
    //referencing custom or variables in line documentation = «»
    //referencing apple stuff = Capitalise
    //symbols and numbers come before letters
    
    //referencing custom in function documentation = ****
    //referencing variables in function documentation = **
    //referencing apple stuff = Capitalise
    //symbols and numbers come before letters
    
    //for spacing, line things up when they are of the same type on the right side of the assignment
    
    override func viewDidAppear(_ animated: Bool)
    {
        //Unwrap the «CreateAccountController's» parameters.
        if let createAccountController  = self.parent as? CreateAccountController,
            let instructionTextView     = createAccountController.instructionTextView,
            let instructionTextViewFont = instructionTextView.font
        {
            //Save the «instructionTextView's» original font size and frame before changing anything.
            originalInstructionTextViewFontSize = instructionTextViewFont.pointSize
            originalInstructionTextViewFrame    = instructionTextView.frame
            
            firstNameTextField.becomeFirstResponder()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Properly layout and format the UITextFields.
        let textFieldArray: [UITextField]! = [eMailTextField, firstNameTextField, lastNameTextField, passwordTextField, phoneNumberTextField, postalCodeTextField]
        
        for individualTextField in textFieldArray
        {
            individualTextField.addTarget(self, action: #selector(CUC.textFieldDidChange), for: .editingChanged)
            individualTextField.adjustsFontSizeToFitWidth = true
            individualTextField.tintColor = UIColor(hex: 0x0097EF)
        }
        
        //Set appropriate tags for each text field.
        eMailTextField.tag       = aTagFor("eMailTextField")
        firstNameTextField.tag   = aTagFor("firstNameTextField")
        lastNameTextField.tag    = aTagFor("lastNameTextField")
        passwordTextField.tag    = aTagFor("passwordTextField")
        phoneNumberTextField.tag = aTagFor("phoneNumberTextField")
        postalCodeTextField.tag  = aTagFor("postalCodeTextField")
        
        //Add a rounded border to the «textFieldEncapsulatingView».
        textFieldEncapsulatingView.layer.borderWidth  = 2
        textFieldEncapsulatingView.layer.cornerRadius = 10
        
        textFieldEncapsulatingView.layer.borderColor = UIColor(hex: 0xE1E0E1).cgColor
        
        textFieldEncapsulatingView.clipsToBounds       = true
        textFieldEncapsulatingView.layer.masksToBounds = true
        
        #warning("FOR DEBUG ONLY")
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(350), execute: {
            self.firstNameTextField.text   = "Grant"
            self.lastNameTextField.text    = "Brooks Goodman"
            self.eMailTextField.text       = "\(randomInteger(0, maximumValue: 1000000))@grantbrooks.io"
            self.passwordTextField.text    = "123456"
            self.phoneNumberTextField.text = "+1 (516) 361-4836"
            self.postalCodeTextField.text  = "11579"
            
            self.textFieldDidChange()
        })
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        //Set up «doneButton's» attributes.
        doneButton.isEnabled = false
        doneButton.initialiseLayer(animateTouches: true, backgroundColour: UIColor(hex: 0x60C129), customBorderFrame: nil, customCornerRadius: nil, shadowColour: UIColor(hex: 0x3B9A1B).cgColor, instanceName: nil)
        doneButton.initialiseTranslation(allowedToAdjust: true, alternateString: "FINISH", backUp: "DONE", useActivityIndicator: true)
        
        backButton.initialiseLayer(animateTouches: true, backgroundColour: UIColor(hex: 0xE95A53), customBorderFrame: nil, customCornerRadius: nil, shadowColour: UIColor(hex: 0xD5443B).cgColor, instanceName: nil)
        backButton.initialiseTranslation(allowedToAdjust: true, alternateString: nil, backUp: nil, useActivityIndicator: true)
    }
    
    //--------------------------------------------------//
    
    /* Interface Builder Actions */
    @IBAction func backButton(_ sender: Any)
    {
        if let createAccountController = self.parent as? CreateAccountController
        {
            createAccountController.instructionTextView.alpha = 1
            createAccountController.stepProgress(forwardDirection: false)
            createAccountController.backTo(createAccountController.birthdateController,
                                           fromController:  createAccountController.createUserController,
                                           pageTitle:       "Age Verification",
                                           instructionText: "You must be at least 18 years old to legally adopt an animal.")
        }
    }
    
    @IBAction func doneButton(_ sender: Any)
    {
        //If the first and last name text fields aren't blank.
        if firstNameTextField.text!.noWhiteSpaceLowerCaseString != "" && lastNameTextField.text!.noWhiteSpaceLowerCaseString != ""
        {
            //If the e-mail text field contains a valid e-mail address.
            if isValidEmail(eMailTextField.text!)
            {
                //If the password is 6 or more characters long.
                if passwordTextField.text!.length > 5
                {
                    //If the phone number text field contains a valid phone number.
                    if phoneNumberTextField.isValidNumber
                    {
                        //If the postal code text field contains a valid postal code.
                        if isValidZipCode(postalCodeTextField.text!)
                        {
                            //Dismiss the keyboard.
                            findAndResignFirstResponder()
                            
                            //Remove the keyboard appearance Observer.
                            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
                            
                            if let createAccountController = self.parent as? CreateAccountController
                            {
                                createAccountController.instructionTextView.alpha = 1
                                createAccountController.stepProgress(forwardDirection: true)
                                createAccountController.presentEmploymentController()
                            }
                        }
                        else //The postal code is invalid.
                        {
                            PresentationManager().errorAlertController(withTitle: "Invalid ZIP", withMessage: "The postal code you entered appears to be invalid. Please correct it and try again.", extraneousInformation: nil, withCancelButtonTitle: nil, withAlternateSelectors: nil, preferredActionIndex: nil, withFileName: #file, withLineNumber: #line, withFunctionTitle: #function, networkDependent: false, canFileReport: true)
                        }
                    }
                    else //The phone number is invalid.
                    {
                        PresentationManager().errorAlertController(withTitle: "Invalid Number", withMessage: "The phone number you entered appears to be invalid. Please correct it and try again.", extraneousInformation: nil, withCancelButtonTitle: nil, withAlternateSelectors: nil, preferredActionIndex: nil, withFileName: #file, withLineNumber: #line, withFunctionTitle: #function, networkDependent: false, canFileReport: true)
                    }
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
     Determines whether a given String is a valid United States postal code or not.
     
     - Parameter withString: The String whose postal code status will be determined.
     */
    func isValidZipCode(_ withString: String) -> Bool
    {
        return NSPredicate(format: "SELF MATCHES %@", "^[0-9]{5}(-[0-9]{4})?$").evaluate(with: withString)
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
            
            //Unwrap the «CreateAccountController's» parameters.
            guard let createAccountController = self.parent as? CreateAccountController else { report("No CreateAccountController.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line]); return }
            
            guard let instructionTextView = createAccountController.instructionTextView else { report("No instructionTextView.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line]); return }
            
            //Get the point where the keyboard begins.
            let minimumValue = keyboardRectangle.origin.y
            
            //If the keyboard obscures part of the view.
            if minimumValue < view.frame.maxY
            {
                //While the keyboard obscures part of the view.
                while minimumValue < view.frame.maxY
                {
                    //If decreasing the «instructionTextView's» font by 1 would make the size less than 10.
                    if instructionTextView.font!.pointSize - 1 < 10
                    {
                        //Hide the «instructionTextView».
                        instructionTextView.alpha = 0
                        
                        //Animate the view's Y origin change.
                        UIView.animate(withDuration: 0.3, animations: {
                            self.view.frame.origin.y = createAccountController.progressView.frame.maxY + 5
                        })
                    }
                    else //If decreasing the «instructionTextView's» font by 1 would not make the size less than 10.
                    {
                        //Decrease the instruction text view's font size by 1.
                        instructionTextView.font = UIFont(name: "SFUIText-Regular", size: instructionTextView.font!.pointSize - 1)
                        
                        //Adjust the instruction text view's frame.
                        instructionTextView.sizeToFit()
                        
                        //Animate the view's Y origin change.
                        UIView.animate(withDuration: 0.3, animations: {
                            self.view.frame.origin.y = instructionTextView.frame.maxY + 5
                        })
                    }
                }
            }
            else //If the keyboard does not obscure the view.
            {
                //If the «instructionTextView's» font size isn't what it originally was.
                if instructionTextView.font!.pointSize != originalInstructionTextViewFontSize
                {
                    //Reset the «instructionTextView's» attributes to default.
                    instructionTextView.font = UIFont(name: "SFUIText-Regular", size: originalInstructionTextViewFontSize)
                    instructionTextView.frame = originalInstructionTextViewFrame
                    instructionTextView.alpha = 1
                    instructionTextView.sizeToFit()
                    
                    //Animate the view's Y origin change.
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.frame.origin.y = instructionTextView.frame.maxY + 5
                    })
                }
            }
        }
    }
    
    ///Called when any UITextField on the view's text changes.
    @objc func textFieldDidChange()
    {
        //Find all instances of empty UITextFields.
        let textFieldArray: [UITextField]! = [eMailTextField, firstNameTextField, lastNameTextField, passwordTextField, phoneNumberTextField, postalCodeTextField]
        
        var isItBlank: [Bool]! = []
        
        for individualTextField in textFieldArray
        {
            isItBlank.append(individualTextField.text!.noWhiteSpaceLowerCaseString == "")
        }
        
        //Enable «doneButton» in the event that all UITextFields have been evaluated.
        doneButton.isEnabled = !isItBlank.contains(true)
    }
}

extension CUC: UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        //If the user is trying to insert a space.
        if string != string.components(separatedBy: NSCharacterSet(charactersIn: " ") as CharacterSet).joined(separator: "")
        {
            //If the text field is «eMailTextField», «phoneNumberTextField», or «postalCodeTextField».
            if textField.keyboardType == .emailAddress || textField.keyboardType == .phonePad || textField.keyboardType == .numberPad
            {
                //Don't allow a space to be inserted.
                return false
            }
        }
        
        //If the text field is «postalCodeTextField» and the user is trying to type more characters than in a valid ZIP code.
        if textField.keyboardType == .numberPad && (textField.text!.length + string.length) > 5
        {
            //Don't allow any further characters to be inserted.
            return false
        }
        
        //If the text field is «postalCodeTextField» and the user is trying to type something other than a number.
        if textField.keyboardType == .numberPad && string != string.components(separatedBy: NSCharacterSet(charactersIn: "0123456789").inverted).joined(separator: "")
        {
            //Don't allow a non-numeric character to be inserted.
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        //If the text field returning is «firstNameTextField».
        if textField.tag == aTagFor("firstNameTextField")
        {
            //Make «lastNameTextField» the first responder.
            lastNameTextField.becomeFirstResponder()
        }
        else if textField.tag == aTagFor("lastNameTextField") //If the text field returning is «lastNameTextField».
        {
            //Make «eMailTextField» the first responder.
            eMailTextField.becomeFirstResponder()
        }
        else if textField.tag == aTagFor("eMailTextField") //If the text field returning is «eMailTextField».
        {
            //Make «passwordTextField» the first responder.
            passwordTextField.becomeFirstResponder()
        }
        else if textField.tag == aTagFor("passwordTextField") //If the text field returning is «passwordTextField».
        {
            //Make «phoneNumberTextField» the first responder.
            phoneNumberTextField.becomeFirstResponder()
        }
        
        return true
    }
}
