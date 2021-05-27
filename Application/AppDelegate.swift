//
//  AppDelegate.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 04/08/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import MessageUI
import UIKit
import UserNotifications

/* Third-party Frameworks */
import Firebase
import PKHUD
import Reachability

//==================================================//

/* MARK: - Top-level Variable Declarations */

//Booleans
var darkMode                              = false
var isPresentingMailComposeViewController = false
var preReleaseApplication                 = true
var verboseFunctionExposure               = false

//DateFormatters
let masterDateFormatter    = DateFormatter()
let secondaryDateFormatter = DateFormatter()

//Strings
var accountIdentifier: String!
var codeName                  = "Yosemite"
var currentFile               = #file
var dmyFirstCompileDateString = "04082020"
var finalName                 = "glaid"

//UIViewControllers
var buildInfoController: BuildInfoController?
var lastInitializedController: UIViewController! = MainController()

//Other Declarations
var appStoreReleaseVersion = 0
var buildType: Build.BuildType = .beta
var currentCalendar = Calendar(identifier: .gregorian)
var currentUser: User?
var informationDictionary: [String:String]!
var statusBarStyle: UIStatusBarStyle = .lightContent
var touchTimer: Timer?

var f = Frame()

//==================================================//

@UIApplicationMain class AppDelegate: UIResponder, MFMailComposeViewControllerDelegate, UIApplicationDelegate, UIGestureRecognizerDelegate {
    
    //==================================================//
    
    /* MARK: - Class-level Variable Declarations */
    
    //Boolean Declarations
    var currentlyAnimating = false
    var hasResigned        = false
    
    //Other Declarations
    let screenSize = UIScreen.main.bounds
    
    var informationDictionary: [String:String] = [:]
    var window: UIWindow?
    
    //==================================================//
    
    /* MARK: - Required Functions */
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.delegate = self
        window?.addGestureRecognizer(tapGesture)
        
        currentCalendar.timeZone = TimeZone(abbreviation: "GMT")!
        
        masterDateFormatter.dateFormat = "yyyy-MM-dd"
        masterDateFormatter.locale = Locale(identifier: "en_GB")
        
        secondaryDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        secondaryDateFormatter.locale = Locale(identifier: "en_GB")
        
        //Set the array of information.
        Build(nil)
        
        FirebaseApp.configure()
        registerForPushNotifications()
        f.originalDevelopmentEnvironment = .fiveEightInch
        
        //        let proxy = UIPageControl.appearance()
        //        proxy.pageIndicatorTintColor = UIColor.red.withAlphaComponent(0.6)
        //        proxy.currentPageIndicatorTintColor = .red
        //        proxy.backgroundColor = .yellow
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if currentlyAnimating && hasResigned {
            lastInitializedController.performSegue(withIdentifier: "initialSegue", sender: self)
            currentlyAnimating = false
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        hasResigned = true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    //==================================================//
    
    /* MARK: - User Notification Functions */
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if !error.localizedDescription.contains("remote notifications are not supported in the simulator") {
            print("Failed to register: \(error)")
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            //print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                
                //print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
            }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    //==================================================//
    
    /* MARK: - Other Functions */
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        touchTimer?.invalidate()
        touchTimer = nil
        
        UIView.animate(withDuration: 0.2, animations: { buildInfoController?.view.alpha = 0.35 }) { (_) in
            if touchTimer == nil {
                touchTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.touchTimerAction), userInfo: nil, repeats: true)
            }
        }
        
        return false
    }
    
    @objc func touchTimerAction() {
        UIView.animate(withDuration: 0.2, animations: {
            if touchTimer != nil {
                buildInfoController?.view.alpha = 1
                
                touchTimer?.invalidate()
                touchTimer = nil
            }
        })
    }
}

//==================================================//

/* MARK: - Helper Functions */

/**/

/* MARK: Error Processing Functions */
/**
 Converts an instance of `Error` to a formatted string.
 
 - Parameter for: The `Error` whose information will be extracted.
 
 - Returns: A string with the error's localized description and code.
 */
func errorInfo(_ for: Error) -> String {
    let asNSError = `for` as NSError
    
    return "\(asNSError.localizedDescription) (\(asNSError.code))"
}

/**
 Converts an instance of `NSError` to a formatted string.
 
 - Parameter for: The `NSError` whose information will be extracted.
 
 - Returns: A string with the error's localized description and code.
 */
func errorInfo(_ for: NSError) -> String {
    return "\(`for`.localizedDescription) (\(`for`.code))"
}

//--------------------------------------------------//

/* MARK: Event Reporting Functions */

///Closes a console stream.
func closeStream(onLine: Int?, withMessage: String?) {
    if verboseFunctionExposure {
        if let closingMessage = withMessage, let lastLine = onLine {
            print("[\(lastLine)]: \(closingMessage)\n*------------------------STREAM CLOSED------------------------*\n")
        } else {
            print("*------------------------STREAM CLOSED------------------------*\n")
        }
    }
}

func fallbackReport(_ text: String, errorCode: Int?, isFatal: Bool) {
    if let unwrappedErrorCode = errorCode {
        print("\n--------------------------------------------------\n[IMPROPERLY FORMATTED METADATA]\n\(text) (\(unwrappedErrorCode))\n--------------------------------------------------\n")
    } else {
        print("\n--------------------------------------------------\n[IMPROPERLY FORMATTED METADATA]\n\(text)\n--------------------------------------------------\n")
    }
    
    if isFatal {
        AlertKit().fatalErrorController()
    }
}

///Logs to the console stream.
func logToStream(forLine: Int, withMessage: String) {
    if verboseFunctionExposure {
        print("[\(forLine)]: \(withMessage)")
    }
}

///Opens a console stream.
func openStream(forFile: String, forFunction: String, forLine: Int?, withMessage: String?) {
    if verboseFunctionExposure {
        let functionTitle = forFunction.components(separatedBy: "(")[0]
        
        if let firstEntry = withMessage {
            print("\n*------------------------STREAM OPENED------------------------*\n\(AlertKit().retrieveFileName(forFile: forFile)): \(functionTitle)()\n[\(forLine!)]: \(firstEntry)")
        } else {
            print("\n*------------------------STREAM OPENED------------------------*\n\(AlertKit().retrieveFileName(forFile: forFile)): \(functionTitle)()")
        }
    }
}

/**
 Prints a formatted event report to the console. Also supports displaying a fatal error alert.
 
 - Parameter text: The content of the message to print.
 - Parameter errorCode: An optional error code to include in the report.
 
 - Parameter isFatal: A Boolean representing whether or not to display a fatal error alert along with the event report.
 - Parameter metadata: The metadata array. Must contain the **file name, function name, and line number** in that order.
 */
func report(_ text: String, errorCode: Int?, isFatal: Bool, metadata: [Any]) {
    guard validateMetadata(metadata) else {
        fallbackReport(text, errorCode: errorCode, isFatal: isFatal)
        return
    }
    
    let unformattedFileName = metadata[0] as! String
    let unformattedFunctionName = metadata[1] as! String
    let lineNumber = metadata[2] as! Int
    
    let fileName = AlertKit().retrieveFileName(forFile: unformattedFileName)
    let functionName = unformattedFunctionName.components(separatedBy: "(")[0]
    
    if let unwrappedErrorCode = errorCode {
        print("\n--------------------------------------------------\n\(fileName): \(functionName)() [\(lineNumber)]\n\(text) (\(unwrappedErrorCode))\n--------------------------------------------------\n")
        
        if isFatal {
            AlertKit().fatalErrorController(extraInfo: "\(text) (\(unwrappedErrorCode))", metadata: [fileName, functionName, lineNumber])
        }
    } else {
        print("\n--------------------------------------------------\n\(fileName): \(functionName)() [\(lineNumber)]\n\(text)\n--------------------------------------------------\n")
        
        if isFatal {
            AlertKit().fatalErrorController(extraInfo: text, metadata: [fileName, functionName, lineNumber])
        }
    }
}

func validateMetadata(_ metadata: [Any]) -> Bool {
    guard metadata.count == 3 else {
        return false
    }
    
    guard metadata[0] is String else {
        return false
    }
    
    guard metadata[1] is String else {
        return false
    }
    
    guard metadata[2] is Int else {
        return false
    }
    
    return true
}

//--------------------------------------------------//

/* MARK: First Responder Functions */

///Finds and resigns the first responder.
func findAndResignFirstResponder() {
    DispatchQueue.main.async {
        if let unwrappedFirstResponder = findFirstResponder(inView: lastInitializedController.view) {
            unwrappedFirstResponder.resignFirstResponder()
        }
    }
}

///Finds the first responder in a given view.
func findFirstResponder(inView view: UIView) -> UIView? {
    for individualSubview in view.subviews {
        if individualSubview.isFirstResponder {
            return individualSubview
        }
        
        if let recursiveSubview = findFirstResponder(inView: individualSubview) {
            return recursiveSubview
        }
    }
    
    return nil
}

//--------------------------------------------------//

/* MARK: HUD Functions */

///Hides the HUD.
func hideHUD() {
    DispatchQueue.main.async {
        if PKHUD.sharedHUD.isVisible {
            PKHUD.sharedHUD.hide(true)
        }
    }
}

func hideHUD(delay: Double?) {
    if let delay = delay {
        let millisecondDelay = Int(delay * 1000)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(millisecondDelay)) {
            if PKHUD.sharedHUD.isVisible {
                PKHUD.sharedHUD.hide(true)
            }
        }
    } else {
        DispatchQueue.main.async {
            if PKHUD.sharedHUD.isVisible {
                PKHUD.sharedHUD.hide(true)
            }
        }
    }
}

func hideHUD(delay: Double?, completion: @escaping() -> Void) {
    if let delay = delay {
        let millisecondDelay = Int(delay * 1000)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(millisecondDelay)) {
            if PKHUD.sharedHUD.isVisible {
                PKHUD.sharedHUD.hide(animated: true) { (_) in
                    completion()
                }
            }
        }
    } else {
        DispatchQueue.main.async {
            if PKHUD.sharedHUD.isVisible {
                PKHUD.sharedHUD.hide(true) { (_) in
                    completion()
                }
            }
        }
    }
}

///Shows the progress HUD.
func showProgressHUD() {
    DispatchQueue.main.async {
        if !PKHUD.sharedHUD.isVisible {
            PKHUD.sharedHUD.contentView = PKHUDProgressView()
            PKHUD.sharedHUD.show(onView: lastInitializedController.view)
        }
    }
}

func showProgressHUD(text: String?, delay: Double?) {
    if let delay = delay {
        let millisecondDelay = Int(delay * 1000)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(millisecondDelay)) {
            if !PKHUD.sharedHUD.isVisible {
                PKHUD.sharedHUD.contentView = PKHUDProgressView(title: nil, subtitle: text)
                PKHUD.sharedHUD.show(onView: lastInitializedController.view)
            }
        }
    } else {
        DispatchQueue.main.async {
            if !PKHUD.sharedHUD.isVisible {
                PKHUD.sharedHUD.contentView = PKHUDProgressView(title: nil, subtitle: text)
                PKHUD.sharedHUD.show(onView: lastInitializedController.view)
            }
        }
    }
}

//--------------------------------------------------//

/* MARK: - Miscellaneous Functions */

///Retrieves the appropriately random tag integer for a given title.
func aTagFor(_ theViewNamed: String) -> Int {
    var finalValue: Float = 1.0
    
    for individualCharacter in String(theViewNamed.unicodeScalars.filter(CharacterSet.letters.contains)).characters {
        finalValue += (finalValue / Float(individualCharacter.alphabeticalPosition))
    }
    
    return Int(String(finalValue).replacingOccurrences(of: ".", with: "")) ?? Int().random(min: 5, max: 10)
}

func buildTypeAsString(short: Bool) -> String {
    switch buildType {
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

///Presents a mail composition view.
func composeMessage(withMessage: String, withRecipients: [String], withSubject: String, isHtmlMessage: Bool) {
    hideHUD(delay: nil)
    
    if MFMailComposeViewController.canSendMail() {
        let composeController = MFMailComposeViewController()
        composeController.mailComposeDelegate = lastInitializedController as! MFMailComposeViewControllerDelegate?
        composeController.setToRecipients(withRecipients)
        composeController.setMessageBody(withMessage, isHTML: isHtmlMessage)
        composeController.setSubject(withSubject)
        
        politelyPresent(viewController: composeController)
    } else {
        AlertKit().errorAlertController(title: "Cannot Send Mail", message: "It appears that your device is not able to send e-mail.\n\nPlease verify that your e-mail client is set up and try again.", dismissButtonTitle: nil, additionalSelectors: nil, preferredAdditionalSelector: nil, canFileReport: false, extraInfo: nil, metadata: [#file, #function, #line], networkDependent: true)
    }
}

///Returns a boolean describing whether or not the device has an active Internet connection.
func hasConnectivity() -> Bool {
    let connectionReachability = try! Reachability()
    let networkStatus = connectionReachability.connection.description
    
    return (networkStatus != "No Connection")
}

///Presents a given view controller, but waits for others to be dismissed before doing so.
func politelyPresent(viewController: UIViewController) {
    hideHUD(delay: nil)
    
    if viewController as? MFMailComposeViewController != nil {
        isPresentingMailComposeViewController = true
    }
    
    let keyWindow = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
    
    if var topController = keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        if topController.presentedViewController == nil && !topController.isKind(of: UIAlertController.self) {
            #warning("Something changed in iOS 14 that broke the above code.")
            topController = lastInitializedController
            
            if !Thread.isMainThread {
                DispatchQueue.main.sync {
                    topController.present(viewController, animated: true)
                }
            } else {
                topController.present(viewController, animated: true)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                politelyPresent(viewController: viewController)
            })
        }
    }
}

///Rounds the corners on any desired view.
///Numbers 0 through 4 correspond to all, left, right, top, and bottom, respectively.
func roundCorners(forViews: [UIView], withCornerType: Int!) {
    for individualView in forViews {
        var cornersToRound: UIRectCorner!
        
        if withCornerType == 0 {
            //All corners.
            cornersToRound = UIRectCorner.allCorners
        } else if withCornerType == 1 {
            //Left corners.
            cornersToRound = UIRectCorner.topLeft.union(UIRectCorner.bottomLeft)
        } else if withCornerType == 2 {
            //Right corners.
            cornersToRound = UIRectCorner.topRight.union(UIRectCorner.bottomRight)
        } else if withCornerType == 3 {
            //Top corners.
            cornersToRound = UIRectCorner.topLeft.union(UIRectCorner.topRight)
        } else if withCornerType == 4 {
            //Bottom corners.
            cornersToRound = UIRectCorner.bottomLeft.union(UIRectCorner.bottomRight)
        }
        
        let maskPathForView: UIBezierPath = UIBezierPath(roundedRect: individualView.bounds,
                                                         byRoundingCorners: cornersToRound,
                                                         cornerRadii: CGSize(width: 10, height: 10))
        
        let maskLayerForView: CAShapeLayer = CAShapeLayer()
        
        maskLayerForView.frame = individualView.bounds
        maskLayerForView.path = maskPathForView.cgPath
        
        individualView.layer.mask = maskLayerForView
        individualView.layer.masksToBounds = false
        individualView.clipsToBounds = true
    }
}

// TODO: REMOVE THESE
func ancillaryRound(forViews: [UIView]) {
    for individualView in forViews {
        let maskPathForView = UIBezierPath(roundedRect: individualView.bounds,
                                           byRoundingCorners: .allCorners,
                                           cornerRadii: CGSize(width: 5, height: 5))
        
        let maskLayerForView = CAShapeLayer()
        
        maskLayerForView.frame = individualView.bounds
        maskLayerForView.path = maskPathForView.cgPath
        
        individualView.layer.mask = maskLayerForView
        individualView.layer.masksToBounds = false
        individualView.clipsToBounds = true
    }
}

/**
 Rounds borders on a given UIView.
 
 - Parameter forView: The view whose borders to round.
 */
func roundBorders(_ forView: UIView) {
    forView.layer.borderWidth  = 2
    forView.layer.cornerRadius = 10
    
    forView.layer.borderColor = UIColor(hex: 0xE1E0E1).cgColor
    
    forView.clipsToBounds       = true
    forView.layer.masksToBounds = true
}

extension Date {
    func amountOfSeconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
}
