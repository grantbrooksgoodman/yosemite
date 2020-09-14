//
//  BuildInfoController.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class BuildInfoController: UIViewController
{
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    //Other Declarations
    let screenBounds = UIScreen.main.bounds
    private let window = BuildInfoWindow()
    
    private(set) var sendFeedbackButton: UIButton!
    
    //--------------------------------------------------//
    
    /* Constructor Functions */
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
        
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.isHidden = false
        window.rootViewController = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(note:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError()
    }
    
    //--------------------------------------------------//
    
    /* Override Functions */
    
    override func loadView()
    {
        let windowView = UIView()
        
        let sendFeedbackButton = getSendFeedbackButton()
        let buildInfoLabel = getBuildInfoLabel(xBaseline: sendFeedbackButton.frame.maxX)
        
        windowView.addSubview(sendFeedbackButton)
        windowView.addSubview(buildInfoLabel)
        
        self.view = windowView
        
        self.sendFeedbackButton = sendFeedbackButton
        window.sendFeedbackButton = sendFeedbackButton
    }
    
    //--------------------------------------------------//
    
    /* Independent Functions */
    
    @objc func keyboardDidShow(note: NSNotification)
    {
        window.windowLevel = UIWindow.Level(rawValue: 0)
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
    }
    
    @objc func sendFeedbackButtonAction()
    {
        if isPresentingMailComposeViewController
        {
            AlertKit().errorAlertController(title: "Already Filing Report",
                                            message: "It appears that a report is already being filed.\n\nPlease complete the first report before beginning another.",
                                            dismissButtonTitle: "OK",
                                            additionalSelectors: nil,
                                            preferredAdditionalSelector: nil,
                                            canFileReport: false,
                                            extraInfo: nil,
                                            metadata: [#file, #function, #line],
                                            networkDependent: false)
        }
        else
        {
            AlertKit().optionAlertController(withTitle: "File Report", withMessage: "Choose the option which best describes your intention.", withCancelButtonTitle: nil, withActions: ["Send Feedback", "Report a Bug"], preferredActionIndex: nil, destructiveActionIndex: nil, networkDependent: true) { (option) in
                if let option = option
                {
                    if option == 0
                    {
                        AlertKit().fileReport(type: .feedback, body: "Appended below are various data points useful in analysing any potential problems within the application. Please do not edit the information contained in the lines below, with the exception of the last field, in which any general feedback is appreciated.", prompt: "General Feedback", extraInfo: nil, metadata: [#file, #function, #line])
                    }
                    else if option == 1
                    {
                        AlertKit().fileReport(type: .bug, body: "In the appropriate section, please describe the error encountered and the steps to reproduce it.", prompt: "Description/Steps to Reproduce", extraInfo: nil, metadata: [#file, #function, #line])
                    }
                }
            }
        }
    }
    
    //--------------------------------------------------//
    
    /* Private Functions */
    
    private func getBuildInfoLabel(xBaseline: CGFloat) -> UILabel
    {
        let buildInfoLabel = UILabel()
        
        let titleToSet = "\(codeName) \(informationDictionary["bundleVersion"]!) (\(informationDictionary["buildNumberAsString"]!)\(buildTypeAsString(short: true)))"
        
        buildInfoLabel.backgroundColor = .black
        buildInfoLabel.font = UIFont(name: "SFUIText-Bold", size: 13)
        buildInfoLabel.text = titleToSet
        buildInfoLabel.textColor = .white
        
        buildInfoLabel.font = buildInfoLabel.font.withSize(buildInfoLabel.fontSizeThatFits(buildInfoLabel.text))
        
        let buildInfoWidth = buildInfoLabel.sizeThatFits(buildInfoLabel.intrinsicContentSize).width
        
        let buildInfoXOrigin = xBaseline - (buildInfoWidth)
        let buildInfoYOrigin = UIScreen.main.bounds.maxY - (15 + 20)
        
        buildInfoLabel.frame = CGRect(x: buildInfoXOrigin, y: buildInfoYOrigin, width: buildInfoWidth, height: 15)
        
        return buildInfoLabel
    }
    
    private func getSendFeedbackButton() -> UIButton
    {
        let sendFeedbackButton = UIButton(type: .system)
        
        let sendFeedbackAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Arial", size: 12)!,
                                                                     .foregroundColor: UIColor.white,
                                                                     .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        let sendFeedbackAttributedString = NSMutableAttributedString(string: sendFeedbackDictionary[languageCode] ?? "Send Feedback", attributes: sendFeedbackAttributes)
        
        sendFeedbackButton.setAttributedTitle(sendFeedbackAttributedString, for: .normal)
        
        let sendFeedbackHeight = sendFeedbackButton.intrinsicContentSize.height - 5
        let sendFeedbackWidth = sendFeedbackButton.intrinsicContentSize.width
        
        let sendFeedbackXOrigin = screenBounds.width - (sendFeedbackWidth + 25)
        let sendFeedbackYOrigin = screenBounds.maxY - (sendFeedbackHeight + 35)
        
        sendFeedbackButton.backgroundColor = .black
        sendFeedbackButton.frame = CGRect(x: sendFeedbackXOrigin, y: sendFeedbackYOrigin, width: sendFeedbackWidth, height: sendFeedbackHeight)
        
        return sendFeedbackButton
    }
}

private class BuildInfoWindow: UIWindow
{
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    var sendFeedbackButton: UIButton?
    
    //--------------------------------------------------//
    
    /* Constructor Functions */
    
    init()
    {
        super.init(frame: UIScreen.main.bounds)
        
        backgroundColor = nil
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    //--------------------------------------------------//
    
    /* Override Functions */
    
    fileprivate override func point(inside point: CGPoint, with event: UIEvent?) -> Bool
    {
        guard let sendFeedbackButton = sendFeedbackButton else { return false }
        
        let buttonPoint = convert(point, to: sendFeedbackButton)
        
        return sendFeedbackButton.point(inside: buttonPoint, with: event)
    }
}
