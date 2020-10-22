//
//  CardController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 16/07/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit

//Third-party Frameworks
import Koloda
import SwiftRandom

class CardController: UIViewController, MFMailComposeViewControllerDelegate
{
    //--------------------------------------------------//
    
    /* Interface Builder UI Elements */
    
    //Other Elements
    @IBOutlet weak var kolodaView: KolodaView!
    
    @IBOutlet weak var matchesButton: ShadowButton!
    
    @IBOutlet weak var accountButton: ShadowButton!
    
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    //Other Declarations
    override var prefersStatusBarHidden:            Bool                 { return false }
    override var preferredStatusBarStyle:           UIStatusBarStyle     { return .lightContent }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .slide }
    
    var buildInstance: Build!
    var conversationsToPass: [Conversation]?
    var matchesToPass: [String]?
    var shouldSwipeCard = true
    var userArray: [User]!
    
    //--------------------------------------------------//
    
    /* Initialiser Function */
    
    func initialiseController()
    {
        lastInitialisedController = self
        buildInstance = Build(self)
    }
    
    //--------------------------------------------------//
    
    /* Overridden Functions */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "conversationFromCardSegue"
        {
            let destinationController = segue.destination as! ConversationController
            
            if let matchesIndicator = view.viewWithTag(aTagFor("matchesIndicator"))
            {
                matchesIndicator.removeFromSuperview()
                matchesButton.isHidden = false
            }
            
            destinationController.conversationArray = conversationsToPass
            destinationController.matchIdentifiers = matchesToPass
        }
        else if segue.identifier == "accountFromCardSegue"
        {
            //let destinationController = segue.destination as! AccountController
            
            
        }
    }
    
    func bottomButtonFrame(forButton: UIButton) -> CGRect
    {
        if UIScreen.main.bounds.height == f.screenHeight(.fourInch)
        {
            return CGRect(x: f.x(forButton.frame.origin.x),
                          y: f.y(forButton.frame.origin.y),
                          width: 50,
                          height: 50)
        }
        
        return f.frame(CGRect(x: forButton.frame.origin.x,
                              y: forButton.frame.origin.y,
                              width: 60,
                              height: 60))
    }
    
    @objc func sendFeedbackButtonAction()
    {
        PresentationManager().feedbackController(withFileName: #file)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initialiseController()
        
        view.bringSubviewToFront(kolodaView)
        
        setNeedsStatusBarAppearanceUpdate()
        
        accountButton.tag = aTagFor("accountButton")
        matchesButton.tag = aTagFor("matchesButton")
        
        title = "glaid" //currentUser!.firstName
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: 0x003262)
        self.navigationController?.navigationBar.tintColor = UIColor(hex: 0xFEB516)
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xFEB516), NSAttributedString.Key.font: UIFont(name: "AppleGaramond", size: 40)!]
        
        accountButton.initialiseLayer(animateTouches: true,
                                      backgroundColour: UIColor(hex: 0x265079),
                                      customBorderFrame: bottomButtonFrame(forButton: accountButton),
                                      customCornerRadius: nil,
                                      shadowColour: UIColor(hex: 0x003262).cgColor,
                                      instanceName: "accountButton")
        
        matchesButton.initialiseLayer(animateTouches: true,
                                      backgroundColour: UIColor(hex: 0x265079),
                                      customBorderFrame: bottomButtonFrame(forButton: matchesButton),
                                      customCornerRadius: nil,
                                      shadowColour: UIColor(hex: 0x003262).cgColor,
                                      instanceName: "matchesButton")
        
        let isFourInchScreen = UIScreen.main.bounds.height == f.screenHeight(.fourInch)
        
        let accountImage = UIImage(named: "account.png")?.scaled(with: isFourInchScreen ? 0.05 : 1)
        let chatImage = UIImage(named: "chat.png")?.scaled(with: isFourInchScreen ? 0.07 : 1)
        
        accountButton.setImage(accountImage!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        accountButton.tintColor = UIColor(hex: 0xFEB516)
        
        matchesButton.setImage(chatImage!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        matchesButton.tintColor = UIColor(hex: 0xFEB516)
        
        let aI = UIActivityIndicatorView(frame: f.frame(CGRect(x: 0, y: 0, width: 40, height: 40)))
        aI.center = view.center
        aI.style = .large
        aI.startAnimating()
        aI.hidesWhenStopped = true
        view.addSubview(aI)
        //showProgressHud()
        
        UserSerialiser().getRandomUsers(amountToGet: nil) { (wrappedUserIdentifiers, getRandomUsersErrorDescriptor) in
            if let returnedUserIdentifiers = wrappedUserIdentifiers
            {
                if let getRandomUsersError = getRandomUsersErrorDescriptor
                {
                    report(getRandomUsersError, errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                }
                
                var parsedUserIdentifiers = returnedUserIdentifiers
                if let index = parsedUserIdentifiers.firstIndex(of: currentUser!.associatedIdentifier)
                {
                    parsedUserIdentifiers.remove(at: index)
                }
                
                for individualIdentifier in parsedUserIdentifiers
                {
                    if let swipedRightOn = currentUser!.swipedRightOn,
                        swipedRightOn.contains(individualIdentifier),
                        let index = parsedUserIdentifiers.firstIndex(of: individualIdentifier)
                    {
                        parsedUserIdentifiers.remove(at: index)
                    }
                    
                    if let swipedLeftOn = currentUser!.swipedLeftOn,
                        swipedLeftOn.contains(individualIdentifier),
                        let index = parsedUserIdentifiers.firstIndex(of: individualIdentifier)
                    {
                        parsedUserIdentifiers.remove(at: index)
                    }
                    
                    if let matches = currentUser!.matches,
                        matches.contains(individualIdentifier),
                        let index = parsedUserIdentifiers.firstIndex(of: individualIdentifier)
                    {
                        parsedUserIdentifiers.remove(at: index)
                    }
                }
                
                UserSerialiser().getUsers(withIdentifiers: parsedUserIdentifiers) { (wrappedUsers, getUsersErrors) in
                    if let returnedUsers = wrappedUsers
                    {
                        aI.stopAnimating() //hideHud
                        self.userArray = returnedUsers
                        self.kolodaView.dataSource = self
                        self.kolodaView.delegate = self
                    }
                    else
                    {
                        aI.stopAnimating() //hideHud()
                        //IF MORE THAN 4 OPTIONS, DO IT LIKE THIS:
                        AlertKit().errorAlertController(title: nil,
                                                        message: nil,
                                                        dismissButtonTitle: nil,
                                                        additionalSelectors: nil,
                                                        preferredAdditionalSelector: nil,
                                                        canFileReport: true,
                                                        extraInfo: getUsersErrors!.joined(separator: "\n"),
                                                        metadata: [#file, #function, #line],
                                                        networkDependent: true)
                    }
                }
            }
            else
            {
                aI.stopAnimating() //hideHud()
                
                AlertKit().errorAlertController(title: nil,
                                                message: nil,
                                                dismissButtonTitle: nil,
                                                additionalSelectors: nil,
                                                preferredAdditionalSelector: nil,
                                                canFileReport: true,
                                                extraInfo: getRandomUsersErrorDescriptor!,
                                                metadata: [#file, #function, #line],
                                                networkDependent: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        currentFile = #file
        buildInfoController?.view.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        UIView.transition(with: self.navigationController!.navigationBar, duration: 0.1, options: [.transitionCrossDissolve], animations: {
            self.title = "glaid"
        })
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        title = ""
    }
    
    //--------------------------------------------------//
    
    /* Interface Builder Actions */
    
    @IBAction func matchesButton(_ sender: Any)
    {
        matchesButton.isHidden = true
        
        guard let matchesButtonBorder = view.findSubview(aTagFor("matchesButton_BORDER")) else { report("No «matchesButtonBorder»", errorCode: nil, isFatal: true, metadata: [#file, #function, #line]); return }
        
        let aI = UIActivityIndicatorView(frame: f.frame(CGRect(x: 0, y: 0, width: 40, height: 40)))
        aI.center = matchesButtonBorder.center
        aI.center.y -= 2
        aI.style = .whiteLarge
        aI.tag = aTagFor("matchesIndicator")
        aI.startAnimating()
        aI.hidesWhenStopped = true
        view.addSubview(aI)
        
        UserSerialiser().getUser(withIdentifier: currentUser!.associatedIdentifier) { (wrappedUser, getUserError) in
            
            if let returnedUser = wrappedUser
            {
                currentUser = returnedUser
                
                returnedUser.deSerialiseConversations { (conversations, error) in
                    guard let conversations = conversations else
                    {
                        if let status = error
                        {
                            if status == "No Conversations to deserialise." || status.contains("Null/first message processed.")
                            {
                                if let matches = returnedUser.matches
                                {
                                    self.title = ""
                                    self.matchesToPass = matches
                                    self.conversationsToPass = nil
                                    self.performSegue(withIdentifier: "conversationFromCardSegue", sender: self)
                                }
                                else
                                {
                                    AlertKit().successAlertController(withTitle: "No matches yet!", withMessage: "Try swiping some more. ;)", withCancelButtonTitle: nil, withAlternateSelectors: nil, preferredActionIndex: nil)
                                }
                            }
                            
                            report(error ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                            
                            aI.removeFromSuperview()
                            
                            self.matchesButton.isHidden = false
                        }
                        
                        return
                    }
                    
                    var participantArray: [String] = []
                    
                    for individualConversation in conversations
                    {
                        participantArray.append(contentsOf: individualConversation.participantIdentifiers)
                    }
                    
                    self.matchesToPass = returnedUser.matches == nil ? nil : returnedUser.matches!.filter({!participantArray.contains($0)})
                    
                    self.title = ""
                    self.conversationsToPass = conversations
                    self.performSegue(withIdentifier: "conversationFromCardSegue", sender: self)
                }
            }
            else
            {
                aI.removeFromSuperview()
                self.matchesButton.isHidden = false
                print(getUserError!)
            }
        }
    }
    
    @IBAction func accountButton(_ sender: Any)
    {
        performSegue(withIdentifier: "accountFromCardSegue", sender: self)
    }
    
    @IBAction func sendFeedbackButton(_ sender: Any)
    {
        PresentationManager().feedbackController(withFileName: #file)
    }
    
    //--------------------------------------------------//
    
    /* Independent Functions */
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        buildInstance.handleMailComposition(withController: controller, withResult: result, withError: error)
    }
}

extension CardController: KolodaViewDataSource
{
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int
    {
        return userArray.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed
    {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, shouldDragCardAt index: Int) -> Bool
    {
        return shouldSwipeCard
    }
    
    func kolodaPanFinished(_ koloda: KolodaView, card: DraggableCardView)
    {
        if card.swipedUp == true
        {
            if let cardView = koloda.viewForCard(at: koloda.currentCardIndex) as? CardView
            {
                if cardView.informationButton.alpha != 0
                {
                    cardView.toggleCardPageController(on: true)
                }
            }
        }
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection)
    {
        if direction == .right
        {
            kolodaView.isUserInteractionEnabled = false
            
            UserSerialiser().swipe(.right, on: userArray[index].associatedIdentifier) { (swipeError) in
                guard swipeError != nil else
                {
                    print("swiped right")
                    if let cardPageController = self.view.findSubview(aTagFor("cardPageController"))
                    {
                        cardPageController.removeFromSuperview()
                    }; return
                }
                
                report(swipeError!, errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
            }
            
            if let otherUserSwipedOn = self.userArray[index].swipedRightOn,
                otherUserSwipedOn.contains(currentUser!.associatedIdentifier)
            {
                AlertKit().successAlertController(withTitle: "New Match!", withMessage: "You just matched with \(self.userArray[index].firstName!) \(self.userArray[index].lastName!)!", withCancelButtonTitle: nil, withAlternateSelectors: nil, preferredActionIndex: nil)
                
                report("NEW MATCH!", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                
                DispatchQueue.main.async {
                    var updatedMatches = currentUser!.matches ?? []
                    updatedMatches.append(self.userArray[index].associatedIdentifier)
                    currentUser!.matches = updatedMatches
                    
                    UserSerialiser().updateMatches(for: self.userArray[index].associatedIdentifier, with: currentUser!.associatedIdentifier) { (updateMatchesErrorDescriptor) in
                        if let updateMatchesError = updateMatchesErrorDescriptor
                        {
                            report(updateMatchesError, errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
                        }
                    }
                    
                    self.kolodaView.isUserInteractionEnabled = true
                }
            }
            else
            {
                kolodaView.isUserInteractionEnabled = true
            }
        }
        else if direction == .left
        {
            UserSerialiser().swipe(.left, on: userArray[index].associatedIdentifier) { (swipeError) in
                guard swipeError != nil else
                {
                    print("swiped left")
                    if let cardPageController = self.view.findSubview(aTagFor("cardPageController"))
                    {
                        cardPageController.removeFromSuperview()
                    }; return
                }
                
                report(swipeError!, errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
            }
        }
    }
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection]
    {
        return [.left, .right, .up]
    }
    
    func koloda(_ koloda: KolodaView, shouldSwipeCardAt index: Int, in direction: SwipeResultDirection) -> Bool
    {
        return shouldSwipeCard
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView
    {
        let cardView = Bundle.main.loadNibNamed("CardView", owner: self, options: nil)?[0] as! CardView
        
        let userForDisplay = userArray[index]
        
        //cardView.updateFrame()
        //cardView.nameLabel.updateFrame()
        //cardView.subtitleLabel.updateFrame()
        //cardView.informationButton.updateFrame()
        //cardView.profileImageView.updateFrame()
        
        cardView.nameLabel.text = userForDisplay.firstName /*.uppercased()*/
        
        let intrinsicNameContentWidth = cardView.nameLabel.sizeThatFits(cardView.nameLabel.intrinsicContentSize).width
        let adjustedNameLabelSize = (intrinsicNameContentWidth + cardView.nameLabel.frame.origin.x) + 5
        
        if adjustedNameLabelSize > cardView.informationButton.frame.origin.x
        {
            cardView.nameLabel.frame.size.width = intrinsicNameContentWidth
            cardView.nameLabel.frame.size.width -= (adjustedNameLabelSize - cardView.informationButton.frame.origin.x)
            cardView.nameLabel.updateFrame()
        }
        else
        {
            cardView.nameLabel.frame.size.width = intrinsicNameContentWidth
            cardView.nameLabel.frame.size.width += 5
            cardView.nameLabel.updateFrame()
            
            if UIScreen.main.bounds.height == f.screenHeight(.fourInch) || UIScreen.main.bounds.height == f.screenHeight(.fourSevenInch)
            {
                cardView.nameLabel.font = UIFont(name: "UniversLTStd-Bold", size: 35)
            }
        }
        
        #warning("FOR DEBUG ONLY!")
        cardView.subtitleLabel.text = userForDisplay.userData.bioText
        
        let similarityTuple = currentUser!.similarity(to: userForDisplay)
        
        let similarity = Float(similarityTuple.0) / Float(similarityTuple.1)
        
        let similarityViewFrame = cardView.similarityView.frame
        let progressFrame = CGRect(x: similarityViewFrame.origin.x, y: similarityViewFrame.origin.y, width: similarityViewFrame.width * CGFloat(similarity), height: similarityViewFrame.height)
        
        let percentage = Int((Double(similarity) * 100).rounded())
        
        //print("you and \(userForDisplay.firstName!) are \(percentage)% similar")
        
        let progressView = UIView(frame: progressFrame)
        
        var colourToUse = UIColor(hex: 0x60C129)
        
        if percentage <= 30
        {
            colourToUse = UIColor(hex: 0xE95A53)
        }
        else if percentage <= 60
        {
            colourToUse = UIColor(hex: 0xFF9B2E)
        }
        
        progressView.backgroundColor = colourToUse
        
        let label = UILabel()
        label.text = "\(percentage)% in common"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "SFUIText-Semibold", size: UIScreen.main.bounds.height == f.screenHeight(.fourInch) ? 10 : 14)
        label.frame = CGRect(x: 0, y: f.y(cardView.similarityView.frame.origin.y), width: 150, height: f.height(20))
        
        let intrinsicContentWidth = label.sizeThatFits(label.intrinsicContentSize).width
        label.frame.size.width = intrinsicContentWidth
        
        progressView.tag = aTagFor("progressView")
        
        cardView.addSubview(progressView)
        cardView.bringSubviewToFront(progressView)
        progressView.updateFrame()
        
        if progressView.frame.width <= label.frame.width + 10
        {
            label.center.y = f.y(cardView.similarityView.center.y - 5)
            label.center.x = cardView.similarityView.center.x
            
            while progressView.frame.width >= label.frame.origin.x
            {
                label.frame.origin.x += 1
            }
            
            label.textColor = .black
        }
        else
        {
            label.center.y = progressView.center.y - 5
            label.center.x = progressView.center.x
        }
        
        if UIScreen.main.bounds.height == f.screenHeight(.fourInch) || UIScreen.main.bounds.height == f.screenHeight(.fourSevenInch)
        {
            label.frame.origin.y -= 1
            cardView.subtitleLabel.font = UIFont(name: "SFUIText-Semibold", size: 12)
        }
        
        label.tag = aTagFor("label")
        
        cardView.addSubview(label)
        
        let intrinsicSubtitleContentWidth = cardView.subtitleLabel.sizeThatFits(cardView.subtitleLabel.intrinsicContentSize).width
        let adjustedSubtitleLabelSize = (intrinsicSubtitleContentWidth + cardView.subtitleLabel.frame.origin.x) + 5
        
        if adjustedSubtitleLabelSize > cardView.frame.maxX - 10
        {
            cardView.subtitleLabel.frame.size.width = intrinsicSubtitleContentWidth
            cardView.subtitleLabel.frame.size.width -= (adjustedSubtitleLabelSize - cardView.informationButton.frame.origin.x)
            cardView.subtitleLabel.updateFrame()
        }
        else
        {
            cardView.subtitleLabel.frame.size.width = intrinsicSubtitleContentWidth
            
            cardView.subtitleLabel.frame.origin.x = f.x(cardView.subtitleLabel.frame.origin.x)
            cardView.subtitleLabel.frame.origin.y = f.y(cardView.subtitleLabel.frame.origin.y)
            
            if cardView.subtitleLabel.frame.maxX < cardView.frame.maxX - 5
            {
                cardView.subtitleLabel.frame.size.width += 5
            }
        }
        
        cardView.profileImageView.contentMode = .scaleAspectFill
        
        if let imageDataArray = userForDisplay.userData.profileImageData,
            let imageData = Data(base64Encoded: imageDataArray[0], options: .ignoreUnknownCharacters)
        {
            cardView.profileImageView.image = UIImage(data: imageData)
            cardView.profileImageView.updateFrame()
        }
        else
        {
            let noImageLabel = UILabel(frame: f.frame(CGRect(x: 0, y: 0, width: 150, height: 20)))
            noImageLabel.center = cardView.profileImageView.center
            noImageLabel.font = UIFont(name: "SFUIText-Semibold", size: 20)
            noImageLabel.text = "No Profile Image"
            noImageLabel.textAlignment = .center
            noImageLabel.textColor = .white
            noImageLabel.updateFrame()
            
            cardView.profileImageView.addSubview(noImageLabel)
            cardView.profileImageView.bringSubviewToFront(noImageLabel)
        }
        
        let expandedCardStoryboard = UIStoryboard(name: "ExpandedCard", bundle: nil)
        
        cardView.quickFactsView = (Bundle.main.loadNibNamed("QuickFactsView", owner: self, options: nil)?[0] as! QuickFactsView)
        
        cardView.cardPageController = expandedCardStoryboard.instantiateInitialViewController() as? CardPageController
        
        if let cardPageController = cardView.cardPageController
        {
            cardPageController.user = userForDisplay
            cardView.user = userForDisplay
        }
        else
        {
            report("No «cardPageController»!",
                   errorCode: nil,
                   isFatal: true,
                   metadata: [#file, #function, #line])
        }
        
        cardView.informationButton.initialiseLayer(animateTouches: true,
                                                   backgroundColour: cardView.informationButton.backgroundColor!,
                                                   customBorderFrame: nil,
                                                   customCornerRadius: cardView.informationButton.frame.size.width / 2,
                                                   shadowColour: UIColor.clear.cgColor,
                                                   instanceName: nil)
        
        if UIScreen.main.bounds.height == f.screenHeight(.fourInch)
        {
            cardView.informationButton.frame.origin.x = f.x(cardView.informationButton.frame.origin.x)
        }
        
        ancillaryRound(forViews: [cardView.nameLabel, cardView.subtitleLabel])
        
        cardView.tag = index
        
        return cardView
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView?
    {
        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
}

extension CardController: KolodaViewDelegate
{
    func kolodaDidRunOutOfCards(_ koloda: KolodaView)
    {
        koloda.reloadData()
    }
    
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat?
    {
        return 0.43
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int)
    {
        //UIApplication.shared.openURL(URL(string: "https://yalantis.com/")!)
    }
}

extension UIView
{
    func updateFrame()
    {
        frame = f.frame(frame)
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}

extension UIImage
{
    func scaled(with scale: CGFloat) -> UIImage?
    {
        // size has to be integer, otherwise it could get white lines
        let size = CGSize(width: floor(self.size.width * scale), height: floor(self.size.height * scale))
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
