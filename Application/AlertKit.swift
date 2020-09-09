//
//  AlertKit.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

//Third-party Frameworks
import PKHUD
import Reachability

class AlertKit
{
    //--------------------------------------------------//
    
    //Class-level Declarations
    
    //Other Declarations
    var decrementSeconds = 30
    var exitTimer: Timer?
    var expiryController: UIAlertController!
    var expiryMessage = "The evaluation period for this pre-release build of *\(codeName)* has ended.\n\nTo continue using this version, enter the six-digit expiration override code associated with it.\n\nUntil updated to a newer build, entry of this code will be required each time the application is launched.\n\nTime remaining for successful entry: 00:30."
    
    //--------------------------------------------------//
    
    //Public Functions
    
    ///Advances a string a given amount of characters.
    func cipherString(withString: String, shiftModifier: Int) -> String
    {
        var resultingCharacterArray = [Character]()
        
        for utf8Value in withString.utf8
        {
            let shiftedValue = Int(utf8Value) + shiftModifier
            
            if shiftedValue > 97 + 25
            {
                resultingCharacterArray.append(Character(UnicodeScalar(shiftedValue - 26)!))
            }
            else if shiftedValue < 97
            {
                resultingCharacterArray.append(Character(UnicodeScalar(shiftedValue + 26)!))
            }
            else
            {
                resultingCharacterArray.append(Character(UnicodeScalar(shiftedValue)!))
            }
        }
        
        return String(resultingCharacterArray)
    }
    
    /**
     Presents a `UIAlertController` tailored to **confirmation of operations.**
     
     - Parameter title: **"Confirm Operation"**; the alert controller's title.
     - Parameter message: **"Are you sure you would like to perform this operation?"**; the alert controller's message.
     - Parameter cancelConfirmTitles: Include **"cancel"** to set the alert controller's **cancel button title.** Include **"confirm"** to set the alert controller's **confirmation button title.**
     
     - Parameter confirmationDestructive:  Set to `true` when the **confirmation button's style** should be `.destructive`.
     - Parameter confirmationPreferred: Set to `true` when **confirming the operation** should be the `.preferredAction`.
     - Parameter networkDepedent: Set to `true` when having an internet connection is a **prequesite** for this alert controller's presentation.
     
     - Parameter completion: Returns with `true` upon the **confirmation button's selection.** `nil` only when *networkDependent* is set to `true`.
     */
    func confirmationAlertController(title: String?,
                                     message: String?,
                                     cancelConfirmTitles: [String: String],
                                     confirmationDestructive: Bool,
                                     confirmationPreferred: Bool,
                                     networkDepedent: Bool,
                                     completion: @escaping(_ didConfirm: Bool?) -> Void)
    {
        if networkDepedent && !hasConnectivity()
        {
            connectionAlertController()
            completion(nil)
        }
        else
        {
            let controllerTitle = title ?? "Confirm Operation"
            let controllerMessage = message ?? "Are you sure you would like to perform this operation?"
            
            let cancelButtonTitle = cancelConfirmTitles["cancel"] ?? "Cancel"
            let confirmationButtonTitle = cancelConfirmTitles["confirm"] ?? "Confirm"
            
            Translator().getArrayOfTranslations(fromArray: [controllerTitle, controllerMessage, cancelButtonTitle, confirmationButtonTitle], requiresHud: true) { (returnedStrings) in
                DispatchQueue.main.async {
                    let confirmationAlertController = UIAlertController(title: returnedStrings[0], message: returnedStrings[1], preferredStyle: .alert)
                    
                    let confirmationButtonStyle = confirmationDestructive ? UIAlertAction.Style.destructive : UIAlertAction.Style.default
                    
                    confirmationAlertController.addAction(UIAlertAction(title: returnedStrings[3], style: confirmationButtonStyle, handler: { (action: UIAlertAction!) in
                        completion(true)
                    }))
                    
                    confirmationAlertController.addAction(UIAlertAction(title: returnedStrings[2], style: .cancel, handler: { (action: UIAlertAction!) in
                        completion(false)
                    }))
                    
                    confirmationAlertController.preferredAction = confirmationPreferred ? confirmationAlertController.actions[0] : nil
                    
                    politelyPresent(viewController: confirmationAlertController)
                }
            }
        }
    }
    
    ///Presents a `UIAlertController` informing the user that the **internet connection is offline.**
    func connectionAlertController()
    {
        var controllerTitle = "Internet Connection Offline"
        var controllerMessage = "The internet connection appears to be offline.\n\nPlease connect to the internet and try again. (0x0)"
        var controllerDismiss = "OK"
        
        if let translatedTitle = noInternetTitleDictionary[languageCode]
        {
            controllerTitle = translatedTitle
        }
        
        if let translatedMessage = noInternetMessageDictionary[languageCode]
        {
            controllerMessage = "\(translatedMessage) (0x0)"
        }
        
        if let translatedDismiss = dismissDictionary[languageCode]
        {
            controllerDismiss = translatedDismiss
        }
        
        //DispatchQueue.main.async {
        let connectionAlertController = UIAlertController(title: controllerTitle, message: controllerMessage, preferredStyle: .alert)
        
        connectionAlertController.addAction(UIAlertAction(title: controllerDismiss, style: .default, handler: nil))
        
        politelyPresent(viewController: connectionAlertController)
        //}
    }
    
    /**
     Presents a `UIAlertController` tailored to **display of errors.**
     
     - Parameter title: The alert controller's `title`. *Default value provided.*
     - Parameter message: The alert controller's `message`. *Default value provided.*
     - Parameter dismissButtonTitle: The `title` of the alert controller's cancel button. *Default value provided.*
     
     - Parameter additionalSelectors: Any **additional options** the user should have.
     - Parameter preferredAdditionalSelector: The **index** of the **additional selector** to become the alert controller's `.preferredAction`.  Used only when *alternateSelectors* is provided.
     
     - Parameter canFileReport:  Set to `true` if the user should be **able to report** this error.
     - Parameter extraInfo:  Represents the *extraneousInformation*  for filing a report. Used only when *canFileReport* is set to `true`.
     
     - Parameter metadata: The metadata Array. Must contain the **file name, function name, and line number** in that order.
     - Parameter networkDependent: Set to `true` when having an internet connection is a **prequesite** for this alert controller's presentation.
     */
    func errorAlertController(title: String?,
                              message: String?,
                              dismissButtonTitle: String?,
                              additionalSelectors: [String:Selector]?,
                              preferredAdditionalSelector: Int?,
                              canFileReport: Bool,
                              extraInfo: String?,
                              metadata: [Any],
                              networkDependent: Bool)
    {
        DispatchQueue.main.async {
            if networkDependent && !hasConnectivity()
            {
                self.connectionAlertController()
            }
            else
            {
                guard validateMetadata(metadata) else { report("Improperly formatted metadata.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return }
                
                let lineNumber = metadata[2] as! Int
                let errorCode = String(format:"%2X", lineNumber)
                
                let controllerTitle = title ?? "Exception *0x\(errorCode)* Occurred"
                let controllerMessage = message != nil ? "\(message!) *(0x\(errorCode))*" : "Unfortunately, an undocumented error has occurred.\n\nNo additional information is available at this time.\n\nIt may be possible to continue working normally, however it is strongly recommended to exit the application to prevent further error or possible data corruption. *(0x\(errorCode))*"
                let controllerCancelButtonTitle = dismissButtonTitle ?? "Dismiss"
                
                var additionalSelectors = additionalSelectors ?? [:]
                
                //Translate everything except for the alterate selector titles.
                Translator().getArrayOfTranslations(fromArray: [controllerTitle, controllerMessage, controllerCancelButtonTitle, "File Report...", "Appended below are various data points useful in determining the cause of the error encountered. Please do not edit the information contained in the lines below."], requiresHud: true) { (returnedStrings) in
                    
                    var sortedKeyArray = additionalSelectors.keys.sorted(by: { $0 < $1 })
                    var iterationCount = sortedKeyArray.count
                    
                    //Translate the alternate selector titles.
                    Translator().getArrayOfTranslations(fromArray: sortedKeyArray, requiresHud: true, completionHandler: { (returnedSelectorStrings) in
                        DispatchQueue.main.async {
                            let errorAlertController = UIAlertController(title: returnedStrings[0], message: returnedStrings[1], preferredStyle: .alert)
                            
                            errorAlertController.addAction(UIAlertAction(title: returnedStrings[2], style: .cancel, handler: nil))
                            
                            //Switch the alternate selector titles to the translated ones.
                            for individualTranslatedString in returnedSelectorStrings
                            {
                                additionalSelectors.switchKey(fromKey: sortedKeyArray[returnedSelectorStrings.firstIndex(of: individualTranslatedString)!], toKey: returnedSelectorStrings[returnedSelectorStrings.firstIndex(of: individualTranslatedString)!])
                            }
                            
                            sortedKeyArray = additionalSelectors.keys.sorted(by: { $0 < $1 })
                            
                            //Add the translated selectors to the alert controller.
                            for individualKey in sortedKeyArray
                            {
                                iterationCount = iterationCount - 1
                                
                                errorAlertController.addAction(UIAlertAction(title: individualKey, style: .default, handler: { (action: UIAlertAction!) in
                                    lastInitialisedController.performSelector(onMainThread: additionalSelectors[individualKey]!, with: nil, waitUntilDone: false)
                                }))
                                
                                //Set the preferred action.
                                if iterationCount == 0
                                {
                                    if let preferredSelector = preferredAdditionalSelector
                                    {
                                        guard errorAlertController.actions.count > preferredSelector + 1 else { report("Preferred Selector index was out of range of the provided Selectors.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return }
                                        
                                        errorAlertController.preferredAction = errorAlertController.actions[preferredSelector + 1]
                                    }
                                }
                            }
                            
                            if canFileReport
                            {
                                let fileName = PresentationManager().retrieveFileName(forFile: metadata[0] as! String)
                                let functionName = (metadata[1] as! String).components(separatedBy: "(")[0]
                                
                                errorAlertController.addAction(UIAlertAction(title: returnedStrings[3], style: .default, handler: { (action: UIAlertAction!) in
                                    self.fileReport(isErrorReport: true,
                                                    withBody: returnedStrings[4],
                                                    withDescriptor: "Error Descriptor",
                                                    withExtraneousInformation: extraInfo,
                                                    withFileName: fileName,
                                                    withFunctionTitle: functionName,
                                                    withLineNumber: lineNumber)
                                }))
                            }
                            
                            politelyPresent(viewController: errorAlertController)
                        }
                    })
                }
            }
        }
    }
    
    ///Displays an expiry alert controller. Should only ever be invoked automatically.
    func expiryAlertController()
    {
        DispatchQueue.main.async {
            var continueUseString = "Continue Use"
            var endOfEvaluationPeriodString = "End of Evaluation Period"
            var exitApplicationString = "Exit Application"
            var incorrectOverrideCodeString = "Incorrect Override Code"
            var incorrectOverrideCodeMessageString = "The code entered was incorrect.\n\nPlease enter the correct expiration override code or exit the application."
            var tryAgainString = "Try Again"
            
            Translator().getArrayOfTranslations(fromArray: [continueUseString, endOfEvaluationPeriodString, exitApplicationString, self.expiryMessage, incorrectOverrideCodeString, incorrectOverrideCodeMessageString, tryAgainString], requiresHud: true) { (returnedStringArray) in
                
                //Set the strings to their translations.
                continueUseString = returnedStringArray[0]
                endOfEvaluationPeriodString = returnedStringArray[1]
                exitApplicationString = returnedStringArray[2]
                self.expiryMessage = returnedStringArray[3]
                incorrectOverrideCodeString = returnedStringArray[4]
                incorrectOverrideCodeMessageString = returnedStringArray[5]
                tryAgainString = returnedStringArray[6]
                
                DispatchQueue.main.async {
                    self.expiryController = UIAlertController(title: endOfEvaluationPeriodString, message: self.expiryMessage, preferredStyle: .alert)
                    
                    self.expiryController.addTextField { (textField) in
                        textField.clearButtonMode = .never
                        textField.isSecureTextEntry = true
                        textField.keyboardAppearance = .light
                        textField.keyboardType = .numberPad
                        textField.placeholder = "\(informationDictionary["bundleVersion"]!) | \(informationDictionary["buildSku"]!)"
                        textField.textAlignment = .center
                    }
                    
                    let continueUseAction = UIAlertAction(title: continueUseString, style: .default) { (action: UIAlertAction!) in
                        let returnedPassword = (self.expiryController!.textFields![0]).text!
                        
                        if returnedPassword == "\(String(format: "%02d", String(codeName.first!).alphabeticalPositionValue))\(String(format: "%02d", String(codeName[codeName.index(codeName.startIndex, offsetBy: Int((Double(codeName.count) / 2).rounded(.down)))]).alphabeticalPositionValue))\(String(format: "%02d", String(codeName.last!).alphabeticalPositionValue))"
                        {
                            invalidateOptionalTimer(withTimer: self.exitTimer)
                            
                            for individualSubview in lastInitialisedController.view.subviews
                            {
                                if individualSubview.tag == 1
                                {
                                    UIView.animate(withDuration: 0.2, animations: {
                                        individualSubview.alpha = 0
                                    }, completion: { (didComplete) in
                                        if didComplete
                                        {
                                            individualSubview.removeFromSuperview()
                                            lastInitialisedController.view.isUserInteractionEnabled = true
                                        }
                                    })
                                }
                            }
                        }
                        else
                        {
                            let incorrectAlertController = UIAlertController(title: incorrectOverrideCodeString, message: incorrectOverrideCodeMessageString, preferredStyle: .alert)
                            
                            incorrectAlertController.addAction(UIAlertAction(title: tryAgainString, style: .default, handler: { (action: UIAlertAction!) in
                                self.expiryAlertController()
                            }))
                            
                            incorrectAlertController.addAction(UIAlertAction(title: exitApplicationString, style: .destructive, handler: { (action: UIAlertAction!) in
                                fatalError()
                            }))
                            
                            incorrectAlertController.preferredAction = incorrectAlertController.actions[0]
                            
                            politelyPresent(viewController: incorrectAlertController)
                        }
                    }
                    
                    continueUseAction.isEnabled = false
                    
                    self.expiryController.addAction(continueUseAction)
                    
                    NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: self.expiryController.textFields![0], queue: .main) { (notification) -> Void in
                        
                        continueUseAction.isEnabled = (self.expiryController.textFields![0].text!.noWhiteSpaceLowerCaseString.length == 6)
                    }
                    
                    self.expiryController.addAction(UIAlertAction(title: exitApplicationString, style: .destructive, handler: { (action: UIAlertAction!) in
                        fatalError()
                    }))
                    
                    self.expiryController.preferredAction = self.expiryController.actions[0]
                    
                    politelyPresent(viewController: self.expiryController)
                    
                    if let unwrappedExitTimer = self.exitTimer
                    {
                        if !unwrappedExitTimer.isValid
                        {
                            self.exitTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AlertKit.decrementSecond), userInfo: nil, repeats: true)
                        }
                    }
                    else
                    {
                        self.exitTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AlertKit.decrementSecond), userInfo: nil, repeats: true)
                    }
                }
            }
        }
    }
    
    ///Displays a fatal error controller.
    func fatalErrorController(extraneousInformation: String?, withFileName: String!, withFunctionTitle: String!, withLineNumber: Int!)
    {
        let clipboardString = "[" + retrieveErrorDescriptor(forFunction: withFunctionTitle, withLineNumber: withLineNumber, withUniqueReferenceCode: randomiseCapitalisation(forString: retrieveUniqueReferenceCode(forString: retrieveFileName(forFile: withFileName)), numericModifier: withLineNumber)) + "]"
        
        var formattedExtraneousInformation: String! = ""
        
        if let unwrappedExtraneousInformation = extraneousInformation
        {
            formattedExtraneousInformation = unwrappedExtraneousInformation.components(separatedBy: CharacterSet.punctuationCharacters).joined()
            
            var semiFinalExtraneousInformation: String! = ""
            
            if formattedExtraneousInformation.components(separatedBy: " ").count == 1
            {
                semiFinalExtraneousInformation = formattedExtraneousInformation.components(separatedBy: " ")[0]
            }
            else if formattedExtraneousInformation.components(separatedBy: " ").count == 2
            {
                semiFinalExtraneousInformation = formattedExtraneousInformation.components(separatedBy: " ")[0] + "_" + formattedExtraneousInformation.components(separatedBy: " ")[1]
            }
            else if formattedExtraneousInformation.components(separatedBy: " ").count > 2
            {
                semiFinalExtraneousInformation = formattedExtraneousInformation.components(separatedBy: " ")[0] + "_" + formattedExtraneousInformation.components(separatedBy: " ")[1] + "_" + formattedExtraneousInformation.components(separatedBy: " ")[2]
            }
            
            formattedExtraneousInformation = "\n\n«" + semiFinalExtraneousInformation.replacingOccurrences(of: " ", with: "_").uppercased() + "»"
        }
        
        Translator().getArrayOfTranslations(fromArray: ["Fatal Exception Occurred", "Unfortunately, a fatal error has occurred. It is not possible to continue working normally – exit the application to prevent further error or possible data corruption.\n\nAn error descriptor has been copied to the clipboard.", "Exit Application", "Continue Execution"], requiresHud: true) { (returnedStringArray) in
            DispatchQueue.main.async {
                let fatalErrorController = UIAlertController(title: returnedStringArray[0], message: returnedStringArray[1] + formattedExtraneousInformation, preferredStyle: .alert)
                
                fatalErrorController.addAction(UIAlertAction(title: returnedStringArray[2], style: .cancel, handler: { (action: UIAlertAction!) in
                    UIPasteboard.general.string = clipboardString
                    fatalError()
                }))
                
                if buildState != .generalRelease
                {
                    fatalErrorController.addAction(UIAlertAction(title: returnedStringArray[3], style: .destructive, handler: { (action: UIAlertAction!) in
                        UIPasteboard.general.string = clipboardString
                    }))
                }
                
                politelyPresent(viewController: fatalErrorController)
            }
        }
    }
    
    ///Displays a fatal error controller.
    func fatalErrorController()
    {
        Translator().getArrayOfTranslations(fromArray: ["Fatal Exception Occurred", "Unfortunately, a fatal error has occurred. It is not possible to continue working normally – exit the application to prevent further error or possible data corruption.", "Exit Application", "Continue Execution"], requiresHud: true) { (returnedStringArray) in
            DispatchQueue.main.async {
                let fatalErrorController = UIAlertController(title: returnedStringArray[0], message: "\(returnedStringArray[1])\n\n«IMPROPERLY_FORMATTED_METADATA»", preferredStyle: .alert)
                
                fatalErrorController.addAction(UIAlertAction(title: returnedStringArray[2], style: .cancel, handler: { (action: UIAlertAction!) in
                    fatalError()
                }))
                
                if buildState != .generalRelease
                {
                    fatalErrorController.addAction(UIAlertAction(title: returnedStringArray[3], style: .destructive, handler: { (action: UIAlertAction!) in
                    }))
                }
                
                politelyPresent(viewController: fatalErrorController)
            }
        }
    }
    
    ///Displays a feedback mail message composition controller.
    func feedbackController(withFileName: String)
    {
        DispatchQueue.main.async {
            Translator().getArrayOfTranslations(fromArray: ["Appended below are various data points useful in analysing any potential problems within the application. Please do not edit the information contained in the lines below, with the exception of the last field, in which a brief description of an incident experienced, or any general feedback, is appreciated.", "Brief Description/General Feedback"], requiresHud: true) { (returnedStrings) in
                
                self.fileReport(isErrorReport: false, withBody: returnedStrings[0], withDescriptor: returnedStrings[1], withExtraneousInformation: nil, withFileName: withFileName, withFunctionTitle: nil, withLineNumber: nil)
            }
        }
    }
    
    ///Displays a customisable option alert controller.
    func optionAlertController(withTitle: String?, withMessage: String?, withCancelButtonTitle: String?, withActions: [String]!, preferredActionIndex: Int?, destructiveActionIndex: Int?, networkDependent: Bool, completionHandler: ((Int?) -> Void)? = nil)
    {
        if networkDependent && !hasConnectivity()
        {
            connectionAlertController()
            completionHandler?(nil)
        }
        else
        {
            let controllerCancelButtonTitle = withCancelButtonTitle ?? "Cancel"
            let controllerMessage = withMessage ?? "Please select an operation you would like to perfom."
            let controllerTitle = withTitle ?? "Select Action"
            
            Translator().getArrayOfTranslations(fromArray: [controllerCancelButtonTitle, controllerMessage, controllerTitle], requiresHud: true) { (returnedStrings) in
                Translator().getArrayOfTranslations(fromArray: withActions, requiresHud: true) { (returnedActionStrings) in
                    DispatchQueue.main.async {
                        let optionAlertController = UIAlertController(title: returnedStrings[2], message: returnedStrings[1], preferredStyle: .alert)
                        
                        optionAlertController.addAction(UIAlertAction(title: returnedStrings[0], style: .cancel, handler: { (action: UIAlertAction!) in
                            completionHandler?(nil)
                        }))
                        
                        for individualAction in returnedActionStrings
                        {
                            if let unwrappedDestructiveActionIndex = destructiveActionIndex
                            {
                                if unwrappedDestructiveActionIndex == returnedActionStrings.firstIndex(of: individualAction)
                                {
                                    optionAlertController.addAction(UIAlertAction(title: individualAction, style: .destructive, handler: { (action: UIAlertAction!) in
                                        completionHandler?(returnedActionStrings.firstIndex(of: individualAction)!)
                                    }))
                                }
                                else
                                {
                                    optionAlertController.addAction(UIAlertAction(title: individualAction, style: .default, handler: { (action: UIAlertAction!) in
                                        completionHandler?(returnedActionStrings.firstIndex(of: individualAction)!)
                                    }))
                                }
                            }
                            else
                            {
                                optionAlertController.addAction(UIAlertAction(title: individualAction, style: .default, handler: { (action: UIAlertAction!) in
                                    completionHandler?(returnedActionStrings.firstIndex(of: individualAction)!)
                                }))
                            }
                        }
                        
                        if let unwrappedPreferredActionIndex = preferredActionIndex
                        {
                            optionAlertController.preferredAction = optionAlertController.actions[unwrappedPreferredActionIndex + 1]
                        }
                        
                        politelyPresent(viewController: optionAlertController)
                    }
                }
            }
        }
    }
    
    ///Displays a customisable protected alert controller.
    ///A return value of 0 is a correct entry.
    ///A return value of 1 is an incorrect entry.
    ///A return value of 2 is a blank entry.
    func protectedAlertController(withTitle: String?, withMessage: String?, withConfirmationButtonTitle: String?, withCancelButtonTitle: String?, confirmationDestructive: Bool!, confirmationPreferred: Bool!, correctPassword: String!, networkDependent: Bool!, keyboardAppearance: UIKeyboardAppearance?, keyboardType: UIKeyboardType?, editingMode: UITextField.ViewMode?, sampleText: String?, placeHolder: String?, textAlignment: NSTextAlignment?, completionHandler: @escaping (Int?) -> Void)
    {
        if networkDependent && !hasConnectivity()
        {
            connectionAlertController()
            completionHandler(nil)
        }
        else
        {
            let controllerCancelButtonTitle = withCancelButtonTitle ?? "Cancel"
            let controllerConfirmationButtonTitle = withConfirmationButtonTitle ?? "Confirm"
            let controllerMessage = withMessage ?? "Please enter the password to perform this operation."
            let controllerPlaceHolder = placeHolder ?? "Required"
            let controllerSampleText = sampleText ?? ""
            let controllerTitle = withTitle ?? "Enter Password"
            
            Translator().getArrayOfTranslations(fromArray: [controllerCancelButtonTitle, controllerConfirmationButtonTitle, controllerMessage, controllerPlaceHolder, controllerSampleText, controllerTitle], requiresHud: true) { (returnedStrings) in
                DispatchQueue.main.async {
                    let protectedAlertController = UIAlertController(title: returnedStrings[5], message: returnedStrings[2], preferredStyle: .alert)
                    
                    let controllerEditingMode = editingMode ?? .never
                    let controllerKeyboardAppearance = keyboardAppearance ?? .light
                    let controllerKeyboardType = keyboardType ?? .default
                    let controllerTextAlignment = textAlignment ?? .left
                    
                    protectedAlertController.addTextField { (textField) in
                        textField.clearButtonMode = controllerEditingMode
                        textField.isSecureTextEntry = true
                        textField.keyboardAppearance = controllerKeyboardAppearance
                        textField.keyboardType = controllerKeyboardType
                        textField.placeholder = returnedStrings[3]
                        textField.text = returnedStrings[4]
                        textField.textAlignment = controllerTextAlignment
                    }
                    
                    var confirmationButtonStyle = UIAlertAction.Style.default
                    
                    if confirmationDestructive!
                    {
                        confirmationButtonStyle = .destructive
                    }
                    
                    protectedAlertController.addAction(UIAlertAction(title: returnedStrings[1], style: confirmationButtonStyle) { [protectedAlertController] (action: UIAlertAction!) in
                        let returnedPassword = (protectedAlertController.textFields![0]).text!
                        
                        if returnedPassword.noWhiteSpaceLowerCaseString != ""
                        {
                            if returnedPassword == correctPassword
                            {
                                completionHandler(0)
                            }
                            else
                            {
                                completionHandler(1)
                            }
                        }
                        else
                        {
                            completionHandler(2)
                        }
                    })
                    
                    protectedAlertController.addAction(UIAlertAction(title: returnedStrings[0], style: .cancel, handler: { (action: UIAlertAction!) in
                        completionHandler(nil)
                    }))
                    
                    if confirmationPreferred!
                    {
                        protectedAlertController.preferredAction = protectedAlertController.actions[0]
                    }
                    
                    politelyPresent(viewController: protectedAlertController)
                }
            }
        }
    }
    
    ///Retrieves a neatly formatted file name for any passed controller name.
    func retrieveFileName(forFile: String) -> String
    {
        let filePath = forFile.components(separatedBy: "/")
        let fileName = filePath[filePath.count - 1].components(separatedBy: ".")[0].replacingOccurrences(of: "-", with: "")
        
        return fileName.stringCharacters[0].uppercased() + fileName.stringCharacters[1...fileName.stringCharacters.count - 1].joined(separator: "")
    }
    
    ///Displays a customisable success alert controller.
    func successAlertController(withTitle: String?, withMessage: String?, withCancelButtonTitle: String?, withAlternateSelectors: [String:Selector]?, preferredActionIndex: Int?)
    {
        let controllerCancelButtonTitle = withCancelButtonTitle ?? "Dismiss"
        let controllerMessage = withMessage ?? "The operation completed successfully."
        let controllerTitle = withTitle ?? "Operation Successful"
        
        var alternateSelectors = withAlternateSelectors ?? [:]
        
        //Translate everything except for the alterate selector titles.
        Translator().getArrayOfTranslations(fromArray: [controllerCancelButtonTitle, controllerMessage, controllerTitle], requiresHud: true) { (returnedStrings) in
            
            var sortedKeyArray = alternateSelectors.keys.sorted(by: { $0 < $1 })
            var iterationCount = sortedKeyArray.count
            
            //Translate the alternate selector titles.
            Translator().getArrayOfTranslations(fromArray: sortedKeyArray, requiresHud: true, completionHandler: { (returnedSelectorStrings) in
                DispatchQueue.main.async {
                    let successAlertController = UIAlertController(title: returnedStrings[2], message: returnedStrings[1], preferredStyle: .alert)
                    
                    successAlertController.addAction(UIAlertAction(title: returnedStrings[0], style: .cancel, handler: nil))
                    
                    //Switch the alternate selector titles to the translated ones.
                    for individualTranslatedString in returnedSelectorStrings
                    {
                        alternateSelectors.switchKey(fromKey: sortedKeyArray[returnedSelectorStrings.firstIndex(of: individualTranslatedString)!], toKey: returnedSelectorStrings[returnedSelectorStrings.firstIndex(of: individualTranslatedString)!])
                    }
                    
                    sortedKeyArray = alternateSelectors.keys.sorted(by: { $0 < $1 })
                    
                    //Add the translated selectors to the alert controller.
                    for individualKey in sortedKeyArray
                    {
                        iterationCount = iterationCount - 1
                        
                        successAlertController.addAction(UIAlertAction(title: individualKey, style: .default, handler: { (action: UIAlertAction!) in
                            lastInitialisedController.performSelector(onMainThread: alternateSelectors[individualKey]!, with: nil, waitUntilDone: false)
                        }))
                        
                        //Set the preferred action.
                        if iterationCount == 0
                        {
                            if let unwrappedPreferredActionIndex = preferredActionIndex
                            {
                                successAlertController.preferredAction = successAlertController.actions[unwrappedPreferredActionIndex + 1]
                            }
                        }
                    }
                    
                    politelyPresent(viewController: successAlertController)
                }
            })
        }
    }
    
    ///Displays a customisable text alert controller.
    func textAlertController(withTitle: String?, withMessage: String?, withCancelButtonTitle: String?, withActions: [String]!, preferredActionIndex: Int?, destructiveActionIndex: Int?, networkDependent: Bool!, capitalisationType: UITextAutocapitalizationType?, correctionType: UITextAutocorrectionType?, keyboardAppearance: UIKeyboardAppearance?, keyboardType: UIKeyboardType?, editingMode: UITextField.ViewMode?, sampleText: String?, placeHolder: String?, textAlignment: NSTextAlignment?, completionHandler: @escaping (String?, Int?) -> Void)
    {
        if networkDependent && !hasConnectivity()
        {
            connectionAlertController()
            completionHandler(nil, nil)
        }
        else
        {
            let controllerCancelButtonTitle = withCancelButtonTitle ?? "Cancel"
            let controllerMessage = withMessage ?? "Please enter some text."
            let controllerPlaceHolder = placeHolder ?? "Here's to the crazy ones."
            let controllerSampleText = sampleText ?? ""
            let controllerTitle = withTitle ?? "Enter Text"
            
            Translator().getArrayOfTranslations(fromArray: [controllerCancelButtonTitle, controllerMessage, controllerPlaceHolder, controllerSampleText, controllerTitle], requiresHud: true) { (returnedStrings) in
                Translator().getArrayOfTranslations(fromArray: withActions, requiresHud: true, completionHandler: { (returnedActionStrings) in
                    DispatchQueue.main.async {
                        let textAlertController = UIAlertController(title: returnedStrings[4], message: returnedStrings[1], preferredStyle: .alert)
                        
                        let controllerCapitalisationType = capitalisationType ?? .sentences
                        let controllerCorrectionType = correctionType ?? .default
                        let controllerEditingMode = editingMode ?? .never
                        let controllerKeyboardAppearance = keyboardAppearance ?? .light
                        let controllerKeyboardType = keyboardType ?? .default
                        let controllerTextAlignment = textAlignment ?? .left
                        
                        textAlertController.addTextField { (textField) in
                            textField.autocapitalizationType = controllerCapitalisationType
                            textField.autocorrectionType = controllerCorrectionType
                            textField.clearButtonMode = controllerEditingMode
                            textField.isSecureTextEntry = false
                            textField.keyboardAppearance = controllerKeyboardAppearance
                            textField.keyboardType = controllerKeyboardType
                            textField.placeholder = returnedStrings[2]
                            textField.text = returnedStrings[3]
                            textField.textAlignment = controllerTextAlignment
                        }
                        
                        textAlertController.addAction(UIAlertAction(title: returnedStrings[0], style: .cancel, handler: { (action: UIAlertAction!) in
                            completionHandler(nil, nil)
                        }))
                        
                        for individualAction in returnedActionStrings
                        {
                            if let unwrappedDestructiveActionIndex = destructiveActionIndex
                            {
                                if unwrappedDestructiveActionIndex == returnedActionStrings.firstIndex(of: individualAction)
                                {
                                    textAlertController.addAction(UIAlertAction(title: individualAction, style: .destructive, handler: { (action: UIAlertAction!) in
                                        completionHandler((textAlertController.textFields![0]).text!, returnedActionStrings.firstIndex(of: individualAction)!)
                                    }))
                                }
                                else
                                {
                                    textAlertController.addAction(UIAlertAction(title: individualAction, style: .default, handler: { (action: UIAlertAction!) in
                                        completionHandler((textAlertController.textFields![0]).text!, returnedActionStrings.firstIndex(of: individualAction)!)
                                    }))
                                }
                            }
                            else
                            {
                                textAlertController.addAction(UIAlertAction(title: individualAction, style: .default, handler: { (action: UIAlertAction!) in
                                    completionHandler((textAlertController.textFields![0]).text!, returnedActionStrings.firstIndex(of: individualAction)!)
                                }))
                            }
                        }
                        
                        if let unwrappedPreferredActionIndex = preferredActionIndex
                        {
                            textAlertController.preferredAction = textAlertController.actions[unwrappedPreferredActionIndex + 1]
                        }
                        
                        politelyPresent(viewController: textAlertController)
                    }
                })
            }
        }
    }
    
    //--------------------------------------------------//
    
    //Private Functions
    
    ///Decrements one second from the expiry counter. If it reaches less than zero, it kills the application.
    @objc private func decrementSecond()
    {
        decrementSeconds -= 1
        
        if decrementSeconds < 0
        {
            invalidateOptionalTimer(withTimer: exitTimer)
            
            lastInitialisedController.dismiss(animated: true, completion: {
                Translator().getArrayOfTranslations(fromArray: ["Time Expired", "The application will now exit."], requiresHud: true, completionHandler: { (returnedStringArray) in
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: returnedStringArray[0], message: returnedStringArray[1], preferredStyle: .alert)
                        
                        lastInitialisedController.present(alertController, animated: true, completion: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                fatalError()
                            })
                        })
                    }
                })
            })
        }
        else
        {
            var decrementString = String(decrementSeconds)
            
            if decrementString.length == 1
            {
                decrementString = "0\(decrementSeconds)"
            }
            
            expiryMessage = "\(expiryMessage.components(separatedBy: ":")[0]): 00:\(decrementString)."
            
            expiryController.message = expiryMessage
        }
    }
    
    ///Sets up and formats the information required for a feedback or error report.
    private func fileReport(isErrorReport: Bool, withBody: String, withDescriptor: String, withExtraneousInformation: String?, withFileName: String, withFunctionTitle: String?, withLineNumber: Int?)
    {
        //Set up the date formatter.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_GB")
        
        //Set the connection status variable.
        var connectionStatus = "online"
        
        if !hasConnectivity()
        {
            connectionStatus = "offline"
        }
        
        var reportType = "Feedback"
        
        //Set the first part variable depending on whether or not it is an error report.
        var firstPart = "<i>\(withBody.split(separator: ".")[0])</i><p></p><b>Project ID:</b> \(informationDictionary["projectIdentifier"]!)<p></p><b>Build SKU:</b> \(informationDictionary["buildSku"]!)<p></p><b>Occurrence Date:</b> \(dateFormatter.string(from: Date()))<p></p><b>Internet Connection Status:</b> \(connectionStatus)<p></p><b>Event Descriptor:</b> "
        
        if withBody.split(separator: ".").count > 1
        {
            firstPart = "<i>\(withBody.split(separator: ".")[0]).<p></p>\(withBody.split(separator: ".")[1]).</i><p></p><b>Project ID:</b> \(informationDictionary["projectIdentifier"]!)<p></p><b>Build SKU:</b> \(informationDictionary["buildSku"]!)<p></p><b>Occurrence Date:</b> \(dateFormatter.string(from: Date()))<p></p><b>Internet Connection Status:</b> \(connectionStatus)<p></p><b>Event Descriptor:</b> "
        }
        
        if isErrorReport
        {
            reportType = "Feedback"
            
            if let unwrappedExtraneousInformation = withExtraneousInformation
            {
                firstPart = "<i>\(withBody.split(separator: ".")[0]).<p></p>\(withBody.split(separator: ".")[1]).</i><p></p><b>Project ID:</b> \(informationDictionary["projectIdentifier"]!)<p></p><b>Build SKU:</b> \(informationDictionary["buildSku"]!)<p></p><b>Occurrence Date:</b> \(dateFormatter.string(from: Date()))<p></p><b>Internet Connection Status:</b> \(connectionStatus)<p></p><b>Extraneous Information:</b> \(unwrappedExtraneousInformation)<p></p><b>\(withDescriptor):</b> "
            }
            else
            {
                firstPart = "<i>\(withBody.split(separator: ".")[0]).<p></p>\(withBody.split(separator: ".")[1]).</i><p></p><b>Project ID:</b> \(informationDictionary["projectIdentifier"]!)<p></p><b>Build SKU:</b> \(informationDictionary["buildSku"]!)<p></p><b>Occurrence Date:</b> \(dateFormatter.string(from: Date()))<p></p><b>Internet Connection Status:</b> \(connectionStatus)<p></p><b>\(withDescriptor):</b> "
            }
        }
        
        //Set the second part variable depending on whether or not it is an error report.
        var secondPart = "[" + retrieveEventDescriptor(forFile: retrieveFileName(forFile: withFileName)) + "]<p></p><b>\(withDescriptor):</b> "
        
        if let unwrappedFunctionTitle = withFunctionTitle, let unwrappedLineNumber = withLineNumber
        {
            secondPart = "[" + retrieveErrorDescriptor(forFunction: unwrappedFunctionTitle, withLineNumber: unwrappedLineNumber, withUniqueReferenceCode: randomiseCapitalisation(forString: retrieveUniqueReferenceCode(forString: retrieveFileName(forFile: withFileName)), numericModifier: unwrappedLineNumber)) + "]"
        }
        
        print(firstPart + secondPart)
        
        composeMessage(withMessage: (firstPart + secondPart), withRecipients: ["support@neotechnica.us"], withSubject: "\((preReleaseApplication ? codeName : finalName)) (\(informationDictionary["bundleVersion"]!)) \(reportType) Report", isHtmlMessage: true)
    }
    
    ///Randomises the capitalisation for a given string and numeric modifier.
    private func randomiseCapitalisation(forString: String, numericModifier: Int) -> String
    {
        var returnedString = ""
        var incrementCount = forString.count
        
        for individualCharacter in forString
        {
            incrementCount = incrementCount - 1
            
            if ((numericModifier + incrementCount) % 2) == 0
            {
                returnedString = returnedString + String(individualCharacter).uppercased()
            }
            else
            {
                returnedString = returnedString + String(individualCharacter).lowercased()
            }
            
            if incrementCount == 0
            {
                return returnedString
            }
        }
        
        return ""
    }
    
    ///Retrieves the error descriptor for a function, line number, and unique reference code.
    private func retrieveErrorDescriptor(forFunction: String, withLineNumber: Int, withUniqueReferenceCode: String) -> String
    {
        let mainErrorCode = randomiseCapitalisation(forString: cipherString(withString: forFunction.components(separatedBy: "(")[0].lowercased(), shiftModifier: (14)), numericModifier: withLineNumber)
        
        let compiledDescriptor = "\(SystemInformation.modelCode.lowercased()).\(mainErrorCode)-\(withLineNumber)-\(withUniqueReferenceCode).\(SystemInformation.operatingSystemVersion.lowercased())"
        
        return compiledDescriptor
    }
    
    ///Retrieves the event descriptor for a file name.
    private func retrieveEventDescriptor(forFile: String) -> String
    {
        let mainEventCode = randomiseCapitalisation(forString: cipherString(withString: forFile.lowercased(), shiftModifier: (14)), numericModifier: 14)
        
        let compiledDescriptor = "\(SystemInformation.modelCode.lowercased()).\(mainEventCode).\(SystemInformation.operatingSystemVersion.lowercased())"
        
        return compiledDescriptor
    }
    
    ///Retrieves a reference code for a given string.
    private func retrieveUniqueReferenceCode(forString: String) -> String
    {
        var returnedString = String(forString.first!)
        
        for individualCharacter in forString
        {
            if String(individualCharacter).lowercased() != String(individualCharacter)
            {
                returnedString = returnedString + String(individualCharacter)
            }
        }
        
        return (returnedString + String(forString.last!))
    }
}
