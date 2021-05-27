//
//  CardView.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 17/07/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import UIKit

/* Third-party Frameworks */
import Firebase
import UserNotifications

class CardView: UIView {
    
    //==================================================//
    
    /* MARK: - Interface Builder UI Elements */
    
    //NSLayoutConstraints
    @IBOutlet weak var nameLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var similarityViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var subtitleLabelTopConstraint: NSLayoutConstraint!
    
    //ShadowButtons
    @IBOutlet weak var closeButton:       ShadowButton!
    @IBOutlet weak var dislikeButton:     ShadowButton!
    @IBOutlet weak var informationButton: ShadowButton!
    @IBOutlet weak var likeButton:        ShadowButton!
    
    //UIButtons
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    //UILabels
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var similarityLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    //Other Elements
    @IBOutlet weak var photoPageControl: UIPageControl!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var similarityView: UIView!
    
    //==================================================//
    
    /* MARK: - Class-level Variable Declarations */
    
    //NSLayoutConstraints
    var cardConstraint: NSLayoutConstraint!
    var subtitleLabelConstraint: NSLayoutConstraint!
    
    //Other Declarations
    var cardPageController: CardPageController?
    var currentImageIndex = 0
    var didDraw = false
    var quickFactsView: QuickFactsView!
    var user: User!
    
    //==================================================//
    
    /* MARK: - Overridden Functions */
    
    override func draw(_ rect: CGRect) {
        if !didDraw {
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
            
            closeButton.initializeLayer(animateTouches: true,
                                        backgroundColor: .white,
                                        customCornerRadius: 5,
                                        shadowColor: UIColor.clear.cgColor)
            
            dislikeButton.initializeLayer(animateTouches: true,
                                          backgroundColor: UIColor(hex: 0xE95A53),
                                          customCornerRadius: nil,
                                          shadowColor: UIColor(hex: 0xD5443B).cgColor)
            
            likeButton.initializeLayer(animateTouches: true,
                                       backgroundColor: UIColor(hex: 0x60C129),
                                       customCornerRadius: nil,
                                       shadowColor: UIColor(hex: 0x3B9A1B).cgColor)
            
            backButton.tag = aTagFor("backButton")
            
            photoPageControl.numberOfPages = user.userData.profileImageData?.count ?? 0
            
            didDraw = true
            
            addSwipe()
            
            subtitleLabelConstraint = subtitleLabelTopConstraint
            cardConstraint = NSLayoutConstraint(item: nameLabel!, attribute: .bottom, relatedBy: .equal, toItem: cardPageController!.view, attribute: .top, multiplier: 1, constant: -5)
        }
    }
    
    //==================================================//
    
    /* MARK: - Interface Builder Actions */
    
    @IBAction func closeButton(_ sender: Any) {
        dismissCardPageController()
    }
    
    @IBAction func dislikeButton(_ sender: Any) {
        (self.parentViewController as! CardController).shouldSwipeCard = true
        (parentViewController as! CardController).kolodaView.swipe(.left)
    }
    
    @IBAction func informationButton(_ sender: Any) {
        instantiateCardPageController()
        presentCardPageController()
    }
    
    @IBAction func likeButton(_ sender: Any) {
        (self.parentViewController as! CardController).shouldSwipeCard = true
        (parentViewController as! CardController).kolodaView.swipe(.right)
    }
    
    @IBAction func photoButton(_ sender: Any) {
        if let button = sender as? UIButton {
            if let imageDataArray = user.userData.profileImageData {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                
                let increment = (button.tag == aTagFor("backButton")) ? currentImageIndex - 1 : currentImageIndex + 1
                
                let boolTest = (button.tag == aTagFor("backButton")) ? increment > -1 : increment < imageDataArray.count
                
                if boolTest {
                    let imageData = Data(base64Encoded: imageDataArray[increment], options: .ignoreUnknownCharacters)
                    
                    profileImageView.image = UIImage(data: imageData!)
                    currentImageIndex = increment
                }
                
                photoPageControl.currentPage = currentImageIndex
            }
        }
    }
    
    @IBAction func segmentedControl(_ sender: Any) {
        if let cardPageController = cardPageController {
            if segmentedControl.selectedSegmentIndex == 0 {
                cardPageController.displaysFactoids = true
            } else {
                cardPageController.displaysFactoids = false
            }
        }
    }
    
    //==================================================//
    
    /* MARK: - Presentation Layout Functions */
    
    func instantiateCardPageController() {
        if let cardController = parentViewController as? CardController,
           let cardPageController = cardPageController,
           let kolodaView = cardController.kolodaView,
           let cardView = kolodaView.viewForCard(at: kolodaView.currentCardIndex) as? CardView {
            
            cardPageController.view.alpha = 0
            cardPageController.view.backgroundColor = .systemBackground
            
            if cardController.view.viewWithTag(aTagFor("cardPageController")) == nil {
                //Set up the frame for the newly instantiated UIViewController.
                cardPageController.view.frame.size.height = 150
                cardPageController.view.frame.origin.y = cardView.frame.maxY - cardPageController.view.frame.height
                
                let topBorder: CALayer = CALayer()
                topBorder.frame = CGRect(x: 0.0, y: 0.0, width: cardPageController.view.frame.size.width, height: 3.0)
                topBorder.backgroundColor = UIColor(hex: 0xE1E0E1).cgColor
                cardPageController.view.layer.addSublayer(topBorder)
                
                cardPageController.willMove(toParent: cardController)
                addSubview(cardPageController.view)
                cardPageController.didMove(toParent: cardController)
                
                cardPageController.view.center.x = kolodaView.center.x
                
                openStream(forFile: #file, forFunction: #function, forLine: #line, withMessage: "instantiated")
            } else {
                openStream(forFile: #file, forFunction: #function, forLine: #line, withMessage: "not nil, already instantiated")
            }
        }
    }
    
    func presentCardPageController() {
        UIView.animate(withDuration: 0.1) {
            self.nameLabel.alpha         = 0
            self.informationButton.alpha = 0
            self.similarityView.alpha    = 0
            self.subtitleLabel.alpha     = 0
        } completion: { _ in
            self.toggleConstraints(on: true)
            
            UIView.animate(withDuration: 0.1, delay: 0.2) {
                self.cardPageController?.view.alpha = 1
                
                self.closeButton.alpha              = 1
                self.dislikeButton.alpha            = 1
                self.likeButton.alpha               = 1
                
                self.nameLabel.alpha                = 1
                self.segmentedControl.alpha         = 1
            }
        }
    }
    
    func dismissCardPageController() {
        UIView.animate(withDuration: 0.1) {
            self.cardPageController?.view.alpha = 0
            
            self.closeButton.alpha              = 0
            self.dislikeButton.alpha            = 0
            self.likeButton.alpha               = 0
            
            self.nameLabel.alpha                = 0
            self.segmentedControl.alpha         = 0
        } completion: { _ in
            self.toggleConstraints(on: false)
            
            UIView.animate(withDuration: 0.1, delay: 0.2) {
                self.nameLabel.alpha         = 1
                self.informationButton.alpha = 1
                self.similarityView.alpha    = 1
                self.subtitleLabel.alpha     = 1
            }
        }
    }
    
    func toggleConstraints(on: Bool) {
        if on {
            self.subtitleLabelTopConstraint.isActive = false
            self.nameLabelTopConstraint.isActive = true
            
            self.addConstraint(self.cardConstraint)
            
            self.profileImageViewConstraint.constant -= (cardPageController!.view.frame.size.height - 30)
            
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
        } else {
            self.removeConstraint(self.cardConstraint)
            
            self.subtitleLabelTopConstraint = self.subtitleLabelConstraint
            self.subtitleLabelTopConstraint.isActive = true
            
            self.nameLabelTopConstraint.isActive = false
            
            self.profileImageViewConstraint.constant += (cardPageController!.view.frame.size.height - 30)
            
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
        }
        
        (self.parentViewController as! CardController).shouldSwipeCard = on ? false : true
    }
    
    //==================================================//
    
    /* MARK: - Other Functions */
    
    func addSwipe() {
        let directions: [UISwipeGestureRecognizer.Direction] = [.down]
        
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(CardView.handleSwipe))
            gesture.direction = direction
            self.addGestureRecognizer(gesture)
        }
    }
    
    @objc func handleSwipe() {
        if !(self.parentViewController as! CardController).shouldSwipeCard {
            closeButton(closeButton!)
        }
    }
    
    func postNotification(_ withMessage: String) {
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
            if let error = error {
                report(error.localizedDescription, errorCode: (error as NSError).code, isFatal: false, metadata: [#file, #function, #line])
            }
        }
    }
}
