//
//  AlertKit.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import UIKit

/* Third-party Frameworks */
import Reachability

class AlertKit {
    
    //==================================================//
    
    /* MARK: - Class-level Variable Declarations */
    
    //Other Declarations
    var decrementSeconds = 30
    var exitTimer: Timer?
    var expiryController: UIAlertController!
    var expiryMessage = "The evaluation period for this pre-release build of \(codeName) has ended.\n\nTo continue using this version, enter the six-digit expiration override code associated with it.\n\nUntil updated to a newer build, entry of this code will be required each time the application is launched.\n\nTime remaining for successful entry: 00:30."
    
    //==================================================//
    
    /* MARK: - Enumerated Type Declarations */
    
    enum AlertControllerTextFieldAttribute {
        case capitalisationType
        case correctionType
        case editingMode
        case keyboardAppearance
        case keyboardType
        case placeholderText
        case sampleText
        case secureTextEntry
        case textAlignment
    }
    
    enum ReportType {
        case bug
        case error
        case feedback
    }
    
    //==================================================//
    
    /* MARK: - Alert Controller Functions */
    
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
                                     completion: @escaping (_ didConfirm: Bool?) -> Void) {
        if networkDepedent && !hasConnectivity() {
            connectionAlertController()
            completion(nil)
        } else {
            let controllerTitle = title ?? "Confirm Operation"
            let controllerMessage = message ?? "Are you sure you would like to perform this operation?"
            
            let cancelButtonTitle = cancelConfirmTitles["cancel"] ?? "Cancel"
            let confirmationButtonTitle = cancelConfirmTitles["confirm"] ?? "Confirm"
            
            let confirmationAlertController = UIAlertController(title: controllerTitle, message: controllerMessage, preferredStyle: .alert)
            
            let confirmationButtonStyle = confirmationDestructive ? UIAlertAction.Style.destructive : UIAlertAction.Style.default
            
            confirmationAlertController.addAction(UIAlertAction(title: confirmationButtonTitle, style: confirmationButtonStyle, handler: { (_: UIAlertAction!) in
                completion(true)
            }))
            
            confirmationAlertController.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: { (_: UIAlertAction!) in
                completion(false)
            }))
            
            confirmationAlertController.preferredAction = confirmationPreferred ? confirmationAlertController.actions[0] : nil
            
            politelyPresent(viewController: confirmationAlertController)
        }
    }
    
    ///Presents a `UIAlertController` informing the user that the **internet connection is offline.**
    func connectionAlertController() {
        let controllerTitle = "Internet Connection Offline"
        let controllerMessage = "The internet connection appears to be offline.\n\nPlease connect to the internet and try again. (0x0)"
        let controllerDismiss = "OK"
        
        let connectionAlertController = UIAlertController(title: controllerTitle, message: controllerMessage, preferredStyle: .alert)
        
        connectionAlertController.addAction(UIAlertAction(title: controllerDismiss, style: .default, handler: nil))
        
        politelyPresent(viewController: connectionAlertController)
    }
    
    /**
     Presents a `UIAlertController` tailored to **display of errors.**
     
     - Parameter title: The alert controller's `title`. *Default value provided.*
     - Parameter message: The alert controller's `message`. *Default value provided.*
     - Parameter dismissButtonTitle: The `title` of the alert controller's cancel button. *Default value provided.*
     
     - Parameter additionalSelectors: Any **additional options** the user should have.
     - Parameter preferredAdditionalSelector: The **index** of the **additional selector** to become the alert controller's `.preferredAction`.  Used only when *alternateSelectors* is provided.
     
     - Parameter canFileReport: Set to `true` if the user should be **able to report** this error.
     - Parameter extraInfo: Represents the *extraneousInformation*  for filing a report. Used only when *canFileReport* is set to `true`.
     
     - Parameter metadata: The metadata Array. Must contain the **file name, function name, and line number** in that order.
     - Parameter networkDependent: Set to `true` when having an internet connection is a **prequesite** for this alert controller's presentation.
     */
    func errorAlertController(title: String?,
                              message: String?,
                              dismissButtonTitle: String?,
                              additionalSelectors: [String: Selector]?,
                              preferredAdditionalSelector: Int?,
                              canFileReport: Bool,
                              extraInfo: String?,
                              metadata: [Any],
                              networkDependent: Bool) {
        DispatchQueue.main.async {
            if networkDependent && !hasConnectivity() {
                self.connectionAlertController()
            } else {
                guard validateMetadata(metadata) else {
                    report("Improperly formatted metadata.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                    return
                }
                
                let lineNumber = metadata[2] as! Int
                let errorCode = String(format: "%2X", lineNumber)
                
                let controllerTitle = title ?? "Exception 0x\(errorCode) Occurred"
                let controllerMessage = message != nil ? "\(message!) (0x\(errorCode))" : "Unfortunately, an undocumented error has occurred.\n\nNo additional information is available at this time.\n\nIt may be possible to continue working normally, however it is strongly recommended to exit the application to prevent further error or possible data corruption. (0x\(errorCode))"
                let controllerCancelButtonTitle = dismissButtonTitle ?? "Dismiss"
                
                let additionalSelectors = additionalSelectors ?? [:]
                
                let sortedKeyArray = additionalSelectors.keys.sorted(by: { $0 < $1 })
                var iterationCount = sortedKeyArray.count
                
                let errorAlertController = UIAlertController(title: controllerTitle, message: controllerMessage, preferredStyle: .alert)
                
                errorAlertController.addAction(UIAlertAction(title: controllerCancelButtonTitle, style: .cancel, handler: nil))
                
                //Add the additional selectors to the alert controller.
                for individualKey in sortedKeyArray {
                    iterationCount = iterationCount - 1
                    
                    errorAlertController.addAction(UIAlertAction(title: individualKey, style: .default, handler: { (_: UIAlertAction!) in
                        lastInitializedController.performSelector(onMainThread: additionalSelectors[individualKey]!, with: nil, waitUntilDone: false)
                    }))
                    
                    //Set the preferred action.
                    if iterationCount == 0 {
                        if let preferredSelector = preferredAdditionalSelector {
                            guard errorAlertController.actions.count > preferredSelector + 1 else {
                                report("Preferred Selector index was out of range of the provided Selectors.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                                return
                            }
                            
                            errorAlertController.preferredAction = errorAlertController.actions[preferredSelector + 1]
                        }
                    }
                }
                
                if canFileReport {
                    let fileName = AlertKit().retrieveFileName(forFile: metadata[0] as! String)
                    let functionName = (metadata[1] as! String).components(separatedBy: "(")[0]
                    
                    errorAlertController.addAction(UIAlertAction(title: "File Report...", style: .default, handler: { (_: UIAlertAction!) in
                        self.fileReport(type: .error, body: "Appended below are various data points useful in determining the cause of the error encountered. Please do not edit the information contained in the lines below.", prompt: "Error Descriptor", extraInfo: extraInfo, metadata: [fileName, functionName, lineNumber])
                    }))
                }
                
                politelyPresent(viewController: errorAlertController)
            }
        }
    }
    
    /**
     Presents a `UIAlertController` tailored to **display of errors.**
     
     - Parameter title: The alert controller's `title`. *Default value provided.*
     - Parameter message: The alert controller's `message`. *Default value provided.*
     - Parameter dismissButtonTitle: The `title` of the alert controller's cancel button. *Default value provided.*
     
     - Parameter additionalSelectors: Any **additional options** the user should have.
     - Parameter preferredAdditionalSelector: The **index** of the **additional selector** to become the alert controller's `.preferredAction`.  Used only when *alternateSelectors* is provided.
     
     - Parameter canFileReport: Set to `true` if the user should be **able to report** this error.
     - Parameter extraInfo: Represents the *extraneousInformation*  for filing a report. Used only when *canFileReport* is set to `true`.
     
     - Parameter metadata: The metadata Array. Must contain the **file name, function name, and line number** in that order.
     - Parameter networkDependent: Set to `true` when having an internet connection is a **prequesite** for this alert controller's presentation.
     
     - Parameter completion: Called upon the user's selection of an action.
     */
    func errorAlertController(title: String?,
                              message: String?,
                              dismissButtonTitle: String?,
                              additionalSelectors: [String: Selector]?,
                              preferredAdditionalSelector: Int?,
                              canFileReport: Bool,
                              extraInfo: String?,
                              metadata: [Any],
                              networkDependent: Bool,
                              completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            if networkDependent && !hasConnectivity() {
                self.connectionAlertController()
            } else {
                guard validateMetadata(metadata) else {
                    report("Improperly formatted metadata.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                    return
                }
                
                let lineNumber = metadata[2] as! Int
                let errorCode = String(format: "%2X", lineNumber)
                
                let controllerTitle = title ?? "Exception 0x\(errorCode) Occurred"
                let controllerMessage = message != nil ? "\(message!) (0x\(errorCode))" : "Unfortunately, an undocumented error has occurred.\n\nNo additional information is available at this time.\n\nIt may be possible to continue working normally, however it is strongly recommended to exit the application to prevent further error or possible data corruption. (0x\(errorCode))"
                let controllerCancelButtonTitle = dismissButtonTitle ?? "Dismiss"
                
                let additionalSelectors = additionalSelectors ?? [:]
                
                let sortedKeyArray = additionalSelectors.keys.sorted(by: { $0 < $1 })
                var iterationCount = sortedKeyArray.count
                
                let errorAlertController = UIAlertController(title: controllerTitle, message: controllerMessage, preferredStyle: .alert)
                
                errorAlertController.addAction(UIAlertAction(title: controllerCancelButtonTitle, style: .cancel, handler: { (_: UIAlertAction!) in
                    completion()
                }))
                
                //Add the additional selectors to the alert controller.
                for individualKey in sortedKeyArray {
                    iterationCount = iterationCount - 1
                    
                    errorAlertController.addAction(UIAlertAction(title: individualKey, style: .default, handler: { (_: UIAlertAction!) in
                        lastInitializedController.performSelector(onMainThread: additionalSelectors[individualKey]!, with: nil, waitUntilDone: false)
                        completion()
                    }))
                    
                    //Set the preferred action.
                    if iterationCount == 0 {
                        if let preferredSelector = preferredAdditionalSelector {
                            guard errorAlertController.actions.count > preferredSelector + 1 else {
                                report("Preferred Selector index was out of range of the provided Selectors.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                                return
                            }
                            
                            errorAlertController.preferredAction = errorAlertController.actions[preferredSelector + 1]
                        }
                    }
                }
                
                if canFileReport {
                    let fileName = AlertKit().retrieveFileName(forFile: metadata[0] as! String)
                    let functionName = (metadata[1] as! String).components(separatedBy: "(")[0]
                    
                    errorAlertController.addAction(UIAlertAction(title: "File Report...", style: .default, handler: { (_: UIAlertAction!) in
                        self.fileReport(type: .error, body: "Appended below are various data points useful in determining the cause of the error encountered. Please do not edit the information contained in the lines below.", prompt: "Error Descriptor", extraInfo: extraInfo, metadata: [fileName, functionName, lineNumber])
                        completion()
                    }))
                }
                
                politelyPresent(viewController: errorAlertController)
            }
        }
    }
    
    ///Displays an expiry alert controller. Should only ever be invoked automatically.
    func expiryAlertController() {
        DispatchQueue.main.async {
            let continueUseString = "Continue Use"
            let endOfEvaluationPeriodString = "End of Evaluation Period"
            let exitApplicationString = "Exit Application"
            let incorrectOverrideCodeString = "Incorrect Override Code"
            let incorrectOverrideCodeMessageString = "The code entered was incorrect.\n\nPlease enter the correct expiration override code or exit the application."
            let tryAgainString = "Try Again"
            
            self.expiryController = UIAlertController(title: endOfEvaluationPeriodString, message: self.expiryMessage, preferredStyle: .alert)
            
            self.expiryController.addTextField { textField in
                textField.clearButtonMode = .never
                textField.isSecureTextEntry = true
                textField.keyboardAppearance = .light
                textField.keyboardType = .numberPad
                textField.placeholder = "\(informationDictionary["bundleVersion"]!) | \(informationDictionary["buildSku"]!)"
                textField.textAlignment = .center
            }
            
            let continueUseAction = UIAlertAction(title: continueUseString, style: .default) { (_: UIAlertAction!) in
                let returnedPassword = (self.expiryController!.textFields![0]).text!
                
                if returnedPassword == "\(String(format: "%02d", String(codeName.first!).alphabeticalPosition))\(String(format: "%02d", String(codeName[codeName.index(codeName.startIndex, offsetBy: Int((Double(codeName.count) / 2).rounded(.down)))]).alphabeticalPosition))\(String(format: "%02d", String(codeName.last!).alphabeticalPosition))" {
                    self.exitTimer?.invalidate()
                    
                    for individualSubview in lastInitializedController.view.subviews {
                        if individualSubview.tag == 1 {
                            UIView.animate(withDuration: 0.2, animations: {
                                individualSubview.alpha = 0
                            }, completion: { didComplete in
                                if didComplete {
                                    individualSubview.removeFromSuperview()
                                    lastInitializedController.view.isUserInteractionEnabled = true
                                }
                            })
                        }
                    }
                } else {
                    let incorrectAlertController = UIAlertController(title: incorrectOverrideCodeString, message: incorrectOverrideCodeMessageString, preferredStyle: .alert)
                    
                    incorrectAlertController.addAction(UIAlertAction(title: tryAgainString, style: .default, handler: { (_: UIAlertAction!) in
                        self.expiryAlertController()
                    }))
                    
                    incorrectAlertController.addAction(UIAlertAction(title: exitApplicationString, style: .destructive, handler: { (_: UIAlertAction!) in
                        fatalError()
                    }))
                    
                    incorrectAlertController.preferredAction = incorrectAlertController.actions[0]
                    
                    politelyPresent(viewController: incorrectAlertController)
                }
            }
            
            continueUseAction.isEnabled = false
            
            self.expiryController.addAction(continueUseAction)
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: self.expiryController.textFields![0], queue: .main) { (_) -> Void in
                
                continueUseAction.isEnabled = (self.expiryController.textFields![0].text!.lowercasedTrimmingWhitespace.count == 6)
            }
            
            self.expiryController.addAction(UIAlertAction(title: exitApplicationString, style: .destructive, handler: { (_: UIAlertAction!) in
                fatalError()
            }))
            
            self.expiryController.preferredAction = self.expiryController.actions[0]
            
            politelyPresent(viewController: self.expiryController)
            
            if let unwrappedExitTimer = self.exitTimer {
                if !unwrappedExitTimer.isValid {
                    self.exitTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AlertKit.decrementSecond), userInfo: nil, repeats: true)
                }
            } else {
                self.exitTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AlertKit.decrementSecond), userInfo: nil, repeats: true)
            }
        }
    }
    
    /**
     Presents a `UIAlertController` for **fatal errors.**
     
     - Parameter extraInfo: Provide this when there is **extra information** about the cause of the error.
     - Parameter metadata: The metadata Array. Must contain the **file name, function name, and line number** in that order.
     */
    func fatalErrorController(extraInfo: String?, metadata: [Any]) {
        guard let code = code(for: .error, metadata: metadata) else {
            report("Unable to generate code.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
            return
        }
        
        let clipboardString = "[\(code)]"
        
        var formattedExtraInfo: String! = ""
        
        if let unwrappedExtraInfo = extraInfo {
            formattedExtraInfo = strippedDescriptor(for: unwrappedExtraInfo)
            
            formattedExtraInfo = formattedExtraInfo.components(separatedBy: CharacterSet.punctuationCharacters).joined()
            
            var semiFinalExtraInfo: String! = ""
            
            if formattedExtraInfo.components(separatedBy: " ").count == 1 {
                semiFinalExtraInfo = formattedExtraInfo.components(separatedBy: " ")[0]
            } else if formattedExtraInfo.components(separatedBy: " ").count == 2 {
                semiFinalExtraInfo = formattedExtraInfo.components(separatedBy: " ")[0] + "_" + formattedExtraInfo.components(separatedBy: " ")[1]
            } else if formattedExtraInfo.components(separatedBy: " ").count > 2 {
                semiFinalExtraInfo = formattedExtraInfo.components(separatedBy: " ")[0] + "_" + formattedExtraInfo.components(separatedBy: " ")[1] + "_" + formattedExtraInfo.components(separatedBy: " ")[2]
            }
            
            formattedExtraInfo = "\n\n«" + semiFinalExtraInfo.replacingOccurrences(of: " ", with: "_").uppercased() + "»"
        }
        
        let fatalErrorController = UIAlertController(title: "Fatal Exception Occurred", message: "Unfortunately, a fatal error has occurred. It is not possible to continue working normally – exit the application to prevent further error or possible data corruption.\n\nAn error descriptor has been copied to the clipboard." + formattedExtraInfo, preferredStyle: .alert)
        
        fatalErrorController.addAction(UIAlertAction(title: "Exit Application", style: .cancel, handler: { (_: UIAlertAction!) in
            UIPasteboard.general.string = clipboardString
            fatalError()
        }))
        
        if buildType != .generalRelease {
            fatalErrorController.addAction(UIAlertAction(title: "Continue Execution", style: .destructive, handler: { (_: UIAlertAction!) in
                UIPasteboard.general.string = clipboardString
            }))
        }
        
        politelyPresent(viewController: fatalErrorController)
    }
    
    ///Displays a fatal error controller.
    func fatalErrorController() {
        let fatalErrorController = UIAlertController(title: "Fatal Exception Occurred", message: "Unfortunately, a fatal error has occurred. It is not possible to continue working normally – exit the application to prevent further error or possible data corruption.\n\n«IMPROPERLY_FORMATTED_METADATA»", preferredStyle: .alert)
        
        fatalErrorController.addAction(UIAlertAction(title: "Exit Application", style: .cancel, handler: { (_: UIAlertAction!) in
            fatalError()
        }))
        
        if buildType != .generalRelease {
            fatalErrorController.addAction(UIAlertAction(title: "Continue Execution", style: .destructive, handler: { (_: UIAlertAction!) in
            }))
        }
        
        politelyPresent(viewController: fatalErrorController)
    }
    
    ///Displays a feedback mail message composition controller.
    func feedbackController(withFileName: String) {
        fileReport(type: .feedback, body: "Appended below are various data points useful in analysing any potential problems within the application. Please do not edit the information contained in the lines below, with the exception of the last field, in which any general feedback is appreciated.", prompt: "General Feedback", extraInfo: nil, metadata: [withFileName, #function, #line])
    }
    
    /**
     Presents a `UIAlertController` allowing the user to **choose from provided options.**
     
     - Parameter title: The alert controller's `title`. *Default value provided.*
     - Parameter message: The alert controller's `message`. *Default value provided.*
     - Parameter cancelButtonTitle: The `title` of the alert controller's cancel button. *Default value provided.*
     
     - Parameter additionalButtons: A tuple array where `title` represents the title of the **additional button** and where `destructive` represents whether the specified button has a `.destructive` style or not.
     - Parameter preferredActionIndex: The index of the **additional button** to become the alert controller's `.preferredAction`.  Defaults to the **cancel button** when unspecified or the index is **out of range** of the specified additional buttons.
     
     - Parameter networkDependent: Set to `true` when having an internet connection is a **prequesite** for this alert controller's presentation.
     - Parameter completion: Returns with the **index** of the button selected. Returns `-1` when the user **cancels,** and `nil` when *networkDependent* is set to `true` and there is no internet connection.
     */
    func optionAlertController(title: String?,
                               message: String?,
                               cancelButtonTitle: String?,
                               additionalButtons: [(title: String, destructive: Bool)]?,
                               preferredActionIndex: Int?,
                               networkDependent: Bool,
                               completion: @escaping (_ selectedIndex: Int?) -> Void) {
        if networkDependent && !hasConnectivity() {
            connectionAlertController()
            completion(nil)
        } else {
            let controllerTitle = title ?? "Select Action"
            let controllerMessage = message ?? "Please select an operation to perform."
            let cancelButtonTitle = cancelButtonTitle ?? "Cancel"
            
            let optionAlertController = UIAlertController(title: controllerTitle, message: controllerMessage, preferredStyle: .alert)
            
            optionAlertController.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: { (_: UIAlertAction!) in
                completion(-1)
            }))
            
            var preferredIndex = -1
            
            if let additionalButtons = additionalButtons {
                if let preferredActionIndex = preferredActionIndex {
                    if preferredActionIndex >= additionalButtons.count {
                        report("Preferred action index was out of range of the provided options. Defaulting to cancel button.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                    } else {
                        preferredIndex = preferredActionIndex
                    }
                }
                
                for (index, button) in additionalButtons.enumerated() {
                    let buttonStyle: UIAlertAction.Style = button.destructive == true ? .destructive : .default
                    
                    optionAlertController.addAction(UIAlertAction(title: button.title, style: buttonStyle, handler: { (_: UIAlertAction!) in
                        completion(index)
                    }))
                    
                    if preferredIndex == index {
                        optionAlertController.preferredAction = optionAlertController.actions.last!
                    }
                }
            }
            
            politelyPresent(viewController: optionAlertController)
        }
    }
    
    ///Retrieves a neatly formatted file name for any passed controller name.
    func retrieveFileName(forFile: String) -> String {
        let filePath = forFile.components(separatedBy: "/")
        let fileName = filePath[filePath.count - 1].components(separatedBy: ".")[0].replacingOccurrences(of: "-", with: "")
        
        return fileName.characters[0].uppercased() + fileName.characters[1 ... fileName.characters.count - 1].joined(separator: "")
    }
    
    ///Displays a customisable success alert controller.
    func successAlertController(withTitle: String?, withMessage: String?, withCancelButtonTitle: String?, withAlternateSelectors: [String: Selector]?, preferredActionIndex: Int?) {
        let controllerCancelButtonTitle = withCancelButtonTitle ?? "Dismiss"
        let controllerMessage = withMessage ?? "The operation completed successfully."
        let controllerTitle = withTitle ?? "Operation Successful"
        
        let alternateSelectors = withAlternateSelectors ?? [:]
        
        let sortedKeyArray = alternateSelectors.keys.sorted(by: { $0 < $1 })
        var iterationCount = sortedKeyArray.count
        
        let successAlertController = UIAlertController(title: controllerTitle, message: controllerMessage, preferredStyle: .alert)
        
        successAlertController.addAction(UIAlertAction(title: controllerCancelButtonTitle, style: .cancel, handler: nil))
        
        for individualKey in sortedKeyArray {
            iterationCount = iterationCount - 1
            
            successAlertController.addAction(UIAlertAction(title: individualKey, style: .default, handler: { (_: UIAlertAction!) in
                lastInitializedController.performSelector(onMainThread: alternateSelectors[individualKey]!, with: nil, waitUntilDone: false)
            }))
            
            //Set the preferred action.
            if iterationCount == 0 {
                if let unwrappedPreferredActionIndex = preferredActionIndex {
                    successAlertController.preferredAction = successAlertController.actions[unwrappedPreferredActionIndex + 1]
                }
            }
        }
        
        politelyPresent(viewController: successAlertController)
    }
    
    /**
     Presents a `UIAlertController` allowing the user to **input text.**
     
     - Parameter title: The alert controller's `title`. *Default value provided.*
     - Parameter message: The alert controller's `message`. *Default value provided.*
     - Parameter cancelButtonTitle: The `title` of the alert controller's cancel button. *Default value provided.*
     
     - Parameter additionalButtons: A tuple array where `title` represents the title of the **additional button** and where `destructive` represents whether the specified button has a `.destructive` style or not.
     - Parameter preferredActionIndex: The index of the **additional button** to become the alert controller's `.preferredAction`.  Defaults to the **cancel button** when unspecified or the index is **out of range** of the specified additional buttons.
     
     - Parameter textFieldAttributes: A dictionary specifying the attributes of the alert controller's **text field** according to the `AlertControllerTextFieldAttribute` cases. *Default value provided.*
     
     - Parameter networkDependent: Set to `true` when having an internet connection is a **prequesite** for this alert controller's presentation.
     - Parameter completion: Returns with any **text** entered and the **index** of the button selected. Returns **no text** and `-1` when the user **cancels,** and `nil` for both values when *networkDependent* is set to `true` and there is no internet connection.
     
     Here is a sample `AlertControllerTextFieldAttribute` dictionary:
     ~~~
     let textFieldAttributes: [AlertKit.AlertControllerTextFieldAttribute:Any] =
     [.capitalisationType: UITextAutocapitalizationType.sentences,
     .correctionType:      UITextAutocorrectionType.default,
     .editingMode:         UITextField.ViewMode.never,
     .keyboardAppearance:  UIKeyboardAppearance.default,
     .keyboardType:        UIKeyboardType.default,
     .placeholderText:     "Here's to the crazy ones.",
     .sampleText:          "",
     .secureTextEntry:     false,
     .textAlignment:       NSTextAlignment.left]
     ~~~
     
     ~~~
     completion(returnedString, selectedIndex)
     ~~~
     */
    func textAlertController(title: String?,
                             message: String?,
                             cancelButtonTitle: String?,
                             additionalButtons: [(title: String, destructive: Bool)]?,
                             preferredActionIndex: Int?,
                             textFieldAttributes: [AlertControllerTextFieldAttribute: Any]?,
                             networkDependent: Bool,
                             completion: @escaping (_ returnedString: String?, _ selectedIndex: Int?) -> Void) {
        if networkDependent && !hasConnectivity() {
            connectionAlertController()
            completion(nil, nil)
        } else {
            let controllerTitle = title ?? "Enter Text"
            let controllerMessage = message ?? "Please enter some text."
            let cancelButtonTitle = cancelButtonTitle ?? "Cancel"
            
            let textAlertController = UIAlertController(title: controllerTitle, message: controllerMessage, preferredStyle: .alert)
            
            var capitalisationType: UITextAutocapitalizationType = .sentences
            var correctionType:     UITextAutocorrectionType     = .default
            var editingMode:        UITextField.ViewMode         = .never
            var keyboardAppearance: UIKeyboardAppearance         = .default
            var keyboardType:       UIKeyboardType               = .default
            var placeholderText                                  = "Here's to the crazy ones."
            var sampleText                                       = ""
            var secureTextEntry                                  = false
            var textAlignment:      NSTextAlignment              = .left
            
            if let attributes = textFieldAttributes {
                for attribute in Array(attributes.keys) {
                    if attribute == .capitalisationType,
                       let specifiedCapitalisationType = attributes[attribute] as? UITextAutocapitalizationType {
                        capitalisationType = specifiedCapitalisationType
                    } else if attribute == .correctionType,
                              let specifiedCorrectionType = attributes[attribute] as? UITextAutocorrectionType {
                        correctionType = specifiedCorrectionType
                    } else if attribute == .editingMode,
                              let specifiedEditingMode = attributes[attribute] as? UITextField.ViewMode {
                        editingMode = specifiedEditingMode
                    } else if attribute == .keyboardAppearance,
                              let specifiedKeyboardAppearance = attributes[attribute] as? UIKeyboardAppearance {
                        keyboardAppearance = specifiedKeyboardAppearance
                    } else if attribute == .keyboardType,
                              let specifiedKeyboardType = attributes[attribute] as? UIKeyboardType {
                        keyboardType = specifiedKeyboardType
                    } else if attribute == .placeholderText,
                              let specifiedPlaceholderText = attributes[attribute] as? String {
                        placeholderText = specifiedPlaceholderText
                    } else if attribute == .sampleText,
                              let specifiedSampleText = attributes[attribute] as? String {
                        sampleText = specifiedSampleText
                    } else if attribute == .secureTextEntry,
                              let specifiedSecureTextEntry = attributes[attribute] as? Bool {
                        secureTextEntry = specifiedSecureTextEntry
                    } else if attribute == .textAlignment,
                              let specifiedTextAlignment = attributes[attribute] as? NSTextAlignment {
                        textAlignment = specifiedTextAlignment
                    }
                }
            }
            
            textAlertController.addTextField { textField in
                textField.autocapitalizationType = capitalisationType
                textField.autocorrectionType = correctionType
                textField.clearButtonMode = editingMode
                textField.isSecureTextEntry = secureTextEntry
                textField.keyboardAppearance = keyboardAppearance
                textField.keyboardType = keyboardType
                textField.placeholder = placeholderText
                textField.text = sampleText
                textField.textAlignment = textAlignment
            }
            
            textAlertController.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: { (_: UIAlertAction!) in
                completion(nil, -1)
            }))
            
            var preferredIndex = -1
            
            if let additionalButtons = additionalButtons {
                if let preferredActionIndex = preferredActionIndex {
                    if preferredActionIndex >= additionalButtons.count {
                        report("Preferred action index was out of range of the provided options. Defaulting to cancel button.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                    } else {
                        preferredIndex = preferredActionIndex
                    }
                }
                
                for (index, button) in additionalButtons.enumerated() {
                    let buttonStyle: UIAlertAction.Style = button.destructive == true ? .destructive : .default
                    
                    textAlertController.addAction(UIAlertAction(title: button.title, style: buttonStyle, handler: { (_: UIAlertAction!) in
                        completion((textAlertController.textFields![0]).text!, index)
                    }))
                    
                    if preferredIndex == index {
                        textAlertController.preferredAction = textAlertController.actions.last!
                    }
                }
            }
            
            politelyPresent(viewController: textAlertController)
        }
    }
    
    //==================================================//
    
    /* MARK: - Helper Functions */
    
    ///Advances a string a given amount of characters.
    func cipherString(withString: String, shiftModifier: Int) -> String {
        var resultingCharacterArray = [Character]()
        
        for utf8Value in withString.utf8 {
            let shiftedValue = Int(utf8Value) + shiftModifier
            
            if shiftedValue > 97 + 25 {
                resultingCharacterArray.append(Character(UnicodeScalar(shiftedValue - 26)!))
            } else if shiftedValue < 97 {
                resultingCharacterArray.append(Character(UnicodeScalar(shiftedValue + 26)!))
            } else {
                resultingCharacterArray.append(Character(UnicodeScalar(shiftedValue)!))
            }
        }
        
        return String(resultingCharacterArray)
    }
    
    /**
     Generates a coded string for the specified `ReportType`.
     
     - Parameter type: The `ReportType` of the code to generate.
     - Parameter metadata: The metadata array. Must contain the **file name, function name, and line number** in that order.
     
     - Requires: A well-formed *metadata* array.
     - Returns: Upon success, a string representing the generated code. Upon failure, returns `nil`.
     */
    func code(for type: ReportType, metadata: [Any]) -> String? {
        guard validateMetadata(metadata) else {
            report("IFM", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
            return nil
        }
        
        let rawFilename = metadata[0] as! String
        let rawFunctionTitle = metadata[1] as! String
        let lineNumber = metadata[2] as! Int
        
        let filePath = rawFilename.components(separatedBy: "/")
        let filename = filePath[filePath.count - 1].components(separatedBy: ".")[0].replacingOccurrences(of: "-", with: "")
        
        let functionTitle = rawFunctionTitle.components(separatedBy: "(")[0].lowercased()
        
        guard let cipheredFilename = filename.lowercased().ciphered(by: 14).randomlyCapitalized(with: lineNumber) else {
            report("Unable to unwrap ciphered filename.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
            return nil
        }
        
        let modelCode = SystemInformation.modelCode.lowercased()
        let operatingSystemVersion = SystemInformation.operatingSystemVersion.lowercased()
        
        if type == .error {
            guard let cipheredFunctionName = functionTitle.lowercased().ciphered(by: 14).randomlyCapitalized(with: lineNumber) else {
                report("Unable to unwrap ciphered function name.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                return nil
            }
            
            return "\(modelCode).\(cipheredFilename)-\(lineNumber)-\(cipheredFunctionName).\(operatingSystemVersion)"
        } else {
            return "\(modelCode).\(cipheredFilename).\(operatingSystemVersion)"
        }
    }
    
    func fileReport(type: ReportType, body: String, prompt: String, extraInfo: String?, metadata: [Any]) {
        guard validateMetadata(metadata) else {
            report("IFM", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
            return
        }
        
        guard let code = code(for: type, metadata: metadata) else {
            report("Unable to generate code.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
            return
        }
        
        let connectionStatus = hasConnectivity() ? "online" : "offline"
        
        let bodySection = body.split(separator: ".").count > 1 ? "<i>\(body.split(separator: ".")[0]).<p></p>\(body.split(separator: ".")[1]).</i><p></p>" : "<i>\(body.split(separator: ".")[0]).</i><p></p>"
        
        let compiledRemainder = "<b>Project ID:</b> \(informationDictionary["projectIdentifier"]!)<p></p><b>Build SKU:</b> \(informationDictionary["buildSku"]!)<p></p><b>Occurrence Date:</b> \(secondaryDateFormatter.string(from: Date()))<p></p><b>Internet Connection Status:</b> \(connectionStatus)<p></p>\(extraInfo == nil ? "" : "<b>Extraneous Information:</b> \(extraInfo!)<p></p>")<b>Reference Code:</b> [\(code)]<p></p><b>\(prompt):</b> "
        
        let subject = "\(buildType == .generalRelease ? finalName : codeName) (\(informationDictionary["bundleVersion"]!)) \(type == .bug ? "Bug" : (type == .error ? "Error" : "Feedback")) Report"
        
        composeMessage(withMessage: bodySection + compiledRemainder, withRecipients: ["me@grantbrooks.io"], withSubject: subject, isHtmlMessage: true)
    }
    
    //==================================================//
    
    /* MARK: - Private Functions */
    
    ///Decrements one second from the expiry counter. If it reaches less than zero, it kills the application.
    @objc private func decrementSecond() {
        decrementSeconds -= 1
        
        if decrementSeconds < 0 {
            exitTimer?.invalidate()
            
            lastInitializedController.dismiss(animated: true, completion: {
                let alertController = UIAlertController(title: "Time Expired", message: "The application will now exit.", preferredStyle: .alert)
                
                lastInitializedController.present(alertController, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { fatalError()
                    }
                })
            })
        } else {
            var decrementString = String(decrementSeconds)
            
            if decrementString.count == 1 {
                decrementString = "0\(decrementSeconds)"
            }
            
            expiryMessage = "\(expiryMessage.components(separatedBy: ":")[0]): 00:\(decrementString)."
            
            expiryController.message = expiryMessage
        }
    }
    
    private func strippedDescriptor(for: String) -> String {
        let stripWords = ["a", "is", "that", "the", "this", "was"]
        
        var resultantString = ""
        
        for word in `for`.components(separatedBy: " ") {
            if !stripWords.contains(word.lowercased()) {
                resultantString.append("\(word)\(word.lowercased() == "not" ? "" : " ")")
            }
        }
        
        return resultantString
    }
}

//==================================================//

/* MARK: - Extensions */

extension String {
    func ciphered(by modifier: Int) -> String {
        var shiftedCharacters = [Character]()
        
        for utf8Value in utf8 {
            let shiftedValue = Int(utf8Value) + modifier
            
            let wrapAroundBy = shiftedValue > 97 + 25 ? -26 : (shiftedValue < 97 ? 26 : 0)
            
            shiftedCharacters.append(Character(UnicodeScalar(shiftedValue + wrapAroundBy)!))
        }
        
        return String(shiftedCharacters)
    }
    
    func randomlyCapitalized(with modifider: Int) -> String? {
        var returnedString = ""
        var incrementCount = count
        
        for character in self {
            incrementCount = incrementCount - 1
            
            if ((modifider + incrementCount) % 2) == 0 {
                returnedString = returnedString + String(character).uppercased()
            } else {
                returnedString = returnedString + String(character).lowercased()
            }
            
            if incrementCount == 0 {
                return returnedString
            }
        }
        
        return nil
    }
}
