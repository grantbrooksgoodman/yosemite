//
//  ConversationController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 24/07/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit

import MessageKit
import FirebaseDatabase

class ConversationController: UIViewController, MFMailComposeViewControllerDelegate
{
    //--------------------------------------------------//
    
    //Interface Builder User Interface Elements
    
    //UILabels
    @IBOutlet weak var codeNameLabel:   UILabel!
    @IBOutlet weak var preReleaseLabel: UILabel!
    
    //Other Elements
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var logoTypeImageView: UIImageView!
    @IBOutlet weak var sendFeedbackButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //--------------------------------------------------//
    
    //Class-level Declarations
    
    //Arrays
    var conversationArray: [Conversation]?
    var matchArray:        [User]?
    
    var buildInstance: Build!
    var selectedIndex = 0
    var newConversation: Conversation?
    var matchIdentifiers: [String]?
    var matchesUpdated = false
    
    var dateLabelUpdateTimer: Timer?
    
    //--------------------------------------------------//
    
    //Prerequisite Initialisation Function
    
    func initialiseController()
    {
        lastInitialisedController = self
        
        buildInstance = Build(withType: .genericController, instanceArray: [codeNameLabel!, logoTypeImageView!, preReleaseLabel!, sendFeedbackButton!, self])
    }
    
    //--------------------------------------------------//
    
    //Override Functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        dateLabelUpdateTimer = nil
        
        if segue.identifier == "messagesFromConversationSegue"
        {
            let destinationController = segue.destination as! MessagesController
            
            let isNewConversation = (newConversation != nil)
            
            destinationController.messageArray = isNewConversation ? [] : conversationArray![selectedIndex].associatedMessages
            destinationController.otherUser = isNewConversation ? matchArray![selectedIndex] : conversationArray![selectedIndex].otherUser
            destinationController.conversationIdentifier = isNewConversation ? newConversation!.associatedIdentifier : conversationArray![selectedIndex].associatedIdentifier
            destinationController.newConversation = newConversation
        }
    }
    
    func setUpMatchView()
    {
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        
        print("\n\n\(currentUser!.associatedIdentifier!)\n\n")
        
        if let matches = matchIdentifiers,
            matches.count > 0
        {
            UserSerialiser().getUsers(withIdentifiers: matches) { (wrappedUsers, wrappedErrorDescriptors) in
                if let returnedUsers = wrappedUsers
                {
                    self.matchArray = returnedUsers
                    
                    self.chatTableView.frame.origin.y = (self.view.findSubview(aTagFor("messagesLabel")) as! UILabel).frame.maxY + 5
                    self.chatTableView.frame.size.height = UIScreen.main.bounds.height - (topBarHeight + self.collectionView.frame.height)
                    
                    //                    for cell in self.collectionView.visibleCells
                    //                    {
                    self.view.removeSubview(aTagFor("blurEffectView"), animated: false)
                    //}
                    
                    self.collectionView.dataSource = self
                    self.collectionView.delegate = self
                    self.collectionView.reloadData()
                    //                    self.collectionView.reloadInputViews()
                    //                    self.collectionView.setNeedsLayout()
                    //                    self.collectionView.setNeedsDisplay()
                    
                    UIView.animate(withDuration: 0.15) {
                        self.collectionView.alpha = 1
                    }
                }
                else
                {
                    UIView.animate(withDuration: 0.15) {
                        self.collectionView.alpha = 1
                    }
                    
                    guard let errorDescriptors = wrappedErrorDescriptors else
                    {
                        report("An unknown error occurred.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return
                    }
                    
                    report(errorDescriptors.joined(separator: "\n"), errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                }
            }
        }
        else
        {
            scrollView.alpha = 0
            chatTableView.frame.size.height = UIScreen.main.bounds.height - topBarHeight
            chatTableView.frame.origin.y = topBarHeight
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard let conversations = conversationArray else
        {
            report("No Conversations to load.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return
        }
        
        ConversationSerialiser().setOtherUsers(for: conversations) { (setOtherUsersError) in
            if let setOtherUsersError = setOtherUsersError
            {
                report(setOtherUsersError, errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
            }
            else
            {
                self.chatTableView.dataSource = self
                self.chatTableView.delegate = self
                self.chatTableView.reloadData()
            }
        }
        
        for individualConversation in conversations
        {
            Database.database().reference().child("allConversations").child(individualConversation.associatedIdentifier).observe(.childChanged) { (returnedSnapshot) in
                if returnedSnapshot.key == "lastModified"
                {
                    if let lastModified = returnedSnapshot.value as? String,
                        let lastModifiedDate = secondaryDateFormatter.date(from: lastModified)
                    {
                        individualConversation.lastModifiedDate = lastModifiedDate
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        initialiseController()
        
        collectionView.alpha = matchesUpdated ? 0 : 1
        matchesUpdated = false
        
        setUpMatchView()
        
        DispatchQueue.main.async {
            if let conversationArray = self.conversationArray
            {
                self.conversationArray = conversationArray.sorted(by: {$0.lastModifiedDate > $1.lastModifiedDate})
                
                let notSetConversations = self.conversationArray!.filter({$0.otherUser == nil})
                
                if notSetConversations.count > 0
                {
                    ConversationSerialiser().setOtherUsers(for: self.conversationArray!.filter({$0.otherUser == nil})) { (setOtherUsersError) in
                        if let setOtherUsersError = setOtherUsersError
                        {
                            report(setOtherUsersError, errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
                        }
                        else
                        {
                            self.chatTableView.dataSource = self
                            self.chatTableView.delegate = self
                            self.chatTableView.reloadData()
                        }
                    }
                }
                else
                {
                    self.chatTableView.dataSource = self
                    self.chatTableView.delegate = self
                    self.chatTableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        UIView.transition(with: self.navigationController!.navigationBar, duration: 0.1, options: [.transitionCrossDissolve], animations: {
            self.title = "Matches"
        })
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        Database.database().reference().child("allConversations").removeAllObservers()
    }
    
    //--------------------------------------------------//
    
    //Interface Builder Actions
    
    @IBAction func sendFeedbackButton(_ sender: Any)
    {
        PresentationManager().feedbackController(withFileName: #file)
    }
    
    //--------------------------------------------------//
    
    //Independent Functions
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        buildInstance.handleMailComposition(withController: controller, withResult: result, withError: error)
    }
    
    @objc func goBack()
    {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func updateDateLabels()
    {
        let visibleCells = chatTableView.visibleCells as Array<UITableViewCell>
        
        for individualCell in visibleCells
        {
            if let chatCell = individualCell as? ChatCell
            {
                if let conversationForCell = conversationArray!.first(where: { aTagFor($0.associatedIdentifier) == chatCell.tag })
                {
                    chatCell.dateLabel.text = conversationForCell.lastModifiedDate.getElapsedInterval()
                }
            }
        }
    }
}

extension ConversationController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        guard let otherUser = self.conversationArray![indexPath.row].otherUser else { report("No «otherUser».", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return nil }
        
        let contextItem = UIContextualAction(style: .destructive, title: "Unmatch") {  (contextualAction, view, completion) in
            AlertKit().confirmationAlertController(title: "Are you sure?",
                                                   message: "Would you really like to unmatch with \(otherUser.firstName!)?",
                cancelConfirmTitles: ["confirm": "Unmatch"],
                confirmationDestructive: true,
                confirmationPreferred: false,
                networkDepedent: true) { (wrappedDidConfirm) in
                    if let didConfirm = wrappedDidConfirm
                    {
                        if didConfirm
                        {
                            let selectedConversation = self.conversationArray![indexPath.row]
                            
                            self.conversationArray!.remove(at: indexPath.row)
                            completion(true)
                            tableView.isUserInteractionEnabled = false
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                                tableView.reloadData()
                                tableView.isUserInteractionEnabled = true
                            }
                            
                            ConversationSerialiser().deleteConversation(selectedConversation) { (wrappedErrorDescriptor) in
                                if let deleteConversationError = wrappedErrorDescriptor
                                {
                                    self.conversationArray!.insert(selectedConversation, at: indexPath.row)
                                    completion(true)
                                    tableView.isUserInteractionEnabled = false
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                                        tableView.reloadData()
                                        tableView.isUserInteractionEnabled = true
                                    }
                                    
                                    AlertKit().errorAlertController(title: nil,
                                                                    message: "The conversation could not be deleted.",
                                                                    dismissButtonTitle: nil,
                                                                    additionalSelectors: nil,
                                                                    preferredAdditionalSelector: nil,
                                                                    canFileReport: true,
                                                                    extraInfo: nil,
                                                                    metadata: [#file, #function, #line],
                                                                    networkDependent: true)
                                    
                                    report(deleteConversationError, errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                                }
                                else
                                {
                                    UserSerialiser().removeMatch(between: currentUser!.associatedIdentifier, and: otherUser.associatedIdentifier) { (removeMatchError) in
                                        if let removeMatchError = removeMatchError
                                        {
                                            report(removeMatchError, errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                                        }
                                        else
                                        {
                                            print("Match removed successfully.")
                                        }
                                    }
                                }
                            }
                        }
                    }
            }
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let currentCell = tableView.dequeueReusableCell(withIdentifier: "currentCell") as! ChatCell
        
        if dateLabelUpdateTimer == nil
        {
            dateLabelUpdateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ConversationController.updateDateLabels), userInfo: nil, repeats: true)
        }
        
        Database.database().reference().child("allConversations").child(conversationArray![indexPath.row].associatedIdentifier).child("associatedMessages").observe(.childAdded, with: { (returnedSnapshot) in
            if let newMessageIdentifier = returnedSnapshot.value as? String
            {
                var doIt = true
                
                if self.conversationArray!.count <= indexPath.row
                {
                    #warning("Fix this bug which occurs upon deletion of a conversation followed by sending a message in the last one.")
                    //                    AlertKit().errorAlertController(title: nil,
                    //                                                    message: "Unable to send message.",
                    //                                                    dismissButtonTitle: nil,
                    //                                                    additionalSelectors: nil,
                    //                                                    preferredAdditionalSelector: nil,
                    //                                                    canFileReport: true,
                    //                                                    extraInfo: "IndexPath row was greater than array count.",
                    //                                                    metadata: [#file, #function, #line],
                    //                                                    networkDependent: false)
                    
                    report("IndexPath row was greater than array count.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                }
                else
                {
                    for individualMessage in self.conversationArray![indexPath.row].associatedMessages
                    {
                        if individualMessage.associatedIdentifier == newMessageIdentifier
                        {
                            doIt = false
                        }
                    }
                    
                    if doIt
                    {
                        MessageSerialiser().getMessage(withIdentifier: newMessageIdentifier) { (wrappedMessage, getMessageError) in
                            if let returnedMessage = wrappedMessage
                            {
                                if !self.conversationArray![indexPath.row].associatedMessages.contains(where: {$0.associatedIdentifier == returnedMessage.associatedIdentifier})
                                {
                                    self.conversationArray![indexPath.row].associatedMessages.append(returnedMessage)
                                    tableView.reloadRows(at: [indexPath], with: .automatic)
                                }
                                else
                                {
                                    report("Tried to add a duplicate message! How daft.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                                }
                            }
                            else
                            {
                                report(getMessageError ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                            }
                        }
                    }
                }
            }
        })
        
        guard let otherUser = self.conversationArray![indexPath.row].otherUser else { report("No «otherUser».", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return UITableViewCell() }
        
        currentCell.nameLabel.text = otherUser.firstName!
        
        let intrinsicContentWidth = currentCell.nameLabel.sizeThatFits(currentCell.nameLabel.intrinsicContentSize).width
        currentCell.nameLabel.frame.size.width = intrinsicContentWidth
        
        currentCell.previewLabel.text = conversationArray![indexPath.row].associatedMessages.last!.messageContent!
        
        currentCell.dateLabel.text = conversationArray![indexPath.row].lastModifiedDate.getElapsedInterval()
        
        if currentCell.previewLabel.text!.count < 45
        {
            currentCell.previewLabel.numberOfLines = 1
        }
        else
        {
            currentCell.previewLabel.numberOfLines = 2
        }
        
        currentCell.previewLabel.sizeToFit()
        
        if let imageDataString = otherUser.userData.avatarImageData,
            let imageData = Data(base64Encoded: imageDataString, options: .ignoreUnknownCharacters)
        {
            currentCell.profileImageView.image = UIImage(data: imageData)
            currentCell.profileImageView.layer.cornerRadius = currentCell.profileImageView.frame.size.width / 2
            currentCell.profileImageView.layer.masksToBounds = false
            currentCell.profileImageView.clipsToBounds = true
        }
        else
        {
            currentCell.avatarView.set(avatar: Avatar(image: nil, initials: "\(otherUser.firstName.stringCharacters[0].uppercased())"))
        }
        
        currentCell.unreadView.isHidden = conversationArray![indexPath.row].associatedMessages.filter({$0.fromAccountIdentifier != accountIdentifier}).count == 0 ? true : (conversationArray![indexPath.row].associatedMessages.filter({$0.fromAccountIdentifier != accountIdentifier}).last?.readDate != nil)
        currentCell.unreadView.layer.cornerRadius = 5
        currentCell.unreadView.clipsToBounds = true
        
        let interval = Calendar.current.dateComponents([.hour, .minute], from: otherUser.userData.lastActiveDate, to: Date())
        
        if let hoursPassed = interval.minute //interval.hour
        {
            currentCell.recentlyActiveView.alpha = hoursPassed > 10 /*3*/ ? 0 : 1
            currentCell.recentlyActiveView.layer.cornerRadius = 5
            currentCell.recentlyActiveView.clipsToBounds = true
            currentCell.recentlyActiveView.frame.origin.x = currentCell.nameLabel.frame.maxX + 8
        }
        
        currentCell.tag = aTagFor(conversationArray![indexPath.row].associatedIdentifier)
        
        return currentCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let lastMessage = conversationArray![indexPath.row].associatedMessages.filter({$0.fromAccountIdentifier != accountIdentifier}).last
        {
            if lastMessage.readDate == nil
            {
                lastMessage.readDate = Date(timeIntervalSince1970: 0)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath.row
        title = ""
        performSegue(withIdentifier: "messagesFromConversationSegue", sender: self)
        
        Database.database().reference().child("allConversations").removeAllObservers()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return conversationArray!.count
    }
}

extension ConversationController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return matchArray!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if let currentCell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
        {
            //currentCell.imageView.image = UIImage(color: .white)
            
            currentCell.imageView.alpha = 0
            
            if let cellSuperview = currentCell.imageView.superview?.superview
            {
                let centrePoint = cellSuperview.convert(currentCell.imageView.center, to: view)
                
                let activityIndicator = UIActivityIndicatorView()
                activityIndicator.center = centrePoint
                activityIndicator.color = .gray
                activityIndicator.style = .large
                activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                activityIndicator.tag = aTagFor("activityIndicator")
                
                activityIndicator.startAnimating()
                
                view.addSubview(activityIndicator)
            }
            
            ConversationSerialiser().createConversation(initialMessageIdentifier: "!", participantIdentifiers: [currentUser!.associatedIdentifier, matchArray![indexPath.row].associatedIdentifier]) { (wrappedIdentifier, createConversationError) in
                if let returnedIdentifier = wrappedIdentifier
                {
                    let newConversation = Conversation(associatedIdentifier: returnedIdentifier, associatedMessages: [], lastModifiedDate: Date(), participantIdentifiers: [currentUser!.associatedIdentifier, self.matchArray![indexPath.row].associatedIdentifier])
                    newConversation.otherUser = self.matchArray![indexPath.row]
                    
                    if self.matchArray![indexPath.row].openConversations != nil
                    {
                        self.matchArray![indexPath.row].openConversations!.append(returnedIdentifier)
                    }
                    else
                    {
                        self.matchArray![indexPath.row].openConversations = [returnedIdentifier]
                    }
                    
                    self.newConversation = newConversation
                    self.selectedIndex = indexPath.row
                    self.title = ""
                    
                    currentCell.imageView.alpha = 1
                    self.view.removeSubview(aTagFor("activityIndicator"), animated: false)
                    
                    self.performSegue(withIdentifier: "messagesFromConversationSegue", sender: self)
                }
                else
                {
                    report(createConversationError ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        if let imageDataString = matchArray![indexPath.row].userData.avatarImageData,
            let imageData = Data(base64Encoded: imageDataString, options: .ignoreUnknownCharacters)
        {
            cell.imageView.image = UIImage(data: imageData)
        }
        
        cell.nameLabel.text = matchArray![indexPath.row].firstName!
        
        return cell
    }
}
