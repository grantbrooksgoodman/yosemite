//
//  AppDelegate.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 04/08/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit
import UserNotifications

//Third-party Frameworks
import Firebase
import PKHUD
import Reachability

//--------------------------------------------------//

//Top-Level Declarations

var buildState: Build.BuildState = .alpha

//Boolean Declarations
var darkMode                = false
var preReleaseApplication   = true
var verboseFunctionExposure = false

//DateFormatter Declarations
let masterDateFormatter    = DateFormatter()
let secondaryDateFormatter = DateFormatter()

//Dictionary Declarations
var dismissDictionary:              [String: String]!
var followingUnableDictionary:      [String: String]!
var informationDictionary:          [String: String]!
var languageCodeDictionary:         [String: String]!
var noInternetMessageDictionary:    [String: String]!
var noInternetTitleDictionary:      [String: String]!
var notSupportedMessageDictionary:  [String: String]!
var sendFeedbackDictionary:         [String: String]!
var translationArchive:             [String: String] = [:]
var unableMessageDictionary:        [String: String]!
var unableTitleDictionary:          [String: String]!

//String Declarations
var accountIdentifier: String!
var codeName                  = "Yosemite"
var finalName                 = "glaid"
var languageCode              = "en"
//Array(languageCodeDictionary.keys).randomElement()!
//["de", "en", "es", "fr", "it", "ja", "ko", "no", "pt", "ru", "ro", "sv"].randomElement()!
//Locale.preferredLanguages[0].components(separatedBy: "-")[0]
var dmyFirstCompileDateString = "04082020"

//Other Declarations
var appStoreReleaseVersion = 0
var currentUser: User?
var lastInitialisedController: UIViewController! = MC()

var f = Frame()

//--------------------------------------------------//

@UIApplicationMain
class AppDelegate: UIResponder, MFMailComposeViewControllerDelegate, UIApplicationDelegate, UNUserNotificationCenterDelegate
{
    //--------------------------------------------------//
    
    //Class-level Declarations
    
    //Boolean Declarations
    var currentlyAnimating = false
    var hasResigned        = false
    
    //Other Declarations
    let screenSize = UIScreen.main.bounds
    
    var informationDictionary: [String: String] = [:]
    var window: UIWindow?
    
    //--------------------------------------------------//
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "AppleGaramond", size: 17)!], for: .normal)
        
        FirebaseApp.configure()
        
        masterDateFormatter.dateFormat = "yyyy-MM-dd"
        masterDateFormatter.locale = Locale(identifier: "en_GB")
        
        secondaryDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        secondaryDateFormatter.locale = Locale(identifier: "en_GB")
        
        if let essentialLocalisations = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Essential-Localisations", ofType: "plist")!) as? [String: [String: String]]
        {
            dismissDictionary = essentialLocalisations["dismiss"]!
            followingUnableDictionary = essentialLocalisations["following_unable"]!
            languageCodeDictionary = essentialLocalisations["language_codes"]!
            noInternetMessageDictionary = essentialLocalisations["no_internet_message"]!
            noInternetTitleDictionary = essentialLocalisations["no_internet_title"]!
            notSupportedMessageDictionary = essentialLocalisations["not_supported"]!
            sendFeedbackDictionary = essentialLocalisations["send_feedback"]!
            unableMessageDictionary = essentialLocalisations["unable_message"]!
            unableTitleDictionary = essentialLocalisations["unable_title"]!
            
            if languageCodeDictionary[languageCode] == nil
            {
                languageCode = "en"
                
                report("Unsupported language code; reverting to English.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
            }
        }
        else
        {
            report("Essential localisations missing.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
        }
        
        if let savedTranslationArchive = UserDefaults.standard.value(forKey: "translationArchive") as? [String: String]
        {
            translationArchive = savedTranslationArchive
        }
        else
        {
            translationArchive["languageCode"] = languageCode
        }
        
        //Determine the height of the screen, and set the preferred storyboard file accordingly.
        if screenSize.height == 896
        {
            let preferredStoryboard = UIStoryboard(name: "6.x Inch", bundle: nil)
            
            let initialViewController = preferredStoryboard.instantiateViewController(withIdentifier: "IC")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        else if screenSize.height == 812
        {
            let preferredStoryboard = UIStoryboard(name: "5.8 Inch", bundle: nil)
            
            let initialViewController = preferredStoryboard.instantiateViewController(withIdentifier: "IC")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        else if screenSize.height == 736
        {
            let preferredStoryboard = UIStoryboard(name: "5.5 Inch", bundle: nil)
            
            let initialViewController = preferredStoryboard.instantiateViewController(withIdentifier: "IC")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        else if screenSize.height == 667
        {
            let preferredStoryboard = UIStoryboard(name: "4.7 Inch", bundle: nil)
            
            let initialViewController = preferredStoryboard.instantiateViewController(withIdentifier: "IC")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        else if screenSize.height == 568
        {
            let preferredStoryboard = UIStoryboard(name: "4 Inch", bundle: nil)
            
            let initialViewController = preferredStoryboard.instantiateViewController(withIdentifier: "IC")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        else
        {
            let preferredStoryboard = UIStoryboard(name: "iPad", bundle: nil)
            
            let initialViewController = preferredStoryboard.instantiateViewController(withIdentifier: "IC")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        //Set the array of information.
        Build(withType: .applicationDelegate, instanceArray: nil, conserveSpace: false)
        
        f.originalDevelopmentEnvironment = .fiveEightInch
        
        registerForPushNotifications()
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        if currentlyAnimating && hasResigned
        {
            lastInitialisedController.performSegue(withIdentifier: "initialSegue", sender: self)
            currentlyAnimating = false
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication)
    {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication)
    {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication)
    {
        hasResigned = true
    }
    
    func applicationWillTerminate(_ application: UIApplication)
    {
        
    }
    
    func registerForPushNotifications()
    {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                
                //print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings()
    {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            //print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        //print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        if !error.localizedDescription.contains("remote notifications are not supported in the simulator")
        {
            print("Failed to register: \(error)")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler(.alert)
    }
}

//--------------------------------------------------//

//Other Functions

///Function that returns a day of the week for a given date string.
func dayOfWeek(_ fromDateString: String) -> String
{
    let fromDate = masterDateFormatter.date(from: fromDateString)!
    
    switch Calendar.current.component(.weekday, from: fromDate)
    {
    case 1:
        return "Sunday"
    case 2:
        return "Monday"
    case 3:
        return "Tuesday"
    case 4:
        return "Wednesday"
    case 5:
        return "Thursday"
    case 6:
        return "Friday"
    case 7:
        return "Saturday"
    default:
        return "Someday"
    }
}

///Function that gets a nicely formatted date string from a provided Date.
func formattedDateString(fromDate: Date) -> String
{
    let differenceBetweenDates = Calendar.current.startOfDay(for: Date()).distance(to: Calendar.current.startOfDay(for: fromDate))
    
    let stylisedDateFormatter = DateFormatter()
    stylisedDateFormatter.dateStyle = .short
    
    if differenceBetweenDates == 0
    {
        return DateFormatter.localizedString(from: fromDate, dateStyle: .none, timeStyle: .short)
    }
    else if differenceBetweenDates == -86400
    {
        return "Yesterday"
    }
    else if differenceBetweenDates >= -604800
    {
        if dayOfWeek(masterDateFormatter.string(from: fromDate)) != dayOfWeek(masterDateFormatter.string(from: Date()))
        {
            return dayOfWeek(masterDateFormatter.string(from: fromDate))
        }
        else
        {
            return stylisedDateFormatter.string(from: fromDate)
        }
    }
    
    return stylisedDateFormatter.string(from: fromDate)
}

func ancillaryRound(forViews: [UIView])
{
    for individualView in forViews
    {
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

///Retrieves the appropriately random tag integer for a given title.
func aTagFor(_ theViewNamed: String) -> Int
{
    var finalValue: Float = 1.0
    
    for individualCharacter in String(theViewNamed.unicodeScalars.filter(CharacterSet.letters.contains)).stringCharacters
    {
        finalValue += (finalValue / Float(individualCharacter.alphabeticalPositionValue))
    }
    
    return Int(String(finalValue).replacingOccurrences(of: ".", with: "")) ?? randomInteger(5, maximumValue: 10)
}

///Closes a console stream.
func closeStream(onLine: Int?, withMessage: String?)
{
    if verboseFunctionExposure
    {
        if let closingMessage = withMessage, let lastLine = onLine
        {
            print("[\(lastLine)]: \(closingMessage)\n*------------------------STREAM CLOSED------------------------*\n")
        }
        else
        {
            print("*------------------------STREAM CLOSED------------------------*\n")
        }
    }
}

///Presents a mail composition view.
func composeMessage(withMessage: String, withRecipients: [String], withSubject: String, isHtmlMessage: Bool)
{
    hideHud()
    
    if MFMailComposeViewController.canSendMail()
    {
        let composeController = MFMailComposeViewController()
        composeController.mailComposeDelegate = lastInitialisedController as! MFMailComposeViewControllerDelegate?
        composeController.setToRecipients(withRecipients)
        composeController.setMessageBody(withMessage, isHTML: isHtmlMessage)
        composeController.setSubject(withSubject)
        
        politelyPresent(viewController: composeController)
    }
    else
    {
        PresentationManager().errorAlertController(withTitle: "Cannot Send Mail", withMessage: "It appears that your device is not able to send mail.\n\nPlease verify that your mail client is active and try again.", extraneousInformation: nil, withCancelButtonTitle: nil, withAlternateSelectors: nil, preferredActionIndex: nil, withFileName: #file, withLineNumber: #line, withFunctionTitle: #function, networkDependent: true, canFileReport: false)
    }
}

///Retrieves a formatted error string from a given instance of NSError.
func errorInformation(forError: NSError) -> String
{
    return "\(forError.localizedDescription) (\(forError.code))"
}

///Finds and resigns the first responder.
func findAndResignFirstResponder()
{
    DispatchQueue.main.async {
        if let unwrappedFirstResponder = findFirstResponder(inView: lastInitialisedController.view)
        {
            unwrappedFirstResponder.resignFirstResponder()
        }
    }
}

///Finds the first responder in a given view.
func findFirstResponder(inView view: UIView) -> UIView?
{
    for individualSubview in view.subviews
    {
        if individualSubview.isFirstResponder
        {
            return individualSubview
        }
        
        if let recursiveSubview = findFirstResponder(inView: individualSubview)
        {
            return recursiveSubview
        }
    }
    
    return nil
}

///Returns a boolean describing whether or not the device has an active Internet connection.
func hasConnectivity() -> Bool
{
    let connectionReachability = try! Reachability()
    let networkStatus = connectionReachability.connection.description
    
    return (networkStatus != "No Connection")
}

///Hides the HUD.
func hideHud()
{
    DispatchQueue.main.async {
        if PKHUD.sharedHUD.isVisible
        {
            PKHUD.sharedHUD.hide(true)
        }
    }
}

///Invalidates an instance of Timer that has been declared as an optional variable.
func invalidateOptionalTimer(withTimer: Timer?)
{
    if let unwrappedTimer = withTimer
    {
        unwrappedTimer.invalidate()
    }
}

func fallbackReport(_ text: String, errorCode: Int?, isFatal: Bool)
{
    if let unwrappedErrorCode = errorCode
    {
        print("\n--------------------------------------------------\n[IMPROPERLY FORMATTED METADATA]\n\(text) (\(unwrappedErrorCode))\n--------------------------------------------------\n")
    }
    else
    {
        print("\n--------------------------------------------------\n[IMPROPERLY FORMATTED METADATA]\n\(text)\n--------------------------------------------------\n")
    }
    
    if isFatal
    {
        PresentationManager().fatalErrorController()
    }
}

func validateMetadata(_ metadata: [Any]) -> Bool
{
    guard metadata.count == 3 else { return false }
    
    guard metadata[0] is String else { return false }
    
    guard metadata[1] is String else { return false }
    
    guard metadata[2] is Int else { return false }
    
    return true
}

/**
 Prints a formatted event report to the console. Also supports displaying a fatal error alert.
 
 - Parameter withText: The content of the message to print.
 - Parameter errorCode: An optional error code to include in the report.
 
 - Parameter isFatal: A Boolean representing whether or not to display a fatal error alert along with the event report.
 - Parameter metadata: The metadata Array. Must contain the **file name, function name, and line number** in that order.
 */
func report(_ text: String, errorCode: Int?, isFatal: Bool, metadata: [Any])
{
    guard validateMetadata(metadata) else { fallbackReport(text, errorCode: errorCode, isFatal: isFatal); return }
    
    let unformattedFileName = metadata[0] as! String
    let unformattedFunctionName = metadata[1] as! String
    let lineNumber = metadata[2] as! Int
    
    let fileName = PresentationManager().retrieveFileName(forFile: unformattedFileName)
    let functionName = unformattedFunctionName.components(separatedBy: "(")[0]
    
    if let unwrappedErrorCode = errorCode
    {
        print("\n--------------------------------------------------\n\(fileName): \(functionName)() [\(lineNumber)]\n\(text) (\(unwrappedErrorCode))\n--------------------------------------------------\n")
        
        if isFatal
        {
            PresentationManager().fatalErrorController(extraneousInformation: "\(text) (\(unwrappedErrorCode)", withFileName: fileName, withFunctionTitle: functionName, withLineNumber: lineNumber)
        }
    }
    else
    {
        print("\n--------------------------------------------------\n\(fileName): \(functionName)() [\(lineNumber)]\n\(text)\n--------------------------------------------------\n")
        
        if isFatal
        {
            PresentationManager().fatalErrorController(extraneousInformation: text, withFileName: fileName, withFunctionTitle: functionName, withLineNumber: lineNumber)
        }
    }
}

///Logs to the console stream.
func logToStream(forLine: Int, withMessage: String)
{
    if verboseFunctionExposure
    {
        print("[\(forLine)]: \(withMessage)")
    }
}

///Opens a console stream.
func openStream(forFile: String, forFunction: String, forLine: Int?, withMessage: String?)
{
    if verboseFunctionExposure
    {
        let functionTitle = forFunction.components(separatedBy: "(")[0]
        
        if let firstEntry = withMessage
        {
            print("\n*------------------------STREAM OPENED------------------------*\n\(PresentationManager().retrieveFileName(forFile: forFile)): \(functionTitle)()\n[\(forLine!)]: \(firstEntry)")
        }
        else
        {
            print("\n*------------------------STREAM OPENED------------------------*\n\(PresentationManager().retrieveFileName(forFile: forFile)): \(functionTitle)()")
        }
    }
}

///Presents a given view controller, but waits for others to be dismissed before doing so.
func politelyPresent(viewController: UIViewController)
{
    hideHud()
    
    if lastInitialisedController.presentedViewController == nil
    {
        if !Thread.isMainThread
        {
            DispatchQueue.main.sync {
                lastInitialisedController.present(viewController, animated: true)
            }
        }
        else
        {
            lastInitialisedController.present(viewController, animated: true)
        }
    }
    else
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            politelyPresent(viewController: viewController)
        })
    }
}

///Returns a random integer value.
func randomInteger(_ minimumValue: Int, maximumValue: Int) -> Int
{
    return minimumValue + Int(arc4random_uniform(UInt32(maximumValue - minimumValue + 1)))
}

/**
 Rounds borders on a given UIView.
 
 - Parameter forView: The view whose borders to round.
 */
func roundBorders(_ forView: UIView)
{
    forView.layer.borderWidth  = 2
    forView.layer.cornerRadius = 10
    
    forView.layer.borderColor = UIColor(hex: 0xE1E0E1).cgColor
    
    forView.clipsToBounds       = true
    forView.layer.masksToBounds = true
}

///Rounds the corners on any desired view.
///Numbers 0 through 4 correspond to all, left, right, top, and bottom, respectively.
func roundCorners(forViews: [UIView], withCornerType: Int!)
{
    for individualView in forViews
    {
        var cornersToRound: UIRectCorner!
        
        if withCornerType == 0
        {
            //All corners.
            cornersToRound = UIRectCorner.allCorners
        }
        else if withCornerType == 1
        {
            //Left corners.
            cornersToRound = UIRectCorner.topLeft.union(UIRectCorner.bottomLeft)
        }
        else if withCornerType == 2
        {
            //Right corners.
            cornersToRound = UIRectCorner.topRight.union(UIRectCorner.bottomRight)
        }
        else if withCornerType == 3
        {
            //Top corners.
            cornersToRound = UIRectCorner.topLeft.union(UIRectCorner.topRight)
        }
        else if withCornerType == 4
        {
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

///Sets the background image on a UIView.
func setBackgroundImage(_ forView: UIView!, imageName: String!)
{
    UIGraphicsBeginImageContext(forView.frame.size)
    
    UIImage(named: imageName)?.draw(in: forView.bounds)
    
    let imageToSet: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    
    UIGraphicsEndImageContext()
    
    forView.backgroundColor = UIColor(patternImage: imageToSet)
}

///Shows the progress HUD.
func showProgressHud()
{
    DispatchQueue.main.async {
        if !PKHUD.sharedHUD.isVisible
        {
            PKHUD.sharedHUD.contentView = PKHUDProgressView()
            PKHUD.sharedHUD.show(onView: lastInitialisedController.view)
        }
    }
}

///Allows two dates to be compared with custom characters.
public func ==(lhs: NSDate, rhs: NSDate) -> Bool
{
    return lhs === rhs || lhs.compare(rhs as Date) == .orderedSame
}

///Allows two dates to be compared with custom characters.
public func <(lhs: NSDate, rhs: NSDate) -> Bool
{
    return lhs.compare(rhs as Date) == .orderedAscending
}

//--------------------------------------------------//

//Extensions

extension UITextView
{
    func fontSizeThatFits(_ alternateText: String?) -> CGFloat
    {
        if let labelText = alternateText ?? text
        {
            let frameToUse = (superview as? UIButton != nil ? superview!.frame : frame)
            
            let mutableCopy = UILabel(frame: frameToUse)
            mutableCopy.font = font
            mutableCopy.text = labelText
            
            var initialSize = mutableCopy.text!.size(withAttributes: [NSAttributedString.Key.font: mutableCopy.font!])
            
            while initialSize.width > mutableCopy.frame.size.width
            {
                let newSize = mutableCopy.font.pointSize - 0.5
                
                if newSize > 0.0
                {
                    mutableCopy.font = mutableCopy.font.withSize(newSize)
                    
                    initialSize = mutableCopy.text!.size(withAttributes: [NSAttributedString.Key.font: mutableCopy.font!])
                }
                else
                {
                    return 0.0
                }
            }
            
            return mutableCopy.font.pointSize
        }
        else
        {
            return self.font!.pointSize
        }
    }
    
    func scaleToMinimum(alternateText: String?, originalText: String?, minimumSize: CGFloat)
    {
        if let labelText = originalText ?? text
        {
            if textWillFit(labelText, minimumSize: minimumSize)
            {
                font = font!.withSize(fontSizeThatFits(labelText))
            }
            else
            {
                if let labelText = alternateText
                {
                    if textWillFit(labelText, minimumSize: minimumSize)
                    {
                        font = font!.withSize(fontSizeThatFits(labelText))
                    }
                    else
                    {
                        report("Neither the original nor alternate strings fit.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                    }
                }
            }
        }
    }
    
    func textWillFit(_ alternateText: String?, minimumSize: CGFloat) -> Bool
    {
        return fontSizeThatFits(alternateText) >= minimumSize
    }
}

extension UILabel
{
    func fontSizeThatFits(_ alternateText: String?) -> CGFloat
    {
        if let labelText = alternateText ?? text
        {
            let frameToUse = (superview as? UIButton != nil ? superview!.frame : frame)
            
            let mutableCopy = UILabel(frame: frameToUse)
            mutableCopy.font = font
            mutableCopy.lineBreakMode = lineBreakMode
            mutableCopy.numberOfLines = numberOfLines
            mutableCopy.text = labelText
            
            var initialSize = mutableCopy.text!.size(withAttributes: [NSAttributedString.Key.font: mutableCopy.font!])
            
            while initialSize.width > mutableCopy.frame.size.width
            {
                let newSize = mutableCopy.font.pointSize - 0.5
                
                if newSize > 0.0
                {
                    mutableCopy.font = mutableCopy.font.withSize(newSize)
                    
                    initialSize = mutableCopy.text!.size(withAttributes: [NSAttributedString.Key.font: mutableCopy.font!])
                }
                else
                {
                    return 0.0
                }
            }
            
            return mutableCopy.font.pointSize
        }
        else
        {
            return self.font.pointSize
        }
    }
    
    func scaleToMinimum(alternateText: String?, originalText: String?, minimumSize: CGFloat)
    {
        if let labelText = originalText ?? text
        {
            if textWillFit(labelText, minimumSize: minimumSize)
            {
                font = font.withSize(fontSizeThatFits(labelText))
            }
            else
            {
                if let labelText = alternateText
                {
                    if textWillFit(labelText, minimumSize: minimumSize)
                    {
                        font = font.withSize(fontSizeThatFits(labelText))
                    }
                    else
                    {
                        report("Neither the original nor alternate strings fit.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                    }
                }
                else
                {
                    report("Original string didn't fit, no alternate provided.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                }
            }
        }
    }
    
    func textWillFit(_ alternateText: String?, minimumSize: CGFloat) -> Bool
    {
        return fontSizeThatFits(alternateText) >= minimumSize
    }
}

extension Array
{
    var chooseOne: Element
    {
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
    
    var shuffledValue: [Element]
    {
        var arrayElements = self
        
        for individualIndex in 0..<arrayElements.count
        {
            arrayElements.swapAt(individualIndex, Int(arc4random_uniform(UInt32(arrayElements.count-individualIndex)))+individualIndex)
        }
        
        return arrayElements
    }
}

extension Date
{
    func amountOfSeconds(from date: Date) -> Int
    {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
    var startOfDay: Date
    {
        return NSCalendar.current.startOfDay(for: self)
    }
    
    func getElapsedInterval() -> String
    {
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: Date())
        
        if let yearsPassed = interval.year,
            yearsPassed > 0
        {
            return "\(yearsPassed)y"
        }
        else if let monthsPassed = interval.month,
            monthsPassed > 0
        {
            return "\(monthsPassed)mo"
        }
        else if let daysPassed = interval.day,
            daysPassed > 0
        {
            return "\(daysPassed)d"
        }
        else if let hoursPassed = interval.hour,
            hoursPassed > 0
        {
            return "\(hoursPassed)h"
        }
        else if let minutesPassed = interval.minute,
            minutesPassed > 0
        {
            return "\(minutesPassed)m"
        }
        
        return "now"
    }
}

extension Dictionary
{
    mutating func switchKey(fromKey: Key, toKey: Key)
    {
        if let dictionaryEntry = removeValue(forKey: fromKey)
        {
            self[toKey] = dictionaryEntry
        }
    }
}

extension Dictionary where Value: Equatable
{
    func allKeys(forValue: Value) -> [Key]
    {
        return self.filter { $1 == forValue }.map { $0.0 }
    }
}

extension Int
{
    var arrayValue: [Int]
    {
        return description.map{Int(String($0)) ?? 0}
    }
    
    var ordinalValue: String
    {
        get
        {
            var determinedSuffix = "th"
            
            switch self % 10
            {
            case 1:
                determinedSuffix = "st"
            case 2:
                determinedSuffix = "nd"
            case 3:
                determinedSuffix = "rd"
            default: ()
            }
            
            if 10 < (self % 100) && (self % 100) < 20
            {
                determinedSuffix = "th"
            }
            
            return String(self) + determinedSuffix
        }
    }
}

extension NSDate: Comparable { }

extension String
{
    func chopPrefix(_ countToChop: Int = 1) -> String
    {
        return String(suffix(from: index(startIndex, offsetBy: countToChop)))
    }
    
    func chopSuffix(_ countToChop: Int = 1) -> String
    {
        return String(prefix(count - countToChop))
    }
    
    var digitalValue: Int
    {
        return Int(components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: ""))!
    }
    
    var firstCapitalised: String
    {
        return String(prefix(1)).uppercased() + String(dropFirst())
    }
    
    var firstLowercased: String
    {
        return String(prefix(1)).lowercased() + String(dropFirst())
    }
    
    var isAlphanumeric: Bool
    {
        return range(of: "^[:alnum:]+$", options: .regularExpression) != nil
    }
    
    var jumbledValue: String
    {
        return String(describing: Array(arrayLiteral: self).shuffledValue)
    }
    
    var length: Int
    {
        return count
    }
    
    var alphabeticalPositionValue: Int
    {
        return ((Array("abcdefghijklmnopqrstuvwxyz").firstIndex(of: Character(lowercased())))! + 1)
    }
    
    var noWhiteSpaceLowerCaseString: String
    {
        return trimmingCharacters(in: .whitespacesAndNewlines).lowercased().replacingOccurrences(of: " ", with: "")
    }
    
    func removeWhitespace() -> String
    {
        return replacingOccurrences(of: " ", with: "")
    }
    
    var stringCharacters: [String]
    {
        return map { String($0) }
    }
}

extension UIImageView
{
    func downloadedFrom(_ imageLink: String, contentMode mode: UIView.ContentMode = .scaleAspectFit)
    {
        guard let imageUrl = URL(string: imageLink) else { return }
        downloadedFrom(imageUrl: imageUrl, contentMode: mode)
    }
    
    func downloadedFrom(imageUrl: URL, contentMode mode: UIView.ContentMode = .scaleAspectFill)
    {
        contentMode = mode
        
        URLSession.shared.dataTask(with: imageUrl) { (privateRetrievedData, privateUrlResponse, privateOccurredError) in
            guard
                let urlResponse = privateUrlResponse as? HTTPURLResponse, urlResponse.statusCode == 200,
                let mimeType = privateUrlResponse?.mimeType, mimeType.hasPrefix("image"),
                let retrievedData = privateRetrievedData, privateOccurredError == nil,
                let retrievedImage = UIImage(data: retrievedData)
                else { DispatchQueue.main.async() { () -> Void in self.image = UIImage(named: "Not Found") }; return }
            DispatchQueue.main.async() { () -> Void in
                self.image = retrievedImage
            }
        }.resume()
    }
}

extension UILabel
{
    var isTruncated: Bool
    {
        guard let labelText = text as NSString? else {
            return false
        }
        
        let contentSize = labelText.size(withAttributes: [.font: font!])
        
        return contentSize.width > bounds.width
    }
}

extension UIView
{
    func addBlur(withActivityIndicator: Bool, withStyle: UIBlurEffect.Style, withTag: Int)
    {
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: withStyle))
        
        blurEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        blurEffectView.frame = bounds
        blurEffectView.tag = withTag
        
        addSubview(blurEffectView)
        
        if withActivityIndicator
        {
            let activityIndicatorView = UIActivityIndicatorView(style: .large)
            activityIndicatorView.center = center
            activityIndicatorView.startAnimating()
            activityIndicatorView.tag = aTagFor("BLUR_INDICATOR")
            addSubview(activityIndicatorView)
        }
    }
    
    ////Adds a translation progress overlay to any view.
    func addTranslationProgressOverlay(toViewNamed: String)
    {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        })
        
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.center = center
        activityIndicatorView.startAnimating()
        activityIndicatorView.tag = aTagFor(toViewNamed)
        activityIndicatorView.alpha = 0
        lastInitialisedController.view.addSubview(activityIndicatorView)
        
        UIView.animate(withDuration: 0.2) {
            activityIndicatorView.alpha = 1
        }
    }
    
    /**
     Attempts to find a subview for a given tag.
     
     - Parameter byTag: The tag by which to search for the view.
     */
    func findSubview(_ byTag: Int) -> UIView?
    {
        for individualSubview in subviews
        {
            if individualSubview.tag == byTag
            {
                return individualSubview
            }
        }
        
        return nil
    }
    
    func removeBlur(withTag: Int)
    {
        for indivdualSubview in subviews
        {
            if indivdualSubview.tag == withTag || indivdualSubview.tag == aTagFor("BLUR_INDICATOR")
            {
                UIView.animate(withDuration: 0.2, animations: {
                    indivdualSubview.alpha = 0
                }) { (didComplete) in
                    if didComplete
                    {
                        indivdualSubview.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    ////Removes a translation progress overlay from any view.
    func removeTranslationProgressOverlay(fromViewNamed: String, oldAlpha: CGFloat?)
    {
        var activityIndicator: UIView?
        
        UIView.animate(withDuration: 0.2, animations: {
            for individualSubview in lastInitialisedController.view.subviews
            {
                if individualSubview.tag == aTagFor(fromViewNamed)
                {
                    activityIndicator = individualSubview
                    individualSubview.alpha = 0
                }
                
                self.alpha = oldAlpha ?? 1
            }
        }) { (didComplete) in
            if didComplete
            {
                if let unwrappedActivityIndicator = activityIndicator
                {
                    unwrappedActivityIndicator.removeFromSuperview()
                }
            }
        }
    }
}

extension UIImage
{
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1))
    {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UIColor
{
    private convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0)
    {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    /**
     Creates a color object using the specified RGB/hexadecimal code.
     
     - Parameter rgb: A hexadecimal integer.
     - Parameter alpha: The opacity of the color, from 0.0 to 1.0.
     */
    convenience init(rgb: Int, alpha: CGFloat = 1.0)
    {
        self.init(red: (rgb >> 16) & 0xFF, green: (rgb >> 8) & 0xFF, blue: rgb & 0xFF, alpha: alpha)
    }
    
    /**
     Creates a color object using the specified hexadecimal code.
     
     - Parameter hex: A hexadecimal integer.
     */
    convenience init(hex: Int)
    {
        self.init(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: hex & 0xFF, alpha: 1.0)
    }
}
