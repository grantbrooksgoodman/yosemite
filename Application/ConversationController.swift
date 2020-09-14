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
    
    /* Interface Builder UI Elements */
    
    //Other Elements
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var matchCollectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sendFeedbackButton: UIButton!
    
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    //Arrays
    var conversationArray: [Conversation]?
    var matchArray:        [User]?
    var matchIdentifiers:  [String]?
    
    //Other Declarations
    var buildInstance: Build!
    var dateLabelUpdateTimer: Timer?
    var matchesUpdated = false
    var newConversation: Conversation?
    var selectedIndex = 0
    
    //--------------------------------------------------//
    
    /* Initialiser Function */
    
    func initialiseController()
    {
        lastInitialisedController = self
        buildInstance = Build(self)
        currentFile = #file
    }
    
    //--------------------------------------------------//
    
    /* Overridden Functions */
    
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
            (navigationController?.navigationBar.frame.height ?? 0.0)
        
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        
        if let matches = matchIdentifiers,
            matches.count > 0 //If we have matches to process.
        {
            //Get all the Users in the «matches» array.
            UserSerialiser().getUsers(withIdentifiers: matches) { (wrappedUsers, wrappedErrorDescriptors) in
                if let returnedUsers = wrappedUsers //If we got the Users successfully.
                {
                    //Set the global «matchArray» to the array of returned Users.
                    self.matchArray = returnedUsers
                    
                    //Adjust the height of the «chatTableView» to account for the match view.
                    self.chatTableView.frame.origin.y = (self.view.findSubview(aTagFor("messagesLabel")) as! UILabel).frame.maxY + 5
                    self.chatTableView.frame.size.height = UIScreen.main.bounds.height - (topBarHeight + self.matchCollectionView.frame.height)
                    
                    //Set the «dataSource» and «delegate» of the «collectionView».
                    self.matchCollectionView.dataSource = self
                    self.matchCollectionView.delegate = self
                    
                    //Tell «collectionView» to layout its cells.
                    self.matchCollectionView.reloadData()
                    
                    //Animate the appearance of «collectionView».
                    UIView.animate(withDuration: 0.15) {
                        self.matchCollectionView.alpha = 1
                    }
                }
                else //If the call to «getUsers» returned an error.
                {
                    //Unwrap the error descriptor array.
                    guard let errorDescriptors = wrappedErrorDescriptors else
                    { //No error descriptors.
                        report("An unknown error occurred.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return
                    }
                    
                    //Report the errors in the array by concatenating its elements into a string.
                    report(errorDescriptors.joined(separator: "\n"), errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                }
            }
        }
        else //If we don't have matches to process.
        {
            //Hide the «scrollView».
            scrollView.alpha = 0
            
            //Set the «chatTableView's» frame accordingly.
            chatTableView.frame.size.height = UIScreen.main.bounds.height - topBarHeight
            chatTableView.frame.origin.y = topBarHeight
        }
        
        //scrollView.updateFrame()
        //matchCollectionView.updateFrame()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initialiseController()
        
        //Check to see if the user has any open Conversations.
        guard let conversations = conversationArray else
        { //No conversations.
            report("No Conversations to load.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return
        }
        
        //Set the «otherUser» variable on each of the Conversations.
        ConversationSerialiser().setOtherUsers(for: conversations) { (setOtherUsersError) in
            if let setOtherUsersError = setOtherUsersError
            {
                report(setOtherUsersError, errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
            }
            else
            { //Successfully set the other Users.
                
                //Set the «dataSource» and «delegate» of «chatTableView».
                self.chatTableView.dataSource = self
                self.chatTableView.delegate = self
                
                //Tell «chatTableView» to layout its cells.
                self.chatTableView.reloadData()
            }
        }
        
        //Go through each Conversation.
        for individualConversation in conversations
        {
            /*
             Monitor changes to the «lastModified» variable of each serialised Conversation.
             If it can be converted into a date, update its correspondoing deserialised instance's «lastModifiedDate» variable.
             */
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
        super.viewWillAppear(animated)
        
        buildInfoController?.view.isHidden = false
        
        matchCollectionView.alpha = matchesUpdated ? 0 : 1
        matchesUpdated = false
        
        setUpMatchView()
        
        DispatchQueue.main.async {
            if let conversationArray = self.conversationArray
            {
                self.conversationArray = conversationArray.sorted(by: {$0.lastModifiedDate > $1.lastModifiedDate})
                
                let notSetConversations = self.conversationArray!.filter({$0.otherUser == nil})
                
                if notSetConversations.count > 0 //If there are Conversations that don't have their «otherUser» set yet.
                {
                    AlertKit().errorAlertController(title: "", message: "There are conversations that haven't been set.", dismissButtonTitle: "OK", additionalSelectors: nil, preferredAdditionalSelector: nil, canFileReport: true, extraInfo: nil, metadata: [#file, #function, #line], networkDependent: false)
                    
                    //Set the «otherUser» variable on each of the Conversations.
                    ConversationSerialiser().setOtherUsers(for: self.conversationArray!.filter({$0.otherUser == nil})) { (setOtherUsersError) in
                        if let setOtherUsersError = setOtherUsersError
                        {
                            report(setOtherUsersError, errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
                        }
                        else
                        { //Successfully set the other Users.
                            
                            //Set the «dataSource» and «delegate» of «chatTableView».
                            self.chatTableView.dataSource = self
                            self.chatTableView.delegate = self
                            
                            //Tell «chatTableView» to layout its cells.
                            self.chatTableView.reloadData()
                        }
                    }
                }
                else //All Conversations have their «otherUser» variables set.
                {
                    //Set the «dataSource» and «delegate» of «chatTableView».
                    self.chatTableView.dataSource = self
                    self.chatTableView.delegate = self
                    
                    //Tell «chatTableView» to layout its cells.
                    self.chatTableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        //Animate the appearance of the navigation controller's title.
        UIView.transition(with: self.navigationController!.navigationBar, duration: 0.1, options: [.transitionCrossDissolve], animations: {
            self.title = "Matches"
        })
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        //Remove all observers set on the «allConversations» key on the server.
        Database.database().reference().child("allConversations").removeAllObservers()
    }
    
    //--------------------------------------------------//
    
    /* Interface Builder Actions */
    
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
    
    func setVisualElements(of cell: ChatCell, with data: Conversation) -> ChatCell?
    {
        //Unwrap the «otherUser» of the Conversation.
        guard let otherUser = data.otherUser else { return nil }
        
        //Set the «nameLabel's» text to the first name of the other User.
        cell.nameLabel.text = otherUser.firstName!
        
        //Calculate the intrinsic content width of the cell's «nameLabel» and set it accordingly.
        let intrinsicContentWidth = cell.nameLabel.sizeThatFits(cell.nameLabel.intrinsicContentSize).width
        cell.nameLabel.frame.size.width = intrinsicContentWidth
        
        //Set the «previewLabel's» text to the last Message's content.
        cell.previewLabel.text = data.associatedMessages.last!.messageContent!
        
        if cell.previewLabel.text!.count < 45 //If the «previewLabel's» text can fit on one line.
        {
            //Set the «previewLabel's» «numberOfLines» to 1.
            cell.previewLabel.numberOfLines = 1
        }
        else
        { //If the «previewLabel's» text needs more than 1 line to fit.
            
            //Set the «previewLabel's» «numberOfLines» to 2.
            cell.previewLabel.numberOfLines = 2
        }
        
        //Size the «previewLabel» to fit its intrinsic content size.
        cell.previewLabel.sizeToFit()
        
        //If the User has an avatar image and it can be converted to data.
        if let imageDataString = otherUser.userData.avatarImageData,
            let imageData = Data(base64Encoded: imageDataString, options: .ignoreUnknownCharacters)
        {
            //Set «profileImageView's» image to the User's avatar and make its frame into a circle.
            cell.profileImageView.image = UIImage(data: imageData)
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 2
            cell.profileImageView.layer.masksToBounds = false
            cell.profileImageView.clipsToBounds = true
        }
        else
        { //If the User does not have an avatar image, or it couldn't be converted to data.
            
            //Set the «avatarView» to a generated Avatar using the User's first name.
            cell.avatarView.set(avatar: Avatar(image: nil, initials: "\(otherUser.firstName.stringCharacters[0].uppercased())"))
        }
        
        //Show or hide the «unreadView» based on whether or not there is an unread Message sent by the other User.
        cell.unreadView.isHidden = data.associatedMessages.filter({$0.fromAccountIdentifier != accountIdentifier}).count == 0 ? true : (data.associatedMessages.filter({$0.fromAccountIdentifier != accountIdentifier}).last?.readDate != nil)
        
        //Make the «unreadView's» frame into a circle.
        cell.unreadView.layer.cornerRadius = 5
        cell.unreadView.clipsToBounds = true
        
        //Get the amount of hours from the date that the other User was last active.
        let interval = Calendar.current.dateComponents([.hour, .minute], from: otherUser.userData.lastActiveDate, to: Date())
        
        //Unwrap the hours passed.
        if let hoursPassed = interval.minute //interval.hour
        {
            //Show or hide the «recentlyActiveView» based on whether or not the User has beeen active in the last 3 hours.
            cell.recentlyActiveView.alpha = hoursPassed > 10 /*3*/ ? 0 : 1
            
            //Make the «recentlyActiveView's» frame into a circle.
            cell.recentlyActiveView.layer.cornerRadius = 5
            cell.recentlyActiveView.clipsToBounds = true
            cell.recentlyActiveView.frame.origin.x = cell.nameLabel.frame.maxX + 8
        }
        
        //Set the cell's tag to the identifier of the Conversation.
        cell.tag = aTagFor(data.associatedIdentifier)
        
        return cell
    }
    
    ///Updates each visble table view cell's `dateLabel` to the current elapsed time since the last **Message** was sent.
    @objc func updateDateLabels()
    {
        let visibleCells = chatTableView.visibleCells as Array<UITableViewCell>
        
        //Iterate through each visible cell.
        for individualCell in visibleCells
        {
            //If the cell can be converted to a «ChatCell» and its tag matches a Conversation in the array.
            if let chatCell = individualCell as? ChatCell,
                let conversationForCell = conversationArray!.first(where: { aTagFor($0.associatedIdentifier) == chatCell.tag })
            {
                //Update the text of the cell's «dateLabel» to the elapsed time since the conversation was last modified.
                chatCell.dateLabel.text = conversationForCell.lastModifiedDate.getElapsedInterval()
            }
        }
    }
}

extension ConversationController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        //Unwrap the selected Conversation's «otherUser».
        guard let otherUser = self.conversationArray![indexPath.row].otherUser else { report("No «otherUser».", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return nil }
        
        //Generate a destructive context action for the "Unmatch" option.
        let contextItem = UIContextualAction(style: .destructive, title: "Unmatch") {  (contextualAction, view, completion) in
            
            //Present a confirmation alert controller.
            AlertKit().confirmationAlertController(title: "Are you sure?",
                                                   message: "Would you really like to unmatch with \(otherUser.firstName!)?",
                cancelConfirmTitles: ["confirm": "Unmatch"],
                confirmationDestructive: true,
                confirmationPreferred: false,
                networkDepedent: true) { (wrappedDidConfirm) in
                    if let didConfirm = wrappedDidConfirm,
                        didConfirm //If the user confirmed that they would like to unmatch with this User.
                    {
                        //Store the currently selected Conversation in case we mess its deletion up.
                        let selectedConversation = self.conversationArray![indexPath.row]
                        
                        //Remove the Conversation from the array.
                        self.conversationArray!.remove(at: indexPath.row)
                        
                        //Dismiss the contextual action and disable interaction with the table view.
                        completion(true)
                        tableView.isUserInteractionEnabled = false
                        
                        /*
                         After dismissing the contextual action, reload the table view.
                         Then enable interaction with the table view again.
                         */
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                            tableView.reloadData()
                            tableView.isUserInteractionEnabled = true
                        }
                        
                        //Delete the selected Conversation on the server.
                        ConversationSerialiser().deleteConversation(selectedConversation) { (wrappedErrorDescriptor) in
                            if let deleteConversationError = wrappedErrorDescriptor //If the Conversation couldn't be deleted.
                            {
                                //Re-insert the selected Conversation into the table view.
                                self.conversationArray!.insert(selectedConversation, at: indexPath.row)
                                
                                //Dismiss the contextual action and disable interaction with the table view.
                                completion(true)
                                tableView.isUserInteractionEnabled = false
                                
                                /*
                                 After dismissing the contextual action, reload the table view.
                                 Then enable interaction with the table view again.
                                 */
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                                    tableView.reloadData()
                                    tableView.isUserInteractionEnabled = true
                                }
                                
                                //Present an error alert controller informing the user that the Conversation couldn't be deleted.
                                AlertKit().errorAlertController(title: nil,
                                                                message: "The conversation could not be deleted.",
                                                                dismissButtonTitle: nil,
                                                                additionalSelectors: nil,
                                                                preferredAdditionalSelector: nil,
                                                                canFileReport: true,
                                                                extraInfo: nil,
                                                                metadata: [#file, #function, #line],
                                                                networkDependent: true)
                                
                                //Report the error.
                                report(deleteConversationError, errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                            }
                            else //If the Conversation was deleted successfully.
                            {
                                //Remove the match between these Users on the server.
                                UserSerialiser().removeMatch(between: currentUser!.associatedIdentifier, and: otherUser.associatedIdentifier) { (removeMatchError) in
                                    if let removeMatchError = removeMatchError //If the match couldn't be removed.
                                    {
                                        //Report the error.
                                        report(removeMatchError, errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                                    }
                                    else //The match was removed successfully. Done!
                                    {
                                        print("Match removed successfully.")
                                    }
                                }
                            }
                        }
                    }
            }
        }
        
        //Add the unmatch context item to a UISwipeActionsConfiguration.
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //Instantiate a «ChatCell».
        let currentCell = tableView.dequeueReusableCell(withIdentifier: "currentCell") as! ChatCell
        
        //If the «dateLabelUpdateTimer» has not been set up.
        if dateLabelUpdateTimer == nil
        {
            //Set up the «dateLabelUpdateTimer» to fire every 60 seconds.
            updateDateLabels()
            dateLabelUpdateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(ConversationController.updateDateLabels), userInfo: nil, repeats: true)
        }
        
        //Monitor all additions to the «associatedMessages» key on the server.
        Database.database().reference().child("allConversations").child(conversationArray![indexPath.row].associatedIdentifier).child("associatedMessages").observe(.childAdded, with: { (returnedSnapshot) in
            if let newMessageIdentifier = returnedSnapshot.value as? String //If the Message's identifier could be unwrapped.
            {
                //Begin by assuming we should add this Message to the table view, i.e. it is a new Message.
                var shouldAddMessage = true
                
                if self.conversationArray!.count <= indexPath.row
                {
                    #warning("Fix this bug which occurs upon deletion of a conversation followed by sending a message in the last one.")
                    
                    report("IndexPath row was greater than array count.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                }
                else //If all seems normal.
                {
                    //Iterate through the Messages in each Conversation.
                    for individualMessage in self.conversationArray![indexPath.row].associatedMessages
                    {
                        //If any Message's identifier matches the one we are trying to add, set «shouldAddMessage» to false.
                        if individualMessage.associatedIdentifier == newMessageIdentifier
                        {
                            shouldAddMessage = false
                        }
                    }
                    
                    //If the Message is actually a new one.
                    if shouldAddMessage
                    {
                        //Get and deserialise the Message.
                        MessageSerialiser().getMessage(withIdentifier: newMessageIdentifier) { (wrappedMessage, getMessageError) in
                            if let returnedMessage = wrappedMessage //If we successfully got the new Message.
                            {
                                //If the «conversationArray» doesn't already contain this Message.
                                if !self.conversationArray![indexPath.row].associatedMessages.contains(where: {$0.associatedIdentifier == returnedMessage.associatedIdentifier})
                                {
                                    //Add the Message to the Conversation and reload the row in the table view to display it.
                                    self.conversationArray![indexPath.row].associatedMessages.append(returnedMessage)
                                    tableView.reloadRows(at: [indexPath], with: .automatic)
                                }
                                else //The «conversationArray» alread contained this Message.
                                {
                                    report("Tried to add a duplicate message! How daft.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                                }
                            }
                            else //If we couldn't get the new Message.
                            {
                                //Report the error if it can be unwrapped.
                                report(getMessageError ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                            }
                        }
                    }
                }
            }
        })
        
        //Unwrap and return a visually set-up «ChatCell».
        if let instantiatedCell = setVisualElements(of: currentCell, with: conversationArray![indexPath.row])
        {
            return instantiatedCell
        }
        else
        { //No «ChatCell» was returned, i.e. there was no «otherUser».
            
            //Report the error.
            report("No «otherUser»!", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
            
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //Unwrap the last Message sent in the selected Conversation.
        if let lastMessage = conversationArray![indexPath.row].associatedMessages.filter({$0.fromAccountIdentifier != accountIdentifier}).last
        {
            //If the last Message's «readDate» hasn't been set yet.
            if lastMessage.readDate == nil
            {
                //Set the Message's «readDate».
                lastMessage.readDate = Date(timeIntervalSince1970: 0)
            }
        }
        
        //Visually deselect the current row.
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Set the global «selectedIndex» variable to the currently selected cell's index path.
        selectedIndex = indexPath.row
        
        //Blank the title of the navigation controller.
        title = ""
        
        //Segue to «MessagesController».
        performSegue(withIdentifier: "messagesFromConversationSegue", sender: self)
        
        //Remove all observers set on the «allConversations» key on the server.
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
        //Unwrap the current cell as a «MatchCell».
        if let currentCell = collectionView.cellForItem(at: indexPath) as? MatchCell
        {
            //Hide the current cell's «imageView».
            currentCell.imageView.alpha = 0
            
            //Unwrap the cell's superview's superview.
            if let cellSuperview = currentCell.imageView.superview?.superview
            {
                //Calculate the centre point of the cell's «imageView».
                let centrePoint = cellSuperview.convert(currentCell.imageView.center, to: view)
                
                //Instantiate an enlarged activity indicator.
                let activityIndicator = UIActivityIndicatorView()
                activityIndicator.center = centrePoint
                activityIndicator.color = .gray
                activityIndicator.style = .large
                activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                activityIndicator.tag = aTagFor("activityIndicator")
                
                //Display the activity indicator.
                activityIndicator.startAnimating()
                view.addSubview(activityIndicator)
            }
            
            //Create a new Conversation.
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
        let matchCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatchCell", for: indexPath) as! MatchCell
        
        //If the User has an avatar image and it can be converted to data.
        if let imageDataString = matchArray![indexPath.row].userData.avatarImageData,
            let imageData = Data(base64Encoded: imageDataString, options: .ignoreUnknownCharacters)
        {
            //Set «matchCell's» image view's image to the User's avatar.
            matchCell.imageView.image = UIImage(data: imageData)
        }
        
        //Set the «nameLabel's» text to the first name of the other User.
        matchCell.nameLabel.text = matchArray![indexPath.row].firstName!
        
        //matchCell.updateFrame()
        
        return matchCell
    }
}
