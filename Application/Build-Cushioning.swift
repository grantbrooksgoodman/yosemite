//
//  Build-Cushioning.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit

class Build
{
    //--------------------------------------------------//
    
    //Class-level Declarations
    
    //UIButton Declarations
    var codeNameButton:     UIButton?
    var informationButton:  UIButton?
    var sendFeedbackButton: UIButton!
    var subtitleButton:     UIButton?
    
    //UILabel Declarations
    var codeNameLabel: UILabel?
    var preReleaseLabel: UILabel?
    
    //Other Declarations
    var extraneousInformationView: UIView?
    var logoTypeImageView: UIImageView?
    
    //--------------------------------------------------//
    
    //Enumerated Type Declarations
    enum ControllerType
    {
        case applicationDelegate
        case genericController
        case mainController
    }
    
    enum BuildState
    {
        case preAlpha
        case alpha
        case beta
        case releaseCandidate
        case generalRelease
    }
    
    //--------------------------------------------------//
    
    //Required Initialisation Function
    
    /**
     Sets up all the necessary visual elements of a view controller.
     
     If the controller is **generic**, these elements must be passed as **instanceArray** in the following order:
     
     • codeNameLabel
     
     • logoTypeImageView
     
     • preReleaseLabel
     
     • sendFeedbackButton
     
     ----------
     
     If the controller is **main**, these elements must be passed as **instanceArray** in the following order:
     
     • bundleVersionLabel
     
     • projectIdentifierLabel
     
     • skuLabel
     
     • codeNameButton
     
     • extraneousInformationView
     
     • informationButton
     
     • sendFeedbackButton
     
     • subtitleButton
     
     - Parameter withType: The type of controller needing to be set up.
     - Parameter instanceArray: An array of the components needing to be set up.
     
     */
    @discardableResult required init(withType: ControllerType, instanceArray: [Any]?, conserveSpace: Bool)
    {
        //If there is no global information dictionary, generate and set one.
        //If there already is one, then just set it to currentInformationDictionary here.
        let currentInformationDictionary = informationDictionary != nil ? informationDictionary! : generateInformationDictionary()
        
        informationDictionary = currentInformationDictionary
        
        //If the ControllerType is not application delegate, meaning we actually have UI setup to do.
        if withType != .applicationDelegate
        {
            //Unwrap the required elements in the informationDictionary.
            if let unwrappedBuildSku                 = currentInformationDictionary["buildSku"],
                let unwrappedBundleVersion           = currentInformationDictionary["bundleVersion"],
                let unwrappedPreReleaseNotifier      = currentInformationDictionary["preReleaseNotifier"],
                let unwrappedProjectIdentifier       = currentInformationDictionary["projectIdentifier"],
                let unwrappedSubtitleExpiryString    = currentInformationDictionary["subtitleExpiryString"]
            {
                //Variable for easy access to the screen height.
                let screenHeight = UIScreen.main.bounds.height
                
                //Unwrap the instance array along with the view controller at the correct index for the controller type.
                if let unwrappedInstanceArray = instanceArray,
                    let viewController = unwrappedInstanceArray[withType == .genericController ? 4 : 8] as? UIViewController
                {
                    //If the application is pre-release and the screen height matches that of an iPhone X or Xs.
                    if buildState != .generalRelease && (screenHeight == 812 || screenHeight == 896)
                    {
                        //Set appropriate location values for an iPhone X or Xs.
                        let firstYValue = (screenHeight == 812 ? 32 : 35)
                        let secondYValue = (screenHeight == 812 ? 792 : 873)
                        let widthValue = (screenHeight == 812 ? 375 : 414)
                        
                        //Set up the topmost safe area indicator.
                        let firstSafeAreaIndicatorView = UIView(frame: CGRect(x: 0, y: firstYValue, width: widthValue, height: 1))
                        firstSafeAreaIndicatorView.backgroundColor = .white
                        viewController.view.addSubview(firstSafeAreaIndicatorView)
                        viewController.view.bringSubviewToFront(firstSafeAreaIndicatorView)
                        
                        //Set up the bottom-most safe area indicator.
                        let secondSafeAreaIndicatorView = UIView(frame: CGRect(x: 0, y: secondYValue, width: widthValue, height: 1))
                        secondSafeAreaIndicatorView.backgroundColor = .white
                        viewController.view.addSubview(secondSafeAreaIndicatorView)
                        viewController.view.bringSubviewToFront(secondSafeAreaIndicatorView)
                    }
                    
                    //Now we get to ControllerType-specific setup.
                    //If the ControllerType is generic.
                    if withType == .genericController
                    {
                        //Unwrap the required elements.
                        if let unwrappedInstanceArray       = instanceArray,
                            let unwrappedCodeNameLabel      = unwrappedInstanceArray[0] as? UILabel,
                            let unwrappedLogoTypeImageView  = unwrappedInstanceArray[1] as? UIImageView,
                            let unwrappedPreReleaseLabel    = unwrappedInstanceArray[2] as? UILabel,
                            let unwrappedSendFeedbackButton = unwrappedInstanceArray[3] as? UIButton
                        {
                            //Set the last initialised controller to the current one being set up.
                            lastInitialisedController = viewController
                            
                            //Set the unwrapped elements to global variables for use in other functions.
                            codeNameLabel = unwrappedCodeNameLabel
                            logoTypeImageView = unwrappedLogoTypeImageView
                            preReleaseLabel = unwrappedPreReleaseLabel
                            sendFeedbackButton = unwrappedSendFeedbackButton
                            
                            //Set up all the attributes of the core visual components.
                            toggleDarkMode(withType: withType)
                            
                            //Determine and set the isHidden values for some of the core visual components.
                            unwrappedCodeNameLabel.isHidden = (buildState == .generalRelease && !conserveSpace)
                            unwrappedLogoTypeImageView.isHidden = (buildState == .generalRelease && !conserveSpace)
                            unwrappedPreReleaseLabel.isHidden = (buildState == .generalRelease)
                            
                            //If the app is pre-release, and if the device is a new form factor (iPhone X, Xs, ...).
                            if buildState != .generalRelease
                            {
                                //Set the project name label text.
                                //If the languageCode is not English.
                                if languageCode != "en"
                                {
                                    //Get a translation for "Project Name."
                                    Translator().dirtyGetTranslation(forString: "Version", requiresHud: false) { (returnedString) in
                                        
                                        //Send our label and its text to a function to be processed and set appropriately.
                                        DispatchQueue.main.async {
                                            self.setCodeNameText(withButtonOrLabel: conserveSpace ? unwrappedPreReleaseLabel : unwrappedCodeNameLabel, withText: returnedString, short: conserveSpace)
                                        }
                                    }
                                }
                                else //If the languageCode is indeed English.
                                {
                                    //Send our label and its text to a function to be processed and set appropriately.
                                    setCodeNameText(withButtonOrLabel: conserveSpace ? unwrappedPreReleaseLabel : unwrappedCodeNameLabel, withText: "Version", short: conserveSpace)
                                }
                                
                                #warning("Clean this up.")
                                //Set the pre-release notifier label text.
                                Translator().dirtyGetTranslation(forString: unwrappedPreReleaseNotifier, requiresHud: false) { (returnedString) in
                                    
                                    DispatchQueue.main.async {
                                        //Set the label's text.
                                        if !conserveSpace
                                        {
                                            unwrappedPreReleaseLabel.text = returnedString
                                            
                                            //Set the font size for the new text on the label.
                                            unwrappedPreReleaseLabel.font = unwrappedPreReleaseLabel.font.withSize(unwrappedPreReleaseLabel.fontSizeThatFits(returnedString))
                                        }
                                        
                                        //Animate the presentation of the core visual elements.
                                        UIView.animate(withDuration: 0.2, delay: 0.5, animations: {
                                            unwrappedCodeNameLabel.alpha = conserveSpace ? 0 : 1
                                            unwrappedLogoTypeImageView.alpha = conserveSpace ? 0 : 1
                                            unwrappedPreReleaseLabel.alpha = 1
                                            unwrappedSendFeedbackButton.alpha = 1
                                        })
                                    }
                                }
                            }
                            else //If the application is NOT pre-release.
                            {
                                //Move sendFeedbackButton to the bottom right of the screen.
                                unwrappedSendFeedbackButton.frame.origin.x = viewController.view.frame.maxX - unwrappedSendFeedbackButton.frame.size.width - CGFloat((screenHeight == 812 ? 10 : 5))
                                
                                //Show sendFeedbackButton.
                                unwrappedSendFeedbackButton.alpha = 1
                            }
                        }
                        else //Couldn't unwrap some or all of the required elements.
                        {
                            report("Unable to unwrap required elements.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
                        }
                    }
                    else //If the ControllerType is main.
                    {
                        //If this build has expired.
                        if unwrappedSubtitleExpiryString == "Evaluation period ended." && preReleaseApplication
                        {
                            //After 1 second, display the expiryAlertController.
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                PresentationManager().expiryAlertController()
                            })
                        }
                        
                        //Unwrap the required elements.
                        if let unwrappedInstanceArray              = instanceArray,
                            let bundleVersionLabel                 = unwrappedInstanceArray[0] as? UILabel,
                            let projectIdentifierLabel             = unwrappedInstanceArray[1] as? UILabel,
                            let skuLabel                           = unwrappedInstanceArray[2] as? UILabel,
                            let unwrappedCodeNameButton            = unwrappedInstanceArray[3] as? UIButton,
                            let unwrappedExtraneousInformationView = unwrappedInstanceArray[4] as? UIView,
                            let unwrappedInformationButton         = unwrappedInstanceArray[5] as? UIButton,
                            let unwrappedSendFeedbackButton        = unwrappedInstanceArray[6] as? UIButton,
                            let unwrappedSubtitleButton            = unwrappedInstanceArray[7] as? UIButton
                        {
                            //Set the last initialised controller to the current one being set up.
                            lastInitialisedController = viewController
                            
                            //Set the unwrapped elements to global variables for use in other functions.
                            codeNameButton = unwrappedCodeNameButton
                            extraneousInformationView = unwrappedExtraneousInformationView
                            informationButton = unwrappedInformationButton
                            sendFeedbackButton = unwrappedSendFeedbackButton
                            subtitleButton = unwrappedSubtitleButton
                            
                            //Set up all the attributes of the core visual components.
                            toggleDarkMode(withType: withType)
                            
                            //Set text of labels that don't need any special setup.
                            bundleVersionLabel.text = unwrappedBundleVersion
                            projectIdentifierLabel.text = unwrappedProjectIdentifier
                            skuLabel.text = unwrappedBuildSku
                            
                            //Set the project name label text.
                            //If the languageCode is not English.
                            if languageCode != "en"
                            {
                                //Get a translation for "Project Name."
                                Translator().dirtyGetTranslation(forString: "Project Name", requiresHud: false) { (returnedString) in
                                    
                                    //Send our button and its titleLabel's text to a function to be processed and set appropriately.
                                    DispatchQueue.main.async {
                                        self.setCodeNameText(withButtonOrLabel: unwrappedCodeNameButton, withText: returnedString, short: false)
                                    }
                                }
                            }
                            else
                            {
                                //Send our button and its titleLabel's text to a function to be processed and set appropriately.
                                setCodeNameText(withButtonOrLabel: unwrappedCodeNameButton, withText: "Project Code Name", short: false)
                            }
                            
                            //Set the subtitleButton's titleLabel's text.
                            Translator().dirtyGetTranslation(forString: unwrappedPreReleaseNotifier, requiresHud: false) { (returnedString) in
                                
                                DispatchQueue.main.async {
                                    //Set the title of the button.
                                    unwrappedSubtitleButton.setTitle(returnedString, for: .normal)
                                    
                                    //Adjust the font to fit the new text.
                                    unwrappedSubtitleButton.titleLabel!.font = unwrappedSubtitleButton.titleLabel!.font.withSize(unwrappedSubtitleButton.titleLabel!.fontSizeThatFits(returnedString))
                                    
                                    //If the application is not pre-release.
                                    if !preReleaseApplication
                                    {
                                        //Move sendFeedbackButton to the bottom right of the screen.
                                        unwrappedSendFeedbackButton.frame.origin.x = viewController.view.frame.maxX - unwrappedSendFeedbackButton.frame.size.width - CGFloat((screenHeight == 812 ? 10 : 5))
                                    }
                                    
                                    //Animate the presentation of the preReleaseInformationView, if applicable, and of sendFeedbackButton.
                                    UIView.animate(withDuration: 0.2, delay: 1.5, animations: {
                                        (viewController as! MC).preReleaseInformationView.alpha = (preReleaseApplication ? 1 : 0)
                                        unwrappedSendFeedbackButton.alpha = 1
                                    })
                                }
                            }
                        }
                        else //Couldn't unwrap some or all of the required elements.
                        {
                            report("Unable to unwrap required elements.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
                        }
                    }
                }
            }
            else //Couldn't unwrap some or all of the required elements.
            {
                report("Unable to unwrap required elements.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
            }
        }
    }
    
    //--------------------------------------------------//
    
    //Public Functions
    
    ///Action for codeNameButton.
    func codeNameButtonAction()
    {
        //Animates the toggling of extraneousInformationView and sendFeedbackButton.
        UIView.animate(withDuration: 0.4)
        {
            self.extraneousInformationView!.alpha = (self.extraneousInformationView!.alpha == 0 ? 1 : 0)
            self.sendFeedbackButton.alpha = (self.extraneousInformationView!.alpha == 1 ? 0 : 1)
        }
    }
    
    ///Displays build information in an alert controller.
    func displayBuildInformation()
    {
        var messageToDisplay = "This is a \(buildStateAsString(short: false)) version of project code name *\(codeName)*.\n\n\(informationDictionary["expiryInformationString"]!)\n\nAll features presented here are subject to change, and any new or previously undisclosed information presented within this software is to remain strictly confidential.\n\nRedistribution of this software by unauthorised parties in any way, shape, or form is strictly prohibited.\n\nBy continuing your use of this software, you acknowledge your agreement to the above terms.\n\nAll content herein, unless otherwise stated, is copyright © \(Calendar.current.dateComponents([.year], from: Date()).year!) *NEOTechnica Corporation*. All rights reserved."
        
        if buildStateAsString(short: false) == "general"
        {
            messageToDisplay = "This is a pre-release update to *\(finalName)*.\n\n\(informationDictionary["expiryInformationString"]!)\n\nAll features presented here are subject to change, and any new or previously undisclosed information presented within this software is to remain strictly confidential.\n\nRedistribution of this software by unauthorised parties in any way, shape, or form is strictly prohibited.\n\nBy continuing your use of this software, you acknowledge your agreement to the above terms.\n\nAll content herein, unless otherwise stated, is copyright © \(Calendar.current.dateComponents([.year], from: Date()).year!) *NEOTechnica Corporation*. All rights reserved."
        }
        
        //Display a successAlertController with information about the build.
        PresentationManager().successAlertController(withTitle: "Project \(codeName)", withMessage: messageToDisplay, withCancelButtonTitle: "Dismiss", withAlternateSelectors: nil, preferredActionIndex: nil)
    }
    
    /**
     Handles e-mail composition when sending feedback.
     
     - Parameter withController: The **MFMailComposeViewController** with which we are dealing.
     - Parameter withResult: The result of the attempted sending.
     - Parameter withError: An optional instance of **Error**, if one did occur.
     */
    func handleMailComposition(withController: MFMailComposeViewController, withResult: MFMailComposeResult, withError: Error?)
    {
        //Dismiss the mail controller.
        withController.dismiss(animated: true)
        
        //Wait for the controller to fully animate its dismissal.
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            //If the message could not be sent.
            if withResult == .failed
            {
                //Display an errorAlertController telling the user the message could not be sent.
                PresentationManager().errorAlertController(withTitle: "Unable to Send", withMessage: "Unfortunately, the message was unable to be sent. Please try again.", extraneousInformation: (withError != nil ? errorInformation(forError: withError! as NSError) : nil), withCancelButtonTitle: nil, withAlternateSelectors: nil, preferredActionIndex: nil, withFileName: #file, withLineNumber: #line, withFunctionTitle: #function, networkDependent: false, canFileReport: true)
            }
            else if withResult == .sent //If the message did send.
            {
                //Display a successAlertController telling the user the message sent successfully.
                PresentationManager().successAlertController(withTitle: "Message Sent", withMessage: "The message was successfully sent.", withCancelButtonTitle: nil, withAlternateSelectors: nil, preferredActionIndex: nil)
            }
        })
    }
    
    ///Action for subtitleButton.
    func subtitleButtonAction(withButton: UIButton)
    {
        //Animate the hiding of the button.
        UIView.animate(withDuration: 0.2, animations: {
            withButton.alpha = 0
        }) { (didComplete) in
            if didComplete
            {
                //Set the font size back up to its original.
                withButton.titleLabel!.font = withButton.titleLabel!.font.withSize(12)
                
                //Get translations for both possible string settings.
                Translator().getArrayOfTranslations(fromArray: [informationDictionary["preReleaseNotifier"]!, informationDictionary["subtitleExpiryString"]!], requiresHud: false) { (returnedStrings) in
                    
                    DispatchQueue.main.async {
                        //The appropriate title to set for the button.
                        let titleToSet = withButton.titleLabel!.text == returnedStrings[0] ? returnedStrings[1] : returnedStrings[0]
                        
                        //Set the title of the button.
                        withButton.setTitle(titleToSet, for: .normal)
                        
                        //Adjust the font to fit the new text.
                        withButton.titleLabel!.font = withButton.titleLabel!.font.withSize(withButton.titleLabel!.fontSizeThatFits(titleToSet))
                        
                        //Animate the presentation of the button.
                        UIView.animate(withDuration: 0.2, delay: 0.1, animations: {
                            withButton.alpha = 1
                        })
                    }
                }
            }
        }
    }
    
    ///Toggles dark mode on the current controller.
    func toggleDarkMode(withType: ControllerType)
    {
        //Ternary conditionals describing the image and text colour for dark or light mode.
        let imageToUse = UIImage(named: "NT (\(darkMode ? "Black" : "White")).png")
        let textColour = (darkMode ? UIColor(hex: 0x282828) : .white)
        
        //An attributed string with a string in the current langugage, if it fits.
        let sendFeedbackAttributedString = NSMutableAttributedString(string: (sendFeedbackButton.titleLabel!.fontSizeThatFits(sendFeedbackDictionary[languageCode]!) >= 9 ? sendFeedbackDictionary[languageCode]! : "Send Feedback"), attributes: [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): textColour, NSAttributedString.Key(rawValue: NSAttributedString.Key.underlineStyle.rawValue): NSUnderlineStyle.single.rawValue])
        
        //Scales sendFeedbackButton's titleLabel to a minimum size of 9 if it needs adjustment.
        sendFeedbackButton.titleLabel!.scaleToMinimum(alternateText: "Send Feedback", originalText: sendFeedbackDictionary[languageCode]!, minimumSize: 9)
        
        //Sets sendFeedbackButton's attributed title.
        sendFeedbackButton.setAttributedTitle(sendFeedbackAttributedString, for: .normal)
        
        //If we are toggling dark mode on a generic controller.
        if withType == .genericController
        {
            //Unwrap required elements.
            if let unwrappedCodeNameLabel      = codeNameLabel,
                let unwrappedPrereleaseLabel   = preReleaseLabel,
                let unwrappedLogoTypeImageView = logoTypeImageView
            {
                //Set the text colour appropriately.
                unwrappedCodeNameLabel.textColor = textColour
                unwrappedPrereleaseLabel.textColor = textColour
                
                //Set the image appropriately.
                unwrappedLogoTypeImageView.image = imageToUse
            }
            else //Couldn't unwrap some or all of the required elements.
            {
                report("Unable to unwrap required elements.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
            }
        }
        else //If we are toggling dark mode on the main controller.
        {
            //Unwrap required elements.
            if let unwrappedCodeNameButton             = codeNameButton,
                let unwrappedExtraneousInformationView = extraneousInformationView,
                let unwrappedInformationButton         = informationButton,
                let unwrappedSubtitleButton            = subtitleButton
            {
                //Set the title colour appropriately.
                unwrappedCodeNameButton.setTitleColor(textColour, for: .normal)
                unwrappedSubtitleButton.setTitleColor(textColour, for: .normal)
                
                //Set the image appropriately.
                unwrappedInformationButton.setImage(imageToUse, for: .normal)
                
                //For each subview that is a label on unwrappedExtraneousInformationView, set the text colour appropriately.
                for individualSubview in unwrappedExtraneousInformationView.subviews
                {
                    if let currentLabel = individualSubview as? UILabel
                    {
                        currentLabel.textColor = textColour
                    }
                }
            }
            else //Couldn't unwrap some or all of the required elements.
            {
                report("Unable to unwrap required elements.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
            }
        }
    }
    
    //--------------------------------------------------//
    
    //Private Functions
    
    private func buildStateAsString(short: Bool) -> String
    {
        switch buildState
        {
        case .preAlpha:
            return short ? "p" : "pre-alpha"
        case .alpha:
            return short ? "a" : "alpha"
        case .beta:
            return short ? "b" : "beta"
        case .releaseCandidate:
            return short ? "c" : "release candidate"
        default:
            return short ? "g" : "general"
        }
    }
    
    /**
     Generates the build's SKU.
     
     - Parameter buildDateUnixDouble: The application's build date as a Unix epoch double.
     - Parameter buildNumber: The application's build number.
     */
    private func generateBuildSku(buildDateUnixDouble: TimeInterval, buildNumber: Int) -> String
    {
        //Date formatter to convert Unix epoch time to a "ddMMyy" date.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyy"
        
        //The "ddMMyy" formatted date string from the Unix epoch build date.
        let formattedBuildDateString = dateFormatter.string(from: Date(timeIntervalSince1970: buildDateUnixDouble))
        
        //If the code name is longer than 3 letters, set threeLetterCodeNameIdentifier to the first, middle, and last letters of the code name, uppercased.
        //If the code name is exactly 3 letters, set threeLetterCodeNameIdentifier to the entire code name, uppercased.
        let threeLetterCodeNameIdentifier = (codeName.length > 3 ? "\(String(codeName.first!))\(String(codeName[codeName.index(codeName.startIndex, offsetBy: Int((Double(codeName.count) / 2).rounded(.down)))]))\(String(codeName.last!))".uppercased() : codeName.uppercased())
        
        return "\(formattedBuildDateString)-\(threeLetterCodeNameIdentifier)-\(String(format: "%06d", buildNumber))\(buildStateAsString(short: true))"
    }
    
    /**
     Generates appropriate strings describing information about the build's expiry date.
     
     - Parameter buildDateUnixDouble: The application's build date as a Unix epoch double.
     */
    private func generateExpiryInformation(buildDateUnixDouble: TimeInterval) -> (informationString: String, subtitleString: String)
    {
        //Thirty days from when the application was last built.
        let expiryDate = Calendar.current.date(byAdding: .day, value: 30, to: Date(timeIntervalSince1970: buildDateUnixDouble))!
        
        //Date formatter to convert Unix epoch time to a "dd-MM-yyyy" date.
        let expiryDateFormatter = DateFormatter()
        expiryDateFormatter.dateFormat = "dd-MM-yyyy"
        
        //Noon of the current date.
        let noonCurrentDate = Calendar.current.date(bySettingHour: 12, minute: 00, second: 00, of: Calendar.current.startOfDay(for: Date()))!
        
        //Noon of the expiry date.
        let noonExpiryDate = Calendar.current.date(bySettingHour: 12, minute: 00, second: 00, of: Calendar.current.startOfDay(for: expiryDate))!
        
        //The amount of days until the build expires.
        let daysUntilExpiry = Calendar.current.dateComponents([.day], from: noonCurrentDate, to: noonExpiryDate).day!
        
        //The verbose information string to be presented in the build information alert controller.
        let informationString = (Date() <= expiryDate ? "The evaluation period for this build will expire on \(expiryDateFormatter.string(from: expiryDate)). After this date, the entry of a six-digit expiration override code will be required to continue using this software. It is strongly encouraged that the build be updated before the end of the evaluation period." : "The evaluation period for this build ended on \(expiryDateFormatter.string(from: expiryDate)).")
        
        //The string to be displayed on the subtitle button.
        let subtitleString = (Date() <= expiryDate ? "Evaluation period ends \(daysUntilExpiry < 1 ? "" : "in \(daysUntilExpiry) ")\((daysUntilExpiry >= 1 ? "day\(daysUntilExpiry > 1 ? "s" : "")" : "today"))." : "Evaluation period ended.")
        
        return (informationString, subtitleString)
    }
    
    ///Generates a dictionary with accessible information about the current build.
    private func generateInformationDictionary() -> [String: String]
    {
        //The Unix epoch build date as a string.
        let cfBuildDate = Bundle.main.infoDictionary!["CFBuildDate"] as! String
        
        //The build date as a Unix epoch double, corrected if it is the first build.
        let buildDateUnixDouble = TimeInterval((cfBuildDate == "443750400" ? String(Date().timeIntervalSince1970).components(separatedBy: ".")[0] : cfBuildDate))!
        
        //The build number for the current release, meaning the build number subtracted by the build numbers from previous App Store release versions.
        let currentReleaseBuildNumber = Int(Bundle.main.infoDictionary!["CFBundleReleaseVersion"] as! String)!
        
        //The bundle version of the application.
        let bundleVersion = "\(String(appStoreReleaseVersion)).\(String(currentReleaseBuildNumber / 150)).\(String(currentReleaseBuildNumber / 50))"
        
        //The full, unadulterated build number.
        let fullBuildNumber = Int(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)!
        
        //Pre-release notifier strings.
        let preReleaseNotifierStringArray = ["All features subject to change.", "Contents strictly confidential.", "Evaluation version.", "For testing purposes only.", "For use by authorised parties only.", "Not for public use.", "Redistribution is prohibited.", "This is pre-release software."]
        
        return ["buildNumberAsString": String(fullBuildNumber),
                "buildSku": generateBuildSku(buildDateUnixDouble: buildDateUnixDouble, buildNumber: fullBuildNumber),
                "bundleVersion": bundleVersion,
                "expiryInformationString": generateExpiryInformation(buildDateUnixDouble: buildDateUnixDouble).informationString,
                "preReleaseNotifier": preReleaseNotifierStringArray[randomInteger(0, maximumValue: preReleaseNotifierStringArray.count - 1)],
                "projectIdentifier": generateProjectIdentifier(),
                "subtitleExpiryString": generateExpiryInformation(buildDateUnixDouble: buildDateUnixDouble).subtitleString]
    }
    
    ///Generates the project's unique identifier.
    private func generateProjectIdentifier() -> String
    {
        //Declare the serial array.
        var projectIdentifierAsStringCharacterArray: [String]! = []
        
        //A "ddMMyyyy" date formatter.
        let identifierDateFormatter = DateFormatter()
        identifierDateFormatter.dateFormat = "ddMMyyyy"
        
        //The first compile date in the "ddMMyyyy" format.
        let firstCompileDate = identifierDateFormatter.date(from: dmyFirstCompileDateString) ?? identifierDateFormatter.date(from: "24011984")!
        
        //The first and last letters of the code name as their positions within the alphabet.
        let codeNameFirstLetterPositionValue = String(codeName.first!).alphabeticalPositionValue
        let codeNameLastLetterPositionValue = String(codeName.last!).alphabeticalPositionValue
        
        //The day, month, and year from the first compile date.
        let dayFromFirstCompileDate = Calendar.current.component(.day, from: firstCompileDate)
        let monthFromFirstCompileDate = Calendar.current.component(.month, from: firstCompileDate)
        let yearFromFirstCompileDate = Calendar.current.component(.year, from: firstCompileDate)
        
        //Half the length of the code name string, rounded down.
        let middleOffset = Int((Double(codeName.count) / 2).rounded(.down))
        
        //The index of the chracter between the first letter and the middle offset, that being the middle letter.
        let middleLetterIndex = codeName.index(codeName.startIndex, offsetBy: middleOffset)
        
        //Middle letter of the code name.
        let middleLetter = String(codeName[middleLetterIndex])
        
        //An array, which contains each digit in the value returned by multiplying every relevant numerical value, as a string.
        let multipliedConstantArray = String(codeNameFirstLetterPositionValue * middleLetter.alphabeticalPositionValue * codeNameLastLetterPositionValue * dayFromFirstCompileDate * monthFromFirstCompileDate * yearFromFirstCompileDate).map({ String($0) })
        
        //Iterate over multipliedConstantArray.
        for individualIntegerAsString in multipliedConstantArray
        {
            //Append the current integer as a string to our project identifier array.
            projectIdentifierAsStringCharacterArray.append(individualIntegerAsString)
            
            //The middle letter advanced by the value of the current integer.
            let cipheredMiddleLetter = PresentationManager().cipherString(withString: middleLetter, shiftModifier: Int(individualIntegerAsString)!).uppercased()
            
            //Append the ciphered middle letter.
            projectIdentifierAsStringCharacterArray.append(cipheredMiddleLetter)
        }
        
        //Remove duplicates from our project identifier array.
        projectIdentifierAsStringCharacterArray = (Array(NSOrderedSet(array: projectIdentifierAsStringCharacterArray)) as! [String])
        
        //If the count of our project identifier array is greater than 8.
        if projectIdentifierAsStringCharacterArray.count > 8
        {
            //While the count of our project identifier array is greater than 8.
            while projectIdentifierAsStringCharacterArray.count > 8
            {
                //Remove the last value.
                projectIdentifierAsStringCharacterArray.remove(at: projectIdentifierAsStringCharacterArray.count - 1)
            }
        }
        else if projectIdentifierAsStringCharacterArray.count < 8 //If the count is less than 8.
        {
            //Set the letter in use.
            var letterInUse = middleLetter
            
            //While the count of our project identifier array is less than 8.
            while projectIdentifierAsStringCharacterArray.count < 8
            {
                //Cipher the letter in use by its position in the alphabet.
                letterInUse = PresentationManager().cipherString(withString: letterInUse, shiftModifier: letterInUse.alphabeticalPositionValue)
                
                //If our project identifier array doesn't contain this letter, append it to the array.
                if !projectIdentifierAsStringCharacterArray.contains(letterInUse)
                {
                    projectIdentifierAsStringCharacterArray.append(letterInUse)
                }
            }
        }
        
        return (Array(NSOrderedSet(array: projectIdentifierAsStringCharacterArray)) as! [String]).joined()
    }
    
    #warning("Clean this up.")
    /**
     Sets the code name text for an appropriate **UIView**.
     
     - Parameter withButtonOrLabel: A **UIView** being either **codeNameButton** for a main controller, and **codeNameLabel** for a generic one.
     - Parameter withText: A **string** containing the appropriate text to be set.
     */
    private func setCodeNameText(withButtonOrLabel: UIView, withText: String, short: Bool)
    {
        //If the UIView passed in was codeNameLabel.
        if let codeNameLabel = withButtonOrLabel as? UILabel
        {
            //Generate an appropriate title for the label.
            var titleToSet = "\(codeName) | \(withText) \(informationDictionary["bundleVersion"]!) (\(informationDictionary["buildNumberAsString"]!)\(buildStateAsString(short: true)))"
            
            if short
            {
                titleToSet = "\(codeName) \(informationDictionary["bundleVersion"]!) (\(informationDictionary["buildNumberAsString"]!)\(buildStateAsString(short: true)))"
                codeNameLabel.backgroundColor = .black
                codeNameLabel.textColor = .white
                codeNameLabel.font = UIFont(name: "SFUIText-Bold", size: 13)
            }
            
            //Set the label's text.
            codeNameLabel.text = titleToSet
            
            //Set the font size for the new text on the label.
            codeNameLabel.font = codeNameLabel.font.withSize(codeNameLabel.fontSizeThatFits(titleToSet))
            
            let intrinsicContentWidth = codeNameLabel.sizeThatFits(codeNameLabel.intrinsicContentSize).width
            
            codeNameLabel.frame.size.width = intrinsicContentWidth
            codeNameLabel.center.x = UIScreen.main.bounds.midX //UIScreen.main.bounds.width - (codeNameLabel.frame.size.width + 10)
        }
        else if let codeNameButton = withButtonOrLabel as? UIButton //If the UIView passed in was codeNameButton.
        {
            //Set the title's text.
            codeNameButton.setTitle("\(withText): \(codeName)", for: .normal)
            
            //Scale the button's titleLabel to the size required for it to fit within the constraints of the minimum size chosen.
            codeNameButton.titleLabel!.scaleToMinimum(alternateText: "Project Code Name: \(codeName)", originalText: "\(withText): \(codeName)", minimumSize: 6)
        }
    }
}
