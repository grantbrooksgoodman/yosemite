//
//  CreateAccountController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 04/08/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit

//Third-party Frameworks
import Firebase
import FirebaseAuth
import FirebaseDatabase
import PKHUD

class CreateAccountController: UIViewController, MFMailComposeViewControllerDelegate, SSRadioButtonControllerDelegate
{
    //--------------------------------------------------//
    
    /* Interface Builder UI Elements */
    
    //RadioButtons
    @IBOutlet weak var adoptButton:   SSRadioButton!
    @IBOutlet weak var shelterButton: SSRadioButton!
    
    //ShadowButtons
    @IBOutlet weak var backButton:     ShadowButton!
    @IBOutlet weak var continueButton: ShadowButton!
    
    //Other Elements
    @IBOutlet weak var createAccountLabel: TranslatedLabel!
    @IBOutlet weak var instructionTextView: UITextView!
    @IBOutlet weak var progressView: UIProgressView!
    
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    //CGPoints
    var initialBiographicCentre:      CGPoint!
    var initialBirthdateCentre:       CGPoint!
    var initialCreateUserCentre:      CGPoint!
    var initialConfidenceCentre:      CGPoint!
    var initialEmploymentCentre:      CGPoint!
    var initialLivingSituationCentre: CGPoint!
    var initialTraitsCentre:          CGPoint!
    
    //UIViewControllers
    var biographicController:      BiographicController!
    var birthdateController:       BirthdateController!
    var createUserController:      CUC!
    var confidenceController:      ConfidenceController!
    var employmentController:      EmploymentController!
    var livingSituationController: LivingSituationController!
    var traitsController:          TraitsController!
    
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initialiseController()
        
        //Turn on dark mode.
        darkMode = true
        
        //Set appropriate tags for each button.
        adoptButton.tag    = aTagFor("adoptButton")
        backButton.tag     = aTagFor("backButton")
        continueButton.tag = aTagFor("continueButton")
        shelterButton.tag  = aTagFor("shelterButton")
        
        //Set up the «RadioButtonController».
        let radioButtonsController: SSRadioButtonsController?
        radioButtonsController = SSRadioButtonsController(buttons: adoptButton, shelterButton)
        radioButtonsController!.delegate = self
        
        //Add shadow borders to to the view behind the «RadioButtons».
        view.addShadowBorder(backgroundColour: .white, borderColour: UIColor(hex: 0xE1E0E1).cgColor, withFrame: CGRect(x: adoptButton.frame.origin.x - 5, y: adoptButton.frame.origin.y, width: adoptButton.frame.size.width, height: adoptButton.frame.size.height), withTag: aTagFor("adoptButton_BORDER"))
        view.addShadowBorder(backgroundColour: .white, borderColour: UIColor(hex: 0xE1E0E1).cgColor, withFrame: CGRect(x: shelterButton.frame.origin.x - 5, y: shelterButton.frame.origin.y, width: shelterButton.frame.size.width, height: shelterButton.frame.size.height), withTag: aTagFor("shelterButton_BORDER"))
        
        //If there is more than 1 UIActivityIndicator showing on the view, blur the view.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(005)) {
            var indicatorCount = 0
            
            for individualSubview in self.view.subviews
            {
                if individualSubview as? UIActivityIndicatorView != nil
                {
                    indicatorCount += 1
                }
            }
            
            if indicatorCount > 1
            {
                self.view.addBlur(withActivityIndicator: true, withStyle: .light, withTag: aTagFor("BLUR"))
            }
        }
        
        //Get translations for the view.
        Translator().getArrayOfTranslations(fromArray: ["Which of the below options best describes you?", "I would like to adopt an animal", "I represent an animal shelter"], requiresHud: false) { (returnedStrings) in
            DispatchQueue.main.async {
                //Set «instructionTextView's» text and remove its translation progress overlay.
                self.instructionTextView.text = returnedStrings[0]
                
                //Show and properly resize «instructionTextView».
                self.instructionTextView.alpha = 1
                self.instructionTextView.sizeToFit()
                
                //Set the text of «adoptButton» and «shelterButton» to the returned translations, underlined.
                let attributedStringAttributes: [NSAttributedString.Key:Any] = [.font: UIFont(name: "SFUIText-Regular", size: 18)!, .foregroundColor: UIColor.black, .underlineStyle: 1]
                
                let adoptButtonTitle   = NSMutableAttributedString(string: returnedStrings[1], attributes: attributedStringAttributes)
                let shelterButtonTitle = NSMutableAttributedString(string: returnedStrings[2], attributes: attributedStringAttributes)
                
                self.adoptButton.setAttributedTitle(adoptButtonTitle, for: .normal)
                self.shelterButton.setAttributedTitle(shelterButtonTitle, for: .normal)
                
                //Remove «adoptButton» and «shelterButton's» translation progress overlays.
                self.adoptButton.removeTranslationProgressOverlay(fromViewNamed: "adoptButton", oldAlpha: nil)
                self.shelterButton.removeTranslationProgressOverlay(fromViewNamed: "shelterButton", oldAlpha: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                    //Fix the text size on «adoptButton» and «shelterButton».
                    self.fixAttributedTitleSize(forButton: self.adoptButton, withAttributes: attributedStringAttributes)
                    self.fixAttributedTitleSize(forButton: self.shelterButton, withAttributes: attributedStringAttributes)
                    
                    //Remove the blur from the view.
                    self.view.removeBlur(withTag: aTagFor("BLUR"))
                }
            }
        }
        
        //If the translation task takes too long, remove the blur from the view.
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
            self.view.removeBlur(withTag: aTagFor("BLUR"))
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        buildInfoController?.view.isHidden = false
        
        if lastInitialisedController != self
        {
            //Set the view's tag.
            view.tag = aTagFor("createAccountController")
            
            //Force «createAccountLabel» to use word wrapping for line breaks.
            createAccountLabel.lineBreakMode = .byWordWrapping
            
            //Add translation progress overlays to «adoptButton» and «shelterButton».
            if languageCode != "en"
            {
                adoptButton.addTranslationProgressOverlay(toViewNamed: "adoptButton")
                shelterButton.addTranslationProgressOverlay(toViewNamed: "shelterButton")
            }
            
            //Set up the back and forward buttons' attributes.
            backButton.initialiseLayer(animateTouches: true,
                                       backgroundColour: UIColor(hex: 0xE95A53),
                                       customBorderFrame: nil,
                                       customCornerRadius: nil,
                                       shadowColour: UIColor(hex: 0xD5443B).cgColor,
                                       instanceName: nil)
            backButton.initialiseTranslation(allowedToAdjust: true, alternateString: nil, backUp: nil, useActivityIndicator: true)
            
            continueButton.isEnabled = false
            continueButton.initialiseLayer(animateTouches: true,
                                           backgroundColour: UIColor(hex: 0x60C129),
                                           customBorderFrame: nil,
                                           customCornerRadius: nil,
                                           shadowColour: UIColor(hex: 0x3B9A1B).cgColor,
                                           instanceName: nil)
            continueButton.initialiseTranslation(allowedToAdjust: true, alternateString: nil, backUp: nil, useActivityIndicator: true)
            
            //continueButton.frame.origin.x = f.x(16)
            //continueButton.frame.size.width = f.width(343)
        }
    }
    
    //--------------------------------------------------//
    
    /* Interface Builder Actions */
    
    @IBAction func backButton(_ sender: Any)
    {
        stepProgress(forwardDirection: false)
        
        if view.tag == aTagFor("birthdateController")
        {
            backToCreateAccount()
        }
        else if view.tag == aTagFor("createUserController")
        {
            backTo(birthdateController,
                   fromController:  createUserController,
                   pageTitle:       "Age Verification",
                   instructionText: "You must be at least 18 years old to legally adopt an animal.")
        }
        else if view.tag == aTagFor("employmentController")
        {
            backTo(createUserController,
                   fromController:  employmentController,
                   pageTitle:       "Welcome to *Boop*!",
                   instructionText: "Enter the requested information to set up your account.")
        }
        else if view.tag == aTagFor("livingSituationController")
        {
            backTo(employmentController,
                   fromController:  livingSituationController,
                   pageTitle:       "Employment Status",
                   instructionText: "Select the option that best matches your employment status.")
        }
        else if view.tag == aTagFor("confidenceController")
        {
            backTo(livingSituationController,
                   fromController:  confidenceController,
                   pageTitle:       "Type of Home",
                   instructionText: "What type of building best describes your living space?")
        }
        else if view.tag == aTagFor("traitsController")
        {
            backTo(confidenceController,
                   fromController:  traitsController,
                   pageTitle:       "Your Experience",
                   instructionText: "How confident are you about owning an animal?")
        }
        else if view.tag == aTagFor("biographicController")
        {
            backTo(traitsController,
                   fromController: biographicController,
                   pageTitle: "Your Characteristics",
                   instructionText: nil)
        }
        else
        {
            performSegue(withIdentifier: "welcomeFromCreateAccountSegue", sender: self)
        }
    }
    
    @IBAction func continueButton(_ sender: Any)
    {
        //Show progress and disable user interaction while the next screen loads.
        continueButton.addTranslationProgressOverlay(toViewNamed: "continueButton")
        view.isUserInteractionEnabled = false
        
        stepProgress(forwardDirection: true)
        
        if      view.tag == aTagFor("createAccountController")   { presentBirthdateController() }
        else if view.tag == aTagFor("birthdateController")       { presentCreateUserController() }
        else if view.tag == aTagFor("employmentController")      { presentLivingSituationController() }
        else if view.tag == aTagFor("livingSituationController") { presentConfidenceController() }
        else if view.tag == aTagFor("confidenceController")      { presentTraitsController() }
        else if view.tag == aTagFor("traitsController")          { presentBiographicController() }
        else
        {
            continueButton.removeTranslationProgressOverlay(fromViewNamed: "continueButton", oldAlpha: 0)
            
            UIView.animate(withDuration: 0.4, animations: {
                self.backButton.alpha = 0
                self.createAccountLabel.alpha = 0
                self.instructionTextView.alpha = 0
                self.progressView.alpha = 0
                
                self.biographicController.view.alpha = 0
            }) { (_) in
                self.biographicController.willMove(toParent: nil)
                self.biographicController.view.removeFromSuperview()
                self.biographicController.removeFromParent()
                
                let activityIndicator = UIActivityIndicatorView(frame: f.frame(CGRect(x: 0, y: 0, width: 40, height: 40)))
                activityIndicator.center = self.view.center
                activityIndicator.color = .gray
                activityIndicator.style = .large
                activityIndicator.tag = aTagFor("activityIndicator")
                self.view.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                
                //self.createAccount()
            }
        }
    }
    
    @IBAction func radioButtonTouchDown(_ sender: Any)
    {
        //Transform the «RadioButton's» shadow upon touching down.
        if let radioButton = sender as? SSRadioButton
        {
            radioButton.transformShadow(forButtonNamed: radioButton.tag == aTagFor("shelterButton") ? "shelterButton" : "adoptButton", touchingUp: false)
        }
    }
    
    @IBAction func radioButtonTouchUpInside(_ sender: Any)
    {
        //Enable the «continueButton».
        continueButton.isEnabled = true
        
        if let radioButton = sender as? SSRadioButton
        {
            //Transform the «RadioButton's» shadow upon touching down.
            radioButton.transformShadow(forButtonNamed: radioButton.tag == aTagFor("shelterButton") ? "shelterButton" : "adoptButton", touchingUp: true)
            
            //Set the «RadioButtons'» selection statuses appropriately.
            if radioButton.tag == aTagFor("adoptButton")
            {
                adoptButton.isSelected   = true
                shelterButton.isSelected = false
            }
            else
            {
                shelterButton.isSelected = true
                adoptButton.isSelected   = false
            }
        }
    }
    
    @IBAction func sendFeedbackButton(_ sender: Any)
    {
        PresentationManager().feedbackController(withFileName: #file)
    }
    
    //--------------------------------------------------//
    
    //Presentation Functions
    
    func presentBirthdateController()
    {
        //Get the shadow views of «adoptButton» and «shelterButton».
        guard let adoptButtonShadow   = self.view.findSubview(aTagFor("adoptButton_BORDER")) else { report("No adopt button border.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line]); return }
        guard let shelterButtonShadow = self.view.findSubview(aTagFor("shelterButton_BORDER")) else { report("No shelter button border.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line]); return }
        
        //Get all the translations for the «BirthdateController».
        Translator().getArrayOfTranslations(fromArray: ["Age Verification", "You must be at least 18 years old to legally adopt an animal."], requiresHud: false) { (returnedTranslations) in
            DispatchQueue.main.async {
                self.changePageTitle(returnedTranslations[0], englishString: "Age Verification")
                
                //Animate setting «instructionTextView's» text to the translation result.
                UIView.transition(with: self.instructionTextView, duration: 0.35, options: .transitionCrossDissolve, animations: {
                    self.instructionTextView.text = returnedTranslations[1]
                    self.instructionTextView.frame.size.height = f.height(90)
                    self.instructionTextView.frame.size.width = f.width(240)
                    self.instructionTextView.font = UIFont(name: "SFUIText-Regular", size: 15)
                    self.instructionTextView.sizeToFit()
                })
                
                //Add an instance of «BirthdateController» to the view.
                if self.birthdateController == nil
                {
                    self.birthdateController = (self.storyboard!.instantiateViewController(withIdentifier: "BirthdateController") as! BirthdateController)
                    self.finishInstantiatingController(self.birthdateController, withCustomHeight: nil)
                }
                
                //Animate the disappearance of «adoptButton» and «shelterButton» with the appearance of «BirthdateController».
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                    self.continueButton.frame.origin.x = f.x(194)
                    self.continueButton.frame.size.width = f.width(165)
                    
                    //Move «adoptButton» and «shelterButton» off the left side of the screen.
                    let adoptButtonCentre   = self.adoptButton.center
                    let shelterButtonCentre = self.shelterButton.center
                    
                    let screenWidth = UIScreen.main.bounds.size.width
                    
                    self.adoptButton.center   = CGPoint(x: adoptButtonCentre.x - screenWidth, y: adoptButtonCentre.y)
                    self.shelterButton.center = CGPoint(x: shelterButtonCentre.x - screenWidth, y: shelterButtonCentre.y)
                    
                    adoptButtonShadow.center   = CGPoint(x: adoptButtonShadow.center.x - screenWidth, y: adoptButtonShadow.center.y)
                    shelterButtonShadow.center = CGPoint(x: shelterButtonShadow.center.x - screenWidth, y: shelterButtonShadow.center.y)
                    
                    //Move «BirthdateController» onto the screen from the right side.
                    self.birthdateController.view.frame = CGRect(x: 0, y: self.instructionTextView.frame.maxY + 5, width: f.width(375), height: f.height(375))
                    
                }, completion: { finished in
                    self.backButton.alpha = 1
                    
                    //Hide progress and enable user interaction again.
                    self.continueButton.removeTranslationProgressOverlay(fromViewNamed: "continueButton", oldAlpha: 1)
                    self.view.isUserInteractionEnabled = true
                    
                    adoptButtonShadow.removeFromSuperview()
                    shelterButtonShadow.removeFromSuperview()
                    
                    //Update the view's tag to represent the change in presenting view.
                    self.view.tag = aTagFor("birthdateController")
                    self.birthdateController.view.tag = aTagFor("birthdateController")
                    self.initialBirthdateCentre = self.birthdateController.view.center
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        if self.continueButton.titleLabel!.isTruncated
                        {
                            print("it's truncated now")
                        }
                    }
                })
            }
        }
    }
    
    func presentCreateUserController()
    {
        //Get all the translations for the «CreateUserController».
        Translator().getArrayOfTranslations(fromArray: ["Welcome to *Boop*!", "Enter the requested information to set up your account.", "First name", "Last name", "Email", "Password", "Phone number", "Postal code"], requiresHud: false) { (returnedTranslations) in
            DispatchQueue.main.async {
                //Hide progress and enable user interaction again.
                self.continueButton.removeTranslationProgressOverlay(fromViewNamed: "continueButton", oldAlpha: 0)
                self.view.isUserInteractionEnabled = true
                
                self.backButton.alpha = 0
                
                self.changePageTitle(returnedTranslations[0], englishString: "Welcome to Boop!")
                
                //Animate setting «instructionTextView's» text to the translation result.
                UIView.transition(with: self.instructionTextView, duration: 0.35, options: .transitionCrossDissolve, animations: {
                    self.instructionTextView.text = returnedTranslations[1]
                    self.instructionTextView.frame.size.height = 90
                    self.instructionTextView.frame.size.width = 240
                    self.instructionTextView.sizeToFit()
                })
                
                if self.createUserController == nil
                {
                    //Add an instance of «CreateUserController» to the view.
                    self.createUserController = (self.storyboard!.instantiateViewController(withIdentifier: "CUC") as! CUC)
                    self.finishInstantiatingController(self.createUserController, withCustomHeight: 257)
                    
                    //Set «CreateUserController's» text field placeholders to the translation results.
                    self.createUserController.firstNameTextField.placeholder   = returnedTranslations[2]
                    self.createUserController.lastNameTextField.placeholder    = returnedTranslations[3]
                    self.createUserController.eMailTextField.placeholder       = (returnedTranslations[4] == "Email" && languageCode == "en") ? "E-mail address" : returnedTranslations[4]
                    self.createUserController.passwordTextField.placeholder    = returnedTranslations[5]
                    self.createUserController.phoneNumberTextField.placeholder = returnedTranslations[6]
                    self.createUserController.postalCodeTextField.placeholder  = returnedTranslations[7]
                }
                else
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                        self.createUserController.firstNameTextField.becomeFirstResponder()
                    }
                }
                
                //Add keyboard appearance Observer.
                NotificationCenter.default.addObserver(self.createUserController!, selector: #selector(self.createUserController.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
                
                //Animate the disappearance of «BirthdateController» with the appearance of «CreateUserController».
                self.transitionController(fromController: self.birthdateController, toController: self.createUserController, withCustomHeight: 257, withNewTag: aTagFor("createUserController"))
            }
        }
    }
    
    func presentEmploymentController()
    {
        NotificationCenter.default.removeObserver(self.createUserController!, name: UIResponder.keyboardDidShowNotification, object: nil)
        
        //Get all the translations for the «CreateUserController».
        Translator().getArrayOfTranslations(fromArray: ["Employment Status", "Select the option that best matches your employment status.", "Employed", "Unemployed", "Student"], requiresHud: false) { (returnedTranslations) in
            DispatchQueue.main.async {
                self.changePageTitle(returnedTranslations[0], englishString: "Employment Status")
                
                //Animate setting «instructionTextView's» text to the translation result.
                UIView.transition(with: self.instructionTextView, duration: 0.35, options: .transitionCrossDissolve, animations: {
                    self.instructionTextView.text = returnedTranslations[1]
                    self.instructionTextView.frame.size.height = 90
                    self.instructionTextView.frame.size.width = 240
                    self.instructionTextView.font = UIFont(name: "SFUIText-Regular", size: 15)
                    self.instructionTextView.sizeToFit()
                })
                
                if self.employmentController == nil
                {
                    //Add an instance of «EmploymentController» to the view.
                    self.employmentController = (self.storyboard!.instantiateViewController(withIdentifier: "EmploymentController") as! EmploymentController)
                    self.finishInstantiatingController(self.employmentController, withCustomHeight: nil)
                    
                    //Set «EmploymentController's» employment status segmented control titles to the translation results.
                    self.employmentController.employmentStatusSegmentedControl.apportionsSegmentWidthsByContent = true
                    self.employmentController.employmentStatusSegmentedControl.setTitle(returnedTranslations[2].uppercased(), forSegmentAt: 0)
                    self.employmentController.employmentStatusSegmentedControl.setTitle(returnedTranslations[3].uppercased(), forSegmentAt: 1)
                    self.employmentController.employmentStatusSegmentedControl.setTitle(returnedTranslations[4].uppercased(), forSegmentAt: 2)
                }
                
                self.continueButton.isEnabled = (self.employmentController.employmentStatusSegmentedControl.selectedSegmentIndex > -1) || (self.employmentController.somethingElseTextView.text.noWhiteSpaceLowerCaseString != "")
                
                //Add keyboard appearance Observer.
                NotificationCenter.default.addObserver(self.employmentController!, selector: #selector(self.employmentController.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
                
                //Animate the disappearance of «CreateUserController» with the appearance of «EmploymentController».
                self.transitionController(fromController: self.createUserController, toController: self.employmentController, withCustomHeight: nil, withNewTag: aTagFor("employmentController"))
                
                //If the «instructionTextView's» font size isn't what it originally was.
                if self.instructionTextView.font!.pointSize != self.createUserController.originalInstructionTextViewFontSize
                {
                    //Reset the «instructionTextView's» attributes to default.
                    self.instructionTextView.font = UIFont(name: "SFUIText-Regular", size: self.createUserController.originalInstructionTextViewFontSize)
                    self.instructionTextView.frame = self.createUserController.originalInstructionTextViewFrame
                    self.instructionTextView.alpha = 1
                    self.instructionTextView.sizeToFit()
                }
            }}
    }
    
    func presentLivingSituationController()
    {
        NotificationCenter.default.removeObserver(self.employmentController!, name: UIResponder.keyboardDidShowNotification, object: nil)
        
        //Get all the translations for the «LivingSituationController».
        Translator().getArrayOfTranslations(fromArray: ["Type of Home", "What type of building best describes your living space?", "Apartment", "House", "Dormitory"], requiresHud: false) { (returnedTranslations) in
            DispatchQueue.main.async {
                //Hide progress and enable user interaction again.
                self.continueButton.removeTranslationProgressOverlay(fromViewNamed: "continueButton", oldAlpha: nil)
                self.view.isUserInteractionEnabled = true
                
                self.changePageTitle(returnedTranslations[0], englishString: "Type of Home")
                
                //Animate setting «instructionTextView's» text to the translation result.
                UIView.transition(with: self.instructionTextView, duration: 0.35, options: .transitionCrossDissolve, animations: {
                    self.instructionTextView.text = returnedTranslations[1]
                    self.instructionTextView.frame.size.height = 90
                    self.instructionTextView.frame.size.width = 240
                    self.instructionTextView.font = UIFont(name: "SFUIText-Regular", size: 15)
                    self.instructionTextView.sizeToFit()
                })
                
                if self.livingSituationController == nil
                {
                    //Add an instance of «LivingSituationController» to the view.
                    self.livingSituationController = (self.storyboard!.instantiateViewController(withIdentifier: "LivingSituationController") as! LivingSituationController)
                    self.finishInstantiatingController(self.livingSituationController, withCustomHeight: nil)
                    
                    //Set «LivingSituationController's» living situation segmented control titles to the translation results.
                    self.livingSituationController.livingSituationSegmentedControl.apportionsSegmentWidthsByContent = true
                    self.livingSituationController.livingSituationSegmentedControl.setTitle(returnedTranslations[2].uppercased(), forSegmentAt: 0)
                    self.livingSituationController.livingSituationSegmentedControl.setTitle(returnedTranslations[3].uppercased(), forSegmentAt: 1)
                    self.livingSituationController.livingSituationSegmentedControl.setTitle(returnedTranslations[4].uppercased(), forSegmentAt: 2)
                }
                
                self.continueButton.isEnabled = (self.livingSituationController.livingSituationSegmentedControl.selectedSegmentIndex > -1) || (self.livingSituationController.somethingElseTextView.text.noWhiteSpaceLowerCaseString != "")
                
                //Add keyboard appearance Observer.
                NotificationCenter.default.addObserver(self.livingSituationController!, selector: #selector(self.livingSituationController.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
                
                //Animate the disappearance of «EmploymentController» with the appearance of «LivingSituationController».
                self.transitionController(fromController: self.employmentController, toController: self.livingSituationController, withCustomHeight: nil, withNewTag: aTagFor("livingSituationController"))
            }
        }
    }
    
    func presentConfidenceController()
    {
        NotificationCenter.default.removeObserver(self.livingSituationController!, name: UIResponder.keyboardDidShowNotification, object: nil)
        
        //Get all the translations for the «ConfidenceController».
        Translator().getArrayOfTranslations(fromArray: ["Your Experience", "How confident are you about owning an animal?", "Confident", "Not confident", "Somewhat confident", "Very confident", "Please separate your entries with a comma"], requiresHud: false) { (returnedTranslations) in
            DispatchQueue.main.async {
                //Hide progress and enable user interaction again.
                self.continueButton.removeTranslationProgressOverlay(fromViewNamed: "continueButton", oldAlpha: nil)
                self.view.isUserInteractionEnabled = true
                
                self.changePageTitle(returnedTranslations[0], englishString: "Your Experience")
                
                //Animate setting «instructionTextView's» text to the translation result.
                UIView.transition(with: self.instructionTextView, duration: 0.35, options: .transitionCrossDissolve, animations: {
                    self.instructionTextView.text = returnedTranslations[1]
                    self.instructionTextView.frame.size.height = 90
                    self.instructionTextView.frame.size.width = 240
                    self.instructionTextView.font = UIFont(name: "SFUIText-Regular", size: 15)
                    self.instructionTextView.sizeToFit()
                })
                
                if self.confidenceController == nil
                {
                    //Add an instance of «ConfidenceController» to the view.
                    self.confidenceController = (self.storyboard!.instantiateViewController(withIdentifier: "ConfidenceController") as! ConfidenceController)
                    self.finishInstantiatingController(self.confidenceController, withCustomHeight: nil)
                    
                    //Set «ConfidenceController's» slider value explanations to the translation results.
                    self.confidenceController.normallyConfident = returnedTranslations[2].uppercased()
                    self.confidenceController.notConfident      = returnedTranslations[3].uppercased()
                    self.confidenceController.somewhatConfident = returnedTranslations[4].uppercased()
                    self.confidenceController.veryConfident     = returnedTranslations[5].uppercased()
                    
                    //Set «ConfidenceController's» other pets text view's placeholder text to the translation result.
                    self.confidenceController.otherPetsPlaceholder = returnedTranslations[6]
                }
                
                //Add keyboard appearance Observer.
                NotificationCenter.default.addObserver(self.confidenceController!, selector: #selector(self.confidenceController.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
                
                //Animate the disappearance of «LivingSituationController» with the appearance of «ConfidenceController».
                self.transitionController(fromController: self.livingSituationController, toController: self.confidenceController, withCustomHeight: nil, withNewTag: aTagFor("confidenceController"))
            }
        }
    }
    
    func presentTraitsController()
    {
        NotificationCenter.default.removeObserver(self.confidenceController!, name: UIResponder.keyboardDidShowNotification, object: nil)
        
        //Get all the translations for the «TraitsController».
        Translator().getArrayOfTranslations(fromArray: ["Your Characteristics", "If a trait below describes you, ", "tap it once", "If one doesn't describe you, ", "tap it twice", "If you can't decide on one, leave it alone. To reset an option, press and hold on it."], requiresHud: false) { (returnedTranslations) in
            DispatchQueue.main.async {
                //Hide progress and enable user interaction again.
                self.continueButton.removeTranslationProgressOverlay(fromViewNamed: "continueButton", oldAlpha: 1)
                self.view.isUserInteractionEnabled = true
                
                self.changePageTitle(returnedTranslations[0], englishString: "Your Characteristics")
                
                self.setTraitsInstructionText(firstPart: returnedTranslations[1], tapOnce: returnedTranslations[2], secondPart: returnedTranslations[3], tapTwice: returnedTranslations[4], thirdPart: returnedTranslations[5])
                
                if self.traitsController == nil
                {
                    //Add an instance of «TraitsController» to the view.
                    self.traitsController = (self.storyboard!.instantiateViewController(withIdentifier: "TraitsController") as! TraitsController)
                    self.finishInstantiatingController(self.traitsController, withCustomHeight: nil)
                }
                
                //Animate the disappearance of «ConfidenceController» with the appearance of «TraitsController».
                self.transitionController(fromController: self.confidenceController, toController: self.traitsController, withCustomHeight: 210, withNewTag: aTagFor("traitsController"))
            }
        }
    }
    
    func presentBiographicController()
    {
        if languageCode != "en"
        {
            continueButton.initialiseTranslation(allowedToAdjust: true, alternateString: "FINISH", backUp: "DONE", useActivityIndicator: false)
        }
        else
        {
            continueButton.setTitle("FINISH", for: .normal)
        }
        
        //Get all the translations for the «BiographicController».
        Translator().getArrayOfTranslations(fromArray: ["Your Profile", "Finally, customise your profile. This is optional but highly encouraged.", "Add a short statement about yourself to be shown to shelters", "Tap to add an image"], requiresHud: false) { (returnedTranslations) in
            DispatchQueue.main.async {
                //Hide progress and enable user interaction again.
                self.continueButton.removeTranslationProgressOverlay(fromViewNamed: "continueButton", oldAlpha: nil)
                self.view.isUserInteractionEnabled = true
                
                self.changePageTitle(returnedTranslations[0], englishString: "Your Profile")
                
                //Animate setting «instructionTextView's» text to the translation result.
                UIView.transition(with: self.instructionTextView, duration: 0.35, options: .transitionCrossDissolve, animations: {
                    self.instructionTextView.text = returnedTranslations[1]
                    self.instructionTextView.frame.size.height = 90
                    self.instructionTextView.frame.size.width = 240
                    self.instructionTextView.font = UIFont(name: "SFUIText-Regular", size: 15)
                    self.instructionTextView.sizeToFit()
                })
                
                if self.biographicController == nil
                {
                    //Add an instance of «BiographicController» to the view.
                    self.biographicController = (self.storyboard!.instantiateViewController(withIdentifier: "BiographicController") as! BiographicController)
                    self.finishInstantiatingController(self.biographicController, withCustomHeight: nil)
                    
                    //Set «BiographicController's» biography text view's placeholder text to the translation result.
                    self.biographicController.biographyPlaceholder = returnedTranslations[2]
                    
                    self.biographicController.addImagePlaceholder = returnedTranslations[3]
                }
                
                //Animate the disappearance of «TraitsController» with the appearance of «BiographicController».
                self.transitionController(fromController: self.traitsController, toController: self.biographicController, withCustomHeight: nil, withNewTag: aTagFor("biographicController"))
            }
        }
    }
    
    //--------------------------------------------------//
    
    //Other Functions
    
    func backTo(_ controller: UIViewController, fromController: UIViewController, pageTitle: String, instructionText: String?)
    {
        NotificationCenter.default.removeObserver(fromController, name: UIResponder.keyboardDidShowNotification, object: nil)
        
        view.isUserInteractionEnabled = false
        view.tag = controller.view.tag
        
        changePageTitle(translationArchive[pageTitle] ?? pageTitle.replacingOccurrences(of: "*", with: ""), englishString: pageTitle.replacingOccurrences(of: "*", with: ""))
        
        if controller.view.tag != aTagFor("traitsController")
        {
            if let unwrappedInstructionText = instructionText
            {
                //Animate setting «instructionTextView's» back to its original text.
                UIView.transition(with: instructionTextView, duration: 0.35, options: .transitionCrossDissolve, animations: {
                    self.instructionTextView.text = translationArchive[unwrappedInstructionText] ?? unwrappedInstructionText.replacingOccurrences(of: "*", with: "")
                    self.instructionTextView.frame.size.height = f.height(90)
                    self.instructionTextView.frame.size.width = f.width(240)
                    self.instructionTextView.font = UIFont(name: "SFUIText-Regular", size: 15)
                    self.instructionTextView.sizeToFit()
                })
            }
        }
        else
        {
            self.setTraitsInstructionText(firstPart:  translationArchive["If a trait below describes you, "]                                                      ?? "If a trait below describes you, ",
                                          tapOnce:    translationArchive["tap it once"]                                                                           ?? "tap it once",
                                          secondPart: translationArchive["If one doesn't describe you, "]                                                         ?? "If one doesn't describe you, ",
                                          tapTwice:   translationArchive["tap it twice"]                                                                          ?? "tap it twice",
                                          thirdPart:  translationArchive["If you can't decide on one, leave it alone. To reset an option, press and hold on it."] ?? "If you can't decide on one, leave it alone. To reset an option, press and hold on it.")
        }
        
        //Animate the disappearance of «fromController» with the appearance of «controller».
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            //Move «fromController» off the right side of the screen.
            let fromControllerCentre = fromController.view.center
            
            let screenWidth = UIScreen.main.bounds.size.width
            
            fromController.view.center = CGPoint(x: f.x(fromControllerCentre.x + screenWidth), y: f.y(fromControllerCentre.y))
            
            if controller.view.tag == aTagFor("biographicController")
            {
                controller.view.center = self.initialBiographicCentre
            }
            else if controller.view.tag == aTagFor("birthdateController")
            {
                controller.view.center = self.initialBirthdateCentre
                
                self.backButton.alpha = 1
                self.continueButton.isEnabled = true
                self.continueButton.alpha = 1
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                    findAndResignFirstResponder()
                }
            }
            else if controller.view.tag == aTagFor("createUserController")
            {
                controller.view.center = self.initialCreateUserCentre
                
                self.backButton.alpha = 0
                self.continueButton.alpha = 0
                
                //Add keyboard appearance Observer.
                NotificationCenter.default.addObserver(self.createUserController!, selector: #selector(self.createUserController.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                    self.createUserController.firstNameTextField.becomeFirstResponder()
                }
            }
            else if controller.view.tag == aTagFor("confidenceController")
            {
                controller.view.center = self.initialConfidenceCentre
            }
            else if controller.view.tag == aTagFor("employmentController")
            {
                controller.view.center = self.initialEmploymentCentre
                
                self.continueButton.isEnabled = true
                
                //Add keyboard appearance Observer.
                NotificationCenter.default.addObserver(self.employmentController!, selector: #selector(self.employmentController.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
            }
            else if controller.view.tag == aTagFor("livingSituationController")
            {
                controller.view.center = self.initialLivingSituationCentre
                self.continueButton.isEnabled = true
                
                //Add keyboard appearance Observer.
                NotificationCenter.default.addObserver(self.livingSituationController!, selector: #selector(self.livingSituationController.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
            }
            else if controller.view.tag == aTagFor("traitsController")
            {
                if languageCode != "en"
                {
                    self.continueButton.initialiseTranslation(allowedToAdjust: true, alternateString: "CONTINUE", backUp: "GO", useActivityIndicator: false)
                }
                else
                {
                    self.continueButton.setTitle("CONTINUE", for: .normal)
                }
                
                controller.view.center = self.initialTraitsCentre
            }
            
        }, completion: { finished in
            self.view.isUserInteractionEnabled = true
        })
    }
    
    func backToCreateAccount()
    {
        //Update the view's tag to represent the change in presenting view.
        view.tag = aTagFor("createAccountController")
        
        //Add shadow borders to to the view behind the «RadioButtons».
        view.addShadowBorder(backgroundColour: .white, borderColour: UIColor(hex: 0xE1E0E1).cgColor, withFrame: CGRect(x: adoptButton.frame.origin.x - 5, y: adoptButton.frame.origin.y, width: adoptButton.frame.size.width, height: adoptButton.frame.size.height), withTag: aTagFor("adoptButton_BORDER"))
        view.addShadowBorder(backgroundColour: .white, borderColour: UIColor(hex: 0xE1E0E1).cgColor, withFrame: CGRect(x: shelterButton.frame.origin.x - 5, y: shelterButton.frame.origin.y, width: shelterButton.frame.size.width, height: shelterButton.frame.size.height), withTag: aTagFor("shelterButton_BORDER"))
        
        //Animate the disappearance of «adoptButton» and «shelterButton» with the appearance of «BirthdateController».
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            //Move «BirthdateController» off the right side of the screen.
            let birthdateControllerCentre = self.birthdateController.view.center
            
            let screenWidth = UIScreen.main.bounds.size.width
            
            self.birthdateController.view.center = CGPoint(x: birthdateControllerCentre.x + screenWidth, y: birthdateControllerCentre.y)
            
            //Get the shadow views of «adoptButton» and «shelterButton».
            guard let adoptButtonShadow   = self.view.findSubview(aTagFor("adoptButton_BORDER")) else { report("No adopt button border.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line]); return }
            guard let shelterButtonShadow = self.view.findSubview(aTagFor("shelterButton_BORDER")) else { report("No shelter button border.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line]); return }
            
            //Move «adoptButton» and «shelterButton» and their shadows back onto the screen.
            self.adoptButton.center = CGPoint(x: f.x(187), y: f.y(379.5))
            self.shelterButton.center = CGPoint(x: self.adoptButton.center.x, y: f.y(432.5))
            
            adoptButtonShadow.center = CGPoint(x: f.x(182.0), y: self.adoptButton.center.y)
            shelterButtonShadow.center = CGPoint(x: adoptButtonShadow.center.x, y: self.shelterButton.center.y)
            
            //Change the page title back to "Create Account".
            self.changePageTitle(translationArchive["Create\nAccount"]?.replacingOccurrences(of: "\n", with: " ") ?? "Create Account", englishString: "Create Account")
            
            //Animate setting «instructionTextView's» back to its original text.
            UIView.transition(with: self.instructionTextView, duration: 0.35, options: .transitionCrossDissolve, animations: {
                self.instructionTextView.text = translationArchive["Which of the below options best describes you?"] ?? "Which of the below options best describes you?"
                self.instructionTextView.frame.size.height = f.height(90)
                self.instructionTextView.frame.size.width = f.width(240)
                self.instructionTextView.font = UIFont(name: "SFUIText-Regular", size: 15)
                self.instructionTextView.sizeToFit()
            })
        })
    }
    
    func changePageTitle(_ toText: String, englishString: String)
    {
        //Animate setting «createAccountLabel's» text to the translation result.
        UIView.transition(with: createAccountLabel, duration: 0.35, options: .transitionCrossDissolve, animations: {
            self.createAccountLabel.font = UIFont(name: "Futura-Bold", size: 50)
            
            let magicNumber = round(Double(toText.components(separatedBy: " ").count) / 2)
            
            var splitText = ""
            
            for individualComponent in toText.components(separatedBy: " ")
            {
                if individualComponent == toText.components(separatedBy: " ")[Int(magicNumber - 1)]
                {
                    splitText += "\(individualComponent)\n"
                }
                else
                {
                    splitText += "\(individualComponent) "
                }
            }
            
            self.createAccountLabel.text = splitText
            
            //Adjust «createAccountLabel's» text size if needed.
            if self.createAccountLabel.text != englishString
            {
                self.createAccountLabel.font = UIFont(name: "Futura-Bold", size: self.createAccountLabel.fontSizeThatFits(nil))
            }
        })
    }
    
    func finishInstantiatingController(_ withController: UIViewController, withCustomHeight: CGFloat?)
    {
        //Set up the frame for the newly instantiated UIViewController.
        withController.view.frame = CGRect(x: view.frame.maxX, y: instructionTextView.frame.maxY + 5, width: 375, height: (withCustomHeight ?? 377))
        withController.willMove(toParent: self)
        view.addSubview(withController.view)
        addChild(withController)
        withController.didMove(toParent: self)
    }
    
    /**
     Decreases the font size of a UIButton's *titleLabel* with an attributed title until it is no longer truncated.
     
     - Parameter forButton: The UIButton whose *titleLabel* to fix.
     - Parameter withAttributes: The UIButton *titleLabel's* attributes.
     */
    func fixAttributedTitleSize(forButton: UIButton, withAttributes: [NSAttributedString.Key:Any])
    {
        var mutableAttributes = withAttributes
        
        if let titleLabel = forButton.titleLabel
        {
            var fixSize: CGFloat = titleLabel.font.pointSize
            
            while titleLabel.isTruncated
            {
                if fixSize > 1
                {
                    fixSize -= 1
                    
                    mutableAttributes[.font] = titleLabel.font.withSize(fixSize)
                    forButton.setAttributedTitle(NSMutableAttributedString(string: titleLabel.text!, attributes: mutableAttributes), for: .normal)
                    print(forButton.titleLabel!.font.pointSize)
                }
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        buildInstance.handleMailComposition(withController: controller, withResult: result, withError: error)
    }
    
    func reverseController(toController: UIViewController, fromController: UIViewController)
    {
        view.isUserInteractionEnabled = false
        
        //Animate the disappearance of «fromController» with the appearance of «toController».
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            //Move «fromController» off the right side of the screen.
            let fromControllerCentre = fromController.view.center
            
            let screenWidth = UIScreen.main.bounds.size.width
            
            fromController.view.center = CGPoint(x: fromControllerCentre.x + screenWidth, y: fromControllerCentre.y)
            
            if      toController.view.tag == aTagFor("biographicController")      { toController.view.center = self.initialBiographicCentre }
            else if toController.view.tag == aTagFor("birthdateController")
            {
                toController.view.center = self.initialBirthdateCentre
                
                self.backButton.alpha = 1
                self.continueButton.isEnabled = true
                self.continueButton.alpha = 1
            }
            else if toController.view.tag == aTagFor("createUserController")
            {
                toController.view.center = self.initialCreateUserCentre
                
                self.backButton.alpha = 0
                self.continueButton.alpha = 0
            }
            else if toController.view.tag == aTagFor("confidenceController")      { toController.view.center = self.initialConfidenceCentre }
            else if toController.view.tag == aTagFor("employmentController")      { toController.view.center = self.initialEmploymentCentre; self.continueButton.isEnabled = true }
            else if toController.view.tag == aTagFor("livingSituationController") { toController.view.center = self.initialLivingSituationCentre }
            else if toController.view.tag == aTagFor("traitsController")          { toController.view.center = self.initialTraitsCentre }
            
        }, completion: { finished in
            //Update the view's tag to represent the change in presenting view.
            self.view.tag = toController.view.tag
            self.view.isUserInteractionEnabled = true
        })
    }
    
    func setTraitsInstructionText(firstPart: String, tapOnce: String, secondPart: String, tapTwice: String, thirdPart: String)
    {
        instructionTextView.frame.size.width = 300
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        
        let defaultAttributes: [NSAttributedString.Key:Any] = [
            .font: UIFont(name: "SFUIText-Regular", size: 13)!,
            .foregroundColor: UIColor.darkGray,
            .paragraphStyle: paragraphStyle]
        
        let tapOnceAttributes: [NSAttributedString.Key:Any] = [
            .font: UIFont(name: "SFUIText-Regular", size: 13)!,
            .foregroundColor: UIColor(hex: 0x60C129),
            .paragraphStyle: paragraphStyle]
        
        let tapTwiceAttributes: [NSAttributedString.Key:Any] = [
            .font: UIFont(name: "SFUIText-Regular", size: 13)!,
            .foregroundColor: UIColor(hex: 0xE95A53),
            .paragraphStyle: paragraphStyle]
        
        let fullyFormedInstructions = NSMutableAttributedString(string: firstPart, attributes: defaultAttributes)
        
        let firstAttributedSection = NSAttributedString(string: "\(tapOnce). ", attributes: tapOnceAttributes)
        let secondAttributedSection = NSAttributedString(string: "\(tapTwice).\n\n", attributes: tapTwiceAttributes)
        
        fullyFormedInstructions.append(firstAttributedSection)
        fullyFormedInstructions.append(NSMutableAttributedString(string: secondPart, attributes: defaultAttributes))
        fullyFormedInstructions.append(secondAttributedSection)
        fullyFormedInstructions.append(NSMutableAttributedString(string: languageCode == "en" ? "Leave any you're not sure of deselected. To reset an option, press and hold on it." : thirdPart, attributes: defaultAttributes))
        
        //Animate setting «instructionTextView's» text to the translation result.
        UIView.transition(with: self.instructionTextView, duration: 0.35, options: .transitionCrossDissolve, animations: {
            self.instructionTextView.attributedText = fullyFormedInstructions
            self.instructionTextView.sizeToFit()
        })
    }
    
    func stepProgress(forwardDirection: Bool)
    {
        UIView.animate(withDuration: 0.2) {
            self.progressView.setProgress(self.progressView.progress + (forwardDirection ? 0.125 : -0.125), animated: true)
        }
    }
    
    func transitionController(fromController: UIViewController, toController: UIViewController, withCustomHeight: CGFloat?, withNewTag: Int)
    {
        //Animate the disappearance of «fromController» with the appearance of «toController».
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            //Move «fromController» off the left side of the screen.
            let fromControllerCentre = fromController.view.center
            
            let screenWidth = UIScreen.main.bounds.size.width
            
            fromController.view.center = CGPoint(x: fromControllerCentre.x - screenWidth, y: fromControllerCentre.y)
            
            //Move «toController» onto the screen from the right side.
            toController.view.frame = CGRect(x: 0, y: self.instructionTextView.frame.maxY + 5, width: 375, height: (withCustomHeight ?? 375))
        }, completion: { finished in
            //Update the view's tag to represent the change in presenting view.
            self.view.tag = withNewTag
            toController.view.tag = withNewTag
            
            if      toController.view.tag == aTagFor("biographicController")      { self.initialBiographicCentre      = toController.view.center }
            else if toController.view.tag == aTagFor("birthdateController")       { self.initialBirthdateCentre       = toController.view.center }
            else if toController.view.tag == aTagFor("createUserController")      { self.initialCreateUserCentre      = toController.view.center }
            else if toController.view.tag == aTagFor("confidenceController")      { self.initialConfidenceCentre      = toController.view.center }
            else if toController.view.tag == aTagFor("employmentController")
            {
                self.initialEmploymentCentre = toController.view.center
                
                self.backButton.alpha = 1
                self.continueButton.isEnabled = (self.employmentController.employmentStatusSegmentedControl.selectedSegmentIndex > -1) || (self.employmentController.somethingElseTextView.text.noWhiteSpaceLowerCaseString != "")
                self.continueButton.alpha = 1
            }
            else if toController.view.tag == aTagFor("livingSituationController") { self.initialLivingSituationCentre = toController.view.center }
            else if toController.view.tag == aTagFor("traitsController")          { self.initialTraitsCentre          = toController.view.center }
        })
    }
}

extension UIButton
{
    /**
     Properly sets a given button's shadow attributes.
     
     - Parameter forButtonNamed: A String representing the button whose shadow to transform.
     - Parameter touchingUp: A Boolean representing whether or not the button's shadow should be transformed for touching up.
     */
    func transformShadow(forButtonNamed: String, touchingUp: Bool)
    {
        if let borderFrame = superview!.findSubview(aTagFor("\(forButtonNamed)_BORDER"))
        {
            let shadowOffset = touchingUp ? 4 : 0
            
            borderFrame.layer.shadowOffset = CGSize(width: 0, height: shadowOffset)
            
            frame.origin.y = touchingUp ? frame.origin.y - 3 : frame.origin.y + 3
            borderFrame.frame.origin.y = touchingUp ? borderFrame.frame.origin.y - 3 : borderFrame.frame.origin.y + 3
        }
    }
}

extension UIView
{
    /**
     Adds a shadow border around the view.
     
     - Parameter backgroundColour: The shadow border's desired background colour.
     - Parameter borderColour: The shadow border's desired border colour.
     - Parameter withFrame: An optional specifying an alternate frame to add the shadow to.
     - Parameter withTag: The tag to associate with the shadow border.
     */
    func addShadowBorder(backgroundColour: UIColor, borderColour: CGColor, withFrame: CGRect?, withTag: Int)
    {
        let borderFrame = UIView(frame: withFrame ?? frame)
        
        borderFrame.backgroundColor = backgroundColour
        
        borderFrame.layer.borderColor = borderColour
        borderFrame.layer.borderWidth = 2
        
        borderFrame.layer.cornerRadius = 10
        borderFrame.layer.masksToBounds = false
        
        borderFrame.layer.shadowColor = borderColour
        borderFrame.layer.shadowOffset = CGSize(width: 0, height: 4)
        borderFrame.layer.shadowOpacity = 1
        
        borderFrame.tag = withTag
        
        addSubview(borderFrame)
        sendSubviewToBack(borderFrame)
    }
    
    /**
     Removes a subview for a given tag, if it exists.
     
     - Parameter withTag: The tag of the view to remove.
     */
    func removeSubview(_ withTag: Int, animated: Bool)
    {
        for individualSubview in subviews
        {
            if individualSubview.tag == withTag
            {
                DispatchQueue.main.async {
                    if animated
                    {
                        UIView.animate(withDuration: 0.2, animations: {
                            individualSubview.alpha = 0
                        }) { (didComplete) in
                            if didComplete
                            {
                                individualSubview.removeFromSuperview()
                            }
                        }
                    }
                    else
                    {
                        individualSubview.removeFromSuperview()
                    }
                }
            }
        }
    }
}

extension String
{
    var digits: String
    {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}
