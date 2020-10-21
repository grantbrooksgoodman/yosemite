//
//  CardView.swift
//  Gamma
//
//  Created by Grant Brooks Goodman on 17/07/2020.
//  Copyright © 2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

import Firebase
import UserNotifications

class CardView: UIView
{
    //--------------------------------------------------//
    
    /* Interface Builder UI Elements */
    
    //ShadowButtons
    @IBOutlet weak var closeButton:       ShadowButton!
    @IBOutlet weak var dislikeButton:     ShadowButton!
    @IBOutlet weak var informationButton: ShadowButton!
    @IBOutlet weak var likeButton:        ShadowButton!
    
    //Other Elements
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoPageControl: UIPageControl!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: TranslatedLabel!
    
    @IBOutlet weak var similarityView: UIView!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    var quickFactsView: QuickFactsView!
    var cardPageController: CardPageController?
    var didDraw = false
    
    //--------------------------------------------------//
    
    /* Overridden Functions */
    
    override func draw(_ rect: CGRect)
    {
        if !didDraw
        {
            backgroundColor = UIColor(hex: 0xE1E0E1)
            
            clipsToBounds = true
            
            layer.borderColor = UIColor(hex: 0xE1E0E1).cgColor
            layer.borderWidth = 3
            layer.cornerRadius = 10
            layer.masksToBounds = true
            
            closeButton.alpha = 0
            dislikeButton.alpha = 0
            likeButton.alpha = 0
            
            segmentedControl.alpha = 0
            
            closeButton.updateFrame()
            dislikeButton.updateFrame()
            likeButton.updateFrame()
            
            closeButton.initialiseLayer(animateTouches: true,
                                        backgroundColour: .white,
                                        customBorderFrame: nil,
                                        customCornerRadius: 5,
                                        shadowColour: UIColor.clear.cgColor,
                                        instanceName: nil)
            
            dislikeButton.initialiseLayer(animateTouches: true,
                                          backgroundColour: UIColor(hex: 0xE95A53),
                                          customBorderFrame: nil,
                                          customCornerRadius: nil,
                                          shadowColour: UIColor(hex: 0xD5443B).cgColor,
                                          instanceName: nil)
            
            likeButton.initialiseLayer(animateTouches: true,
                                       backgroundColour: UIColor(hex: 0x60C129),
                                       customBorderFrame: nil,
                                       customCornerRadius: nil,
                                       shadowColour: UIColor(hex: 0x3B9A1B).cgColor,
                                       instanceName: nil)
            
            didDraw = true
            
            frame = f.frame(frame)
            similarityView.updateFrame()
            
            addSwipe()
        }
    }
    
    //--------------------------------------------------//
    
    /* Interface Builder Actions */
    
    @IBAction func closeButton(_ sender: Any)
    {
        //toggleQuickFactsView(on: false)
        toggleCardPageController(on: false)
    }
    
    @IBAction func dislikeButton(_ sender: Any)
    {
        (self.parentViewController as! CardController).shouldSwipeCard = true
        (parentViewController as! CardController).kolodaView.swipe(.left)
    }
    
    @IBAction func informationButton(_ sender: Any)
    {
        toggleCardPageController(on: true)
        //toggleQuickFactsView(on: true)
    }
    
    @IBAction func likeButton(_ sender: Any)
    {
        (self.parentViewController as! CardController).shouldSwipeCard = true
        (parentViewController as! CardController).kolodaView.swipe(.right)
    }
    
    @IBAction func nextButton(_ sender: Any)
    {
        
    }
    
    @IBAction func segmentedControl(_ sender: Any)
    {
        if let cardPageController = cardPageController
        {
            if segmentedControl.selectedSegmentIndex == 0
            {
                cardPageController.displaysFactoids = true
            }
            else
            {
                cardPageController.displaysFactoids = false
            }
        }
    }
    
    //--------------------------------------------------//
    
    /* Independent Functions */
    
    func addSwipe()
    {
        let directions: [UISwipeGestureRecognizer.Direction] = [.down]
        for direction in directions
        {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(CardView.handleSwipe))
            gesture.direction = direction
            self.addGestureRecognizer(gesture)
        }
    }
    
    @objc func handleSwipe()
    {
        if !(self.parentViewController as! CardController).shouldSwipeCard
        {
            closeButton(closeButton!)
        }
    }
    
    func postNotification(_ withMessage: String)
    {
        let content = UNMutableNotificationContent()
        //content.title = withMessage //NSString.localizedUserNotificationString(forKey: "Hello!", arguments: nil)
        content.body = withMessage //NSString.localizedUserNotificationString(forKey: "Hello_message_body", arguments: nil)
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "notify-test"
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.01, repeats: false)
        let request = UNNotificationRequest.init(identifier: "notify-test", content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error
            {
                report(error.localizedDescription, errorCode: (error as NSError).code, isFatal: false, metadata: [#file, #function, #line])
            }
        }
    }
    
    func toggleCardPageController(on: Bool)
    {
        let screenSize = UIScreen.main.bounds.size
        
        let isFourInchScreen = screenSize.height == f.screenHeight(.fourInch)
        let isFourSevenInchScreen = screenSize.height == f.screenHeight(.fourSevenInch)
        let isFiveFiveInchScreen = screenSize.height == f.screenHeight(.fiveFiveInch)
        let isSixInchScreen = screenSize.height == f.screenHeight(.sixInch)
        
        var calculatedImageViewHeightModifier = f.height(131)
        var calculatedNameYOriginModifier = f.height(200)
        
        var calculatedCardPageControllerHeight = f.height(150)
        
        if isFourInchScreen
        {
            calculatedImageViewHeightModifier = f.height(171) + 15
            calculatedNameYOriginModifier = f.height(181)
            calculatedCardPageControllerHeight = f.height(200)
        }
        else if isFourSevenInchScreen
        {
            calculatedImageViewHeightModifier = f.height(161)
            calculatedNameYOriginModifier = f.height(181)
            calculatedCardPageControllerHeight = f.height(170)
        }
        else if isFiveFiveInchScreen
        {
            calculatedImageViewHeightModifier += 8
        }
        else if isSixInchScreen
        {
            calculatedImageViewHeightModifier -= 25
            calculatedNameYOriginModifier -= 25
            calculatedCardPageControllerHeight -= 25
        }
        
        let buttonAlpha:             CGFloat = on ? 1 : 0
        let imageViewHeightModifier: CGFloat = on ? calculatedImageViewHeightModifier : -calculatedImageViewHeightModifier
        let nameYOriginModifier:     CGFloat = on ? calculatedNameYOriginModifier : -calculatedNameYOriginModifier
        
        let originalImageViewHeight = profileImageView.frame.size.height
        
        var calculatedCardPageControllerYOrigin = (originalImageViewHeight - imageViewHeightModifier) + 3
        
        if isFourInchScreen && on
        {
            calculatedCardPageControllerYOrigin += 1
            self.likeButton.frame.origin.y -= 35
            self.dislikeButton.frame.origin.y -= 35
            self.nameLabel.frame.origin.y -= 30
            self.closeButton.frame.origin.y -= 40
        }
        else if isFourSevenInchScreen && on
        {
            calculatedCardPageControllerYOrigin += 1
            self.likeButton.frame.origin.y -= 15
            self.dislikeButton.frame.origin.y -= 15
            self.nameLabel.frame.origin.y -= 10
            self.closeButton.frame.origin.y -= 20
        }
        else if isFiveFiveInchScreen && on
        {
            calculatedCardPageControllerYOrigin += 1
            calculatedCardPageControllerHeight += 8
        }
        else if isSixInchScreen && on
        {
            self.likeButton.frame.origin.y += 25
            self.dislikeButton.frame.origin.y += 25
            self.nameLabel.frame.origin.y += 20
            self.closeButton.frame.origin.y += 30
        }
        
        if let cardController = parentViewController as? CardController,
            let cardPageController = cardPageController,
            let kolodaView = cardController.kolodaView,
            let cardView = kolodaView.viewForCard(at: kolodaView.currentCardIndex) as? CardView,
            let progressView = cardView.viewWithTag(aTagFor("progressView")),
            let label = cardView.viewWithTag(aTagFor("label")) as? UILabel
        {
            if on
            {
                cardPageController.view.alpha = 0
                cardPageController.view.backgroundColor = .systemBackground
                
                if cardController.view.viewWithTag(aTagFor("cardPageController")) == nil
                {
                    //Set up the frame for the newly instantiated UIViewController.
                    cardPageController.view.frame = CGRect(x: f.x(0),
                                                           y: calculatedCardPageControllerYOrigin,
                                                           width: f.width(365),
                                                           height: calculatedCardPageControllerHeight)
                    
                    cardPageController.willMove(toParent: cardController)
                    addSubview(cardPageController.view)
                    cardPageController.didMove(toParent: cardController)
                    
                    openStream(forFile: #file, forFunction: #function, forLine: #line, withMessage: "instantiated")
                }
                else
                {
                    openStream(forFile: #file, forFunction: #function, forLine: #line, withMessage: "not nil, already instantiated")
                }
            }
            
            UIView.animate(withDuration: 0.25, animations: {
                
                cardView.similarityView.alpha = on ? 0 : 1
                progressView.alpha = on ? 0 : 1
                label.alpha = on ? 0 : 1
                
                self.informationButton.alpha = on ? 0 : 1
                self.subtitleLabel.alpha     = on ? 0 : 1
                
                self.nameLabel.frame.origin.y -= nameYOriginModifier
                
                self.profileImageView.frame.size.height -= imageViewHeightModifier
                self.profileImageView.contentMode = .scaleAspectFill
                
                if on
                {
                    self.bringSubviewToFront(self.closeButton)
                }
                else
                {
                    if isFourInchScreen
                    {
                        self.likeButton.frame.origin.y += 35
                        self.dislikeButton.frame.origin.y += 35
                        self.nameLabel.frame.origin.y += 30
                        self.closeButton.frame.origin.y += 40
                    }
                    else if isFourSevenInchScreen
                    {
                        self.likeButton.frame.origin.y += 15
                        self.dislikeButton.frame.origin.y += 15
                        self.nameLabel.frame.origin.y += 10
                        self.closeButton.frame.origin.y += 20
                    }
                    else if isSixInchScreen
                    {
                        self.likeButton.frame.origin.y -= 25
                        self.dislikeButton.frame.origin.y -= 25
                        self.nameLabel.frame.origin.y -= 20
                        self.closeButton.frame.origin.y -= 30
                    }
                }
                
                (self.parentViewController as! CardController).shouldSwipeCard = on ? false : true
                
                self.closeButton.alpha        = buttonAlpha
                self.dislikeButton.alpha      = buttonAlpha
                self.likeButton.alpha         = buttonAlpha
                self.segmentedControl.alpha   = buttonAlpha
                cardPageController.view.alpha = buttonAlpha
            }) { (_) in
                if on
                {
                    if cardController.view.viewWithTag(aTagFor("cardPageController")) == nil
                    {
                        logToStream(forLine: #line, withMessage: "is cardPageController on the superview? \(cardController.view.viewWithTag(aTagFor("cardPageController")) == nil ? "no" : "yes")")
                        
                        closeStream(onLine: #line, withMessage: "GOT TO SET UP!")
                        
                        //Set up the frame for the newly instantiated UIViewController.
                        cardPageController.view.frame = CGRect(x: f.x(0),
                                                               y: calculatedCardPageControllerYOrigin,
                                                               width: f.width(365),
                                                               height: calculatedCardPageControllerHeight)
                        
                        cardPageController.willMove(toParent: cardController)
                        self.addSubview(cardPageController.view)
                        cardPageController.didMove(toParent: cardController)
                        
                        cardPageController.view.alpha = 1
                    }
                    else
                    {
                        closeStream(onLine: #line, withMessage: "is cardPageController on the superview? \(cardController.view.viewWithTag(aTagFor("cardPageController")) == nil ? "no" : "yes")")
                    }  
                }
            }
        }
    }
    
    func trashDatabase()
    {
        AlertKit().confirmationAlertController(title: "Trash Database?",
                                               message: "This will erase all data on the web server.",
                                               cancelConfirmTitles: ["confirm": "Confirm"],
                                               confirmationDestructive: true,
                                               confirmationPreferred: false,
                                               networkDepedent: true) { (didConfirm) in
                                                
                                                if let didConfirm = didConfirm, didConfirm
                                                {
                                                    Database.database().reference().child("/").removeValue(completionBlock: { (error, refer) in
                                                        if error != nil {
                                                            report(error?.localizedDescription ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                                                            
                                                            AlertKit().errorAlertController(title: nil,
                                                                                            message: error?.localizedDescription,
                                                                                            dismissButtonTitle: nil,
                                                                                            additionalSelectors: nil,
                                                                                            preferredAdditionalSelector: nil,
                                                                                            canFileReport: true,
                                                                                            extraInfo: nil,
                                                                                            metadata: [#file, #function, #line],
                                                                                            networkDependent: true)
                                                        }
                                                        else
                                                        {
                                                            AlertKit().successAlertController(withTitle: "Success",
                                                                                              withMessage: "Data trashed successfully.",
                                                                                              withCancelButtonTitle: nil,
                                                                                              withAlternateSelectors: nil,
                                                                                              preferredActionIndex: nil)
                                                        }
                                                    })
                                                }}
    }
}
