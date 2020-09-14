//
//  Builder.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

//First-party frameworks
import MessageUI
import UIKit

class Build
{
    var extraneousInformationView: UIView!
    var sendFeedbackButton: UIButton!
    
    //--------------------------------------------------//
    
    /* Enumerated Type Declarations */
    enum BuildType
    {
        case preAlpha
        case alpha
        case beta
        case releaseCandidate
        case generalRelease
    }
    
    //--------------------------------------------------//
    
    /* Constructor Function */
    
    @discardableResult required init(_ viewController: UIViewController?)
    {
        //If there is no global information dictionary, generate and set one.
        //If there already is one, then just set it to currentInformationDictionary here.
        let currentInformationDictionary = informationDictionary != nil ? informationDictionary! : generateInformationDictionary()
        
        informationDictionary = currentInformationDictionary
        
        let screenHeight = UIScreen.main.bounds.height
        
        if let viewController = viewController
        {
            //If the application is pre-release and the screen height matches that of an iPhone X or Xs.
            if buildType != .generalRelease && (screenHeight == 812 || screenHeight == 896)
            {
                //Set appropriate location values for an iPhone X or Xs.
                let topYOrigin = (screenHeight == 812 ? 32 : 35)
                let bottomYOrigin = (screenHeight == 812 ? 792 : 873)
                let widthValue = (screenHeight == 812 ? 375 : 414)
                
                //Set up the topmost safe area indicator.
                let topSafeAreaIndicator = UIView(frame: CGRect(x: 0, y: topYOrigin, width: widthValue, height: 1))
                topSafeAreaIndicator.backgroundColor = .white
                viewController.view.addSubview(topSafeAreaIndicator)
                viewController.view.bringSubviewToFront(topSafeAreaIndicator)
                
                //Set up the bottom-most safe area indicator.
                let bottomSafeAreaIndicator = UIView(frame: CGRect(x: 0, y: bottomYOrigin, width: widthValue, height: 1))
                bottomSafeAreaIndicator.backgroundColor = .white
                viewController.view.addSubview(bottomSafeAreaIndicator)
                viewController.view.bringSubviewToFront(bottomSafeAreaIndicator)
            }
            
            if let mainController = viewController as? MC
            {
                buildMain(mainController)
            }
            else
            {
                buildGeneric(viewController)
            }
        }
    }
    
    func buildMain(_ main: MC)
    {
        extraneousInformationView = main.extraneousInformationView
        sendFeedbackButton = main.sendFeedbackButton
        
        //Set up all the attributes of the core visual components.
        toggleDarkMode(main)
        
        //Unwrap the required elements in the informationDictionary.
        if let buildSku                 = informationDictionary["buildSku"],
            let bundleVersion           = informationDictionary["bundleVersion"],
            let preReleaseNotifier      = informationDictionary["preReleaseNotifier"],
            let projectIdentifier       = informationDictionary["projectIdentifier"],
            let subtitleExpiryString    = informationDictionary["subtitleExpiryString"]
        {
            if buildType != .generalRelease
            {
                //If this build has expired.
                if subtitleExpiryString == "Evaluation period ended."
                {
                    //After 1 second, display the expiryAlertController.
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        PresentationManager().expiryAlertController()
                    })
                }
                
                //Set text of labels that don't need any special setup.
                main.bundleVersionLabel.text = bundleVersion
                main.projectIdentifierLabel.text = projectIdentifier
                main.skuLabel.text = buildSku
                
                //Set the project name label text.
                //If the languageCode is not English.
                if languageCode != "en"
                {
                    //Get a translation for "Project Name."
                    Translator().dirtyGetTranslation(forString: "Project Name", requiresHud: false) { (returnedString) in
                        
                        //Send our button and its titleLabel's text to a function to be processed and set appropriately.
                        DispatchQueue.main.async {
                            //Set the title's text.
                            main.codeNameButton.setTitle("\(returnedString): \(codeName)", for: .normal)
                            
                            //Scale the button's titleLabel to the size required for it to fit within the constraints of the minimum size chosen.
                            main.codeNameButton.titleLabel!.scaleToMinimum(alternateText: "Project Code Name: \(codeName)", originalText: "\(returnedString): \(codeName)", minimumSize: 6)
                        }
                    }
                }
                else
                {
                    //Set the title's text.
                    main.codeNameButton.setTitle("Project Code Name: \(codeName)", for: .normal)
                    
                    //Scale the button's titleLabel to the size required for it to fit within the constraints of the minimum size chosen.
                    main.codeNameButton.titleLabel!.scaleToMinimum(alternateText: nil, originalText: nil, minimumSize: 6)
                }
                
                //Set the subtitleButton's titleLabel's text.
                Translator().dirtyGetTranslation(forString: preReleaseNotifier, requiresHud: false) { (returnedString) in
                    
                    DispatchQueue.main.async {
                        //Set the title of the button.
                        main.subtitleButton.setTitle(returnedString, for: .normal)
                        
                        //Adjust the font to fit the new text.
                        main.subtitleButton.titleLabel!.font = main.subtitleButton.titleLabel!.font.withSize(main.subtitleButton.titleLabel!.fontSizeThatFits(returnedString))
                        
                        //Animate the presentation of the preReleaseInformationView, if applicable, and of sendFeedbackButton.
                        UIView.animate(withDuration: 0.2, delay: 1.5, animations: {
                            main.preReleaseInformationView.alpha = (preReleaseApplication ? 1 : 0)
                            main.sendFeedbackButton.alpha = 1
                        })
                    }
                }
            }
            else
            {
                //Move sendFeedbackButton to the bottom right of the screen.
                main.sendFeedbackButton.frame.origin.x = main.view.frame.maxX - main.sendFeedbackButton.frame.size.width - CGFloat((UIScreen.main.bounds.height == 812 ? 10 : 5))
                
                //Show sendFeedbackButton.
                main.sendFeedbackButton.alpha = 1
            }
        }
        else //Couldn't unwrap some or all of the required information.
        {
            report("Unable to unwrap required information.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
        }
    }
    
    func buildGeneric(_ viewController: UIViewController)
    {
        if buildType != .generalRelease && buildInfoController == nil
        {
            buildInfoController = BuildInfoController()
            buildInfoController?.sendFeedbackButton.addTarget(nil, action: #selector(buildInfoController!.sendFeedbackButtonAction), for: .touchUpInside)
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
        let buildTypeString = buildTypeAsString(short: false)
        
        var messageToDisplay = "This is a\(buildTypeString == "alpha" ? "n" : "") \(buildTypeString) version of project code name *\(codeName)*.\n\n\(informationDictionary["expiryInformationString"]!)\n\nAll features presented here are subject to change, and any new or previously undisclosed information presented within this software is to remain strictly confidential.\n\nRedistribution of this software by unauthorised parties in any way, shape, or form is strictly prohibited.\n\nBy continuing your use of this software, you acknowledge your agreement to the above terms.\n\nAll content herein, unless otherwise stated, is copyright © \(Calendar.current.dateComponents([.year], from: Date()).year!) *NEOTechnica Corporation*. All rights reserved."
        
        if buildTypeString == "general"
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
        
        isPresentingMailComposeViewController = false
        
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
    func toggleDarkMode(_ viewController: MC)
    {
        //Ternary conditionals describing the image and text colour for dark or light mode.
        let imageToUse = UIImage(named: "NT (\(darkMode ? "Black" : "White")).png")
        let textColour = (darkMode ? UIColor(hex: 0x282828) : .white)
        
        let sendFeedbackAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: textColour,
                                                                     .underlineStyle: NSUnderlineStyle.single.rawValue]
        let sendFeedbackString = (viewController.sendFeedbackButton.titleLabel!.fontSizeThatFits(sendFeedbackDictionary[languageCode]!) >= 9 ? sendFeedbackDictionary[languageCode]! : "Send Feedback")
        
        //An attributed string with a string in the current langugage, if it fits.
        let sendFeedbackAttributedString = NSMutableAttributedString(string: sendFeedbackString, attributes: sendFeedbackAttributes)
        
        //Scales sendFeedbackButton's titleLabel to a minimum size of 9 if it needs adjustment.
        viewController.sendFeedbackButton.titleLabel!.scaleToMinimum(alternateText: "Send Feedback", originalText: sendFeedbackDictionary[languageCode]!, minimumSize: 9)
        
        //Sets sendFeedbackButton's attributed title.
        viewController.sendFeedbackButton.setAttributedTitle(sendFeedbackAttributedString, for: .normal)
        
        //Set the title colour appropriately.
        viewController.codeNameButton.setTitleColor(textColour, for: .normal)
        viewController.subtitleButton.setTitleColor(textColour, for: .normal)
        
        //Set the image appropriately.
        viewController.informationButton.setImage(imageToUse, for: .normal)
        
        //For each subview that is a label on unwrappedExtraneousInformationView, set the text colour appropriately.
        for individualSubview in viewController.extraneousInformationView.subviews
        {
            if let currentLabel = individualSubview as? UILabel
            {
                currentLabel.textColor = textColour
            }
        }
    }
    
    //--------------------------------------------------//
    
    //Private Functions
    
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
        
        return "\(formattedBuildDateString)-\(threeLetterCodeNameIdentifier)-\(String(format: "%06d", buildNumber))\(buildTypeAsString(short: true))"
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
}
