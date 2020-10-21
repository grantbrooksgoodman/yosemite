//
//  MessagesController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 27/07/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit

import MessageKit
import InputBarAccessoryView
import FirebaseDatabase

class MessagesController: MessagesViewController, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate
{
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    var buildInstance: Build!
    
    var messageArray: [Message]!
    var otherUser: User!
    var conversationIdentifier: String!
    var newConversation: Conversation?
    
    var firstMoveLabel: UILabel?
    var profileImageView: UIImageView?
    
    //--------------------------------------------------//
    
    /* Initialiser Function */
    
    func initialiseController()
    {
        lastInitialisedController = self
        buildInstance = Build(self)
    }
    
    //--------------------------------------------------//
    
    /* Overridden Functions */
    
    public struct Sender: SenderType
    {
        public let senderId: String
        
        public let displayName: String
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
    }
    
    @objc func sendFeedbackButtonAction()
    {
        PresentationManager().feedbackController(withFileName: #file)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initialiseController()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        configureMessageInputBar()
        title = otherUser.firstName
        messagesCollectionView.scrollToBottom(animated: true)
        
        if messageArray.count == 0
        {
            profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            
            if let profileImageData = otherUser.userData.profileImageData,
                let imageData = Data(base64Encoded: profileImageData[0], options: .ignoreUnknownCharacters)
            {
                profileImageView!.image = UIImage(data: imageData)
            }
            
            profileImageView!.layer.borderColor = UIColor(hex: 0xE1E0E1).cgColor
            profileImageView!.layer.borderWidth = 3
            
            profileImageView!.layer.cornerRadius = profileImageView!.frame.size.width / 2
            
            profileImageView!.layer.masksToBounds = true
            profileImageView!.clipsToBounds = true
            
            profileImageView!.center = view.center
            view.addSubview(profileImageView!)
            
            firstMoveLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
            firstMoveLabel!.font = UIFont(name: "SFUIText-Regular", size: 15)
            firstMoveLabel!.textColor = .systemGray
            firstMoveLabel!.text = "Ready to make the first move?"
            
            let intrinsicContentWidth = firstMoveLabel!.sizeThatFits(firstMoveLabel!.intrinsicContentSize).width
            firstMoveLabel!.frame.size.width = intrinsicContentWidth
            
            firstMoveLabel!.center = view.center
            firstMoveLabel!.frame.origin.y = profileImageView!.frame.maxY + firstMoveLabel!.frame.size.height + 10
            view.addSubview(firstMoveLabel!)
            
            //firstMoveLabel!.updateFrame()
        }
        
        for individualMessage in messageArray
        {
            if individualMessage.fromAccountIdentifier != accountIdentifier && individualMessage.readDate == Date(timeIntervalSince1970: 0)
            {
                MessageSerialiser().getMessage(withIdentifier: individualMessage.associatedIdentifier) { (wrappedMessage, getMessageError) in
                    if let returnedMessage = wrappedMessage
                    {
                        if returnedMessage.readDate == nil
                        {
                            MessageSerialiser().updateReadDate(onMessageWithIdentifier: individualMessage.associatedIdentifier) { (wrappedError) in
                                if let updateReadDateError = wrappedError
                                {
                                    report(updateReadDateError, errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                                }
                            }
                        }
                    }
                    else
                    {
                        print(getMessageError!)
                    }
                }
            }
        }
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.setMessageOutgoingCellBottomLabelAlignment(.init(textAlignment: .right, textInsets: .init(top: 2, left: 0, bottom: 0, right: 10)))
        }
        
        Database.database().reference().child("allConversations").child(conversationIdentifier).child("associatedMessages").observe(.childAdded, with: { (returnedSnapshot) in
            if let newMessageIdentifier = returnedSnapshot.value as? String,
                newMessageIdentifier != "!"
            {
                var shouldUpdateChat = true
                
                for individualMessage in self.messageArray
                {
                    if individualMessage.associatedIdentifier == newMessageIdentifier
                    {
                        shouldUpdateChat = false
                    }
                }
                
                if shouldUpdateChat
                {
                    MessageSerialiser().getMessage(withIdentifier: newMessageIdentifier) { (wrappedMessage, getMessageError) in
                        if let returnedMessage = wrappedMessage
                        {
                            if returnedMessage.fromAccountIdentifier != accountIdentifier
                            {
                                self.messageArray.append(returnedMessage)
                                self.messagesCollectionView.reloadData()
                                self.messagesCollectionView.scrollToBottom(animated: true)
                            }
                        }
                        else
                        {
                            report(getMessageError ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                        }
                    }
                }
            }
            else
            {
                report("Null/first message; awaiting replacement.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        currentFile = #file
        buildInfoController?.view.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        if let conversationController = navigationController?.children[1] as? ConversationController,
            let newConversation = newConversation
        {
            conversationController.newConversation = nil
            
            if messageArray.count == 0
            {
                ConversationSerialiser().deleteConversation(newConversation) { (error) in
                    if let error = error
                    {
                        report(error, errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                    }
                }
            }
            else
            {
                if let matchIdentifiers = conversationController.matchIdentifiers,
                    let index = matchIdentifiers.firstIndex(of: newConversation.participantIdentifiers.filter({$0 != accountIdentifier})[0])
                {
                    conversationController.matchIdentifiers!.remove(at: index)
                    conversationController.matchesUpdated = true
                }
                
                guard conversationController.conversationArray != nil else { conversationController.conversationArray = [newConversation]; return }
                
                conversationController.conversationArray!.append(newConversation)
            }
        }
        
        for individualMessage in messageArray
        {
            Database.database().reference().child("allMessages").child(individualMessage.associatedIdentifier).removeAllObservers()
        }
        
        Database.database().reference().child("allConversations").child(conversationIdentifier).child("associatedMessages").removeAllObservers()
    }
    
    //--------------------------------------------------//
    
    /* Interface Builder Actions */
    
    @IBAction func sendFeedbackButton(_ sender: Any)
    {
        PresentationManager().feedbackController(withFileName: #file)
    }
    
    //--------------------------------------------------//
    
    /* Independent Functions */
    
    @objc func keyboardDidShow(_ withNotification: Notification)
    {
        //        if let firstMoveLabel = firstMoveLabel,
        //            let messageField = inputAccessoryView,
        //            let profileImageView = profileImageView,
        //            findFirstResponder(inView: messageField) != nil
        //        {
        //            UIView.animate(withDuration: 0.2) {
        //                firstMoveLabel.alpha = 0
        //                profileImageView.alpha = 0
        //            }
        //        }
        
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
    @objc func keyboardWillShow(_ withNotification: Notification)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            if let firstMoveLabel = self.firstMoveLabel,
                let profileImageView = self.profileImageView,
                let userInfo = withNotification.userInfo,
                let keyboardFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
                keyboardFrame.origin.y != UIScreen.main.bounds.maxY,
                findFirstResponder(inView: self.messageInputBar) != nil
            {
                UIView.animate(withDuration: 0.15) {
                    firstMoveLabel.alpha = 0
                    profileImageView.alpha = 0
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ withNotification: Notification)
    {
        if let firstMoveLabel = firstMoveLabel,
            let profileImageView = profileImageView
        {
            UIView.animate(withDuration: 0.15) {
                firstMoveLabel.alpha = 1
                profileImageView.alpha = 1
            }
        }
    }
    
    func configureMessageInputBar()
    {
        messageInputBar.delegate = self
        //messageInputBar.inputTextView.tintColor = .systemRed
        //messageInputBar.sendButton.setTitleColor(UIColor(hex: 0x75B6EA), for: .normal)
        //messageInputBar.sendButton.setTitleColor(
        //UIColor(hex: 0x75B6EA).withAlphaComponent(0.3),
        //for: .highlighted
        //)
        messageInputBar.isTranslucent = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func attributedString(_ forString: String, separationIndex: Int) -> NSAttributedString
    {
        let attributedString = NSMutableAttributedString(string: forString)
        
        let boldAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 12),
                                                             .foregroundColor: UIColor.gray]
        
        let regularAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12),
                                                                .foregroundColor: UIColor.lightGray]
        
        attributedString.addAttributes(boldAttributes, range: NSRange(location: 0, length: separationIndex))
        
        attributedString.addAttributes(regularAttributes, range: NSRange(location: separationIndex, length: attributedString.length - separationIndex))
        
        return attributedString
    }
    
    func separatorDateString(fromDate: Date) -> NSAttributedString
    {
        let differenceBetweenDates = Calendar.current.startOfDay(for: Date()).distance(to: Calendar.current.startOfDay(for: fromDate))
        
        let formattedTimeString = DateFormatter.localizedString(from: fromDate, dateStyle: .none, timeStyle: .short)
        
        let overYearDateFormatter = DateFormatter()
        overYearDateFormatter.dateFormat = (Locale.preferredLanguages[0] == "en-US" ? "MMM dd yyyy, " : "dd MMM yyyy, ")
        
        let overYearDateString = overYearDateFormatter.string(from: fromDate)
        
        let regularDateFormatter = DateFormatter()
        regularDateFormatter.dateFormat = "yyyy-MM-dd"
        
        let underYearDateFormatter = DateFormatter()
        underYearDateFormatter.dateFormat = (Locale.preferredLanguages[0] == "en-US" ? "E MMM d, " : "E d MMM, ")
        
        let underYearDateString = underYearDateFormatter.string(from: fromDate)
        
        if differenceBetweenDates == 0
        {
            let separatorString = "Today"
            
            return attributedString("\(separatorString) \(formattedTimeString)", separationIndex: separatorString.count)
        }
        else if differenceBetweenDates == -86400
        {
            let separatorString = "Yesterday"
            
            return attributedString("\(separatorString) \(formattedTimeString)", separationIndex: separatorString.count)
        }
        else if differenceBetweenDates >= -604800
        {
            let fromDateDay = dayOfWeek(regularDateFormatter.string(from: fromDate))
            
            if fromDateDay != dayOfWeek(regularDateFormatter.string(from: Date()))
            {
                return attributedString("\(fromDateDay) \(formattedTimeString)", separationIndex: fromDateDay.count)
            }
            else
            {
                return attributedString(underYearDateString + formattedTimeString, separationIndex: underYearDateString.components(separatedBy: ",")[0].count + 1)
            }
        }
        else if differenceBetweenDates < -604800 && differenceBetweenDates > -31540000
        {
            return attributedString(underYearDateString + formattedTimeString, separationIndex: underYearDateString.components(separatedBy: ",")[0].count + 1)
        }
        
        return attributedString(overYearDateString + formattedTimeString, separationIndex: overYearDateString.components(separatedBy: ",")[0].count + 1)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        buildInstance.handleMailComposition(withController: controller, withResult: result, withError: error)
    }
}

extension MessagesController: MessagesDataSource
{
    func currentSender() -> SenderType {
        return Sender(senderId: accountIdentifier, displayName: "Steven")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int
    {
        return messageArray.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType
    {
        let lastMessageIndex = messageArray.count - 1
        
        if indexPath.section == lastMessageIndex
        {
            Database.database().reference().child("allMessages").removeAllObservers()
            
            Database.database().reference().child("allMessages").child(messageArray[indexPath.section].associatedIdentifier!).observe(.childChanged, with: { (returnedSnapshot) in
                if returnedSnapshot.key == "readDate"
                {
                    if let readDateString = returnedSnapshot.value as? String
                    {
                        if let readDate = secondaryDateFormatter.date(from: readDateString)
                        {
                            self.messageArray[indexPath.section].readDate = readDate
                        }
                        else if readDateString == "!"
                        {
                            self.messageArray[indexPath.section].readDate = nil
                        }
                        
                        self.messagesCollectionView.reloadItems(at: [indexPath])
                    }
                }
            })
        }
        
        return messageArray[indexPath.section]
    }
    
    //    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat
    //    {
    //        return 12
    //    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString?
    {
        //        if indexPath.section % 3 == 0
        //        {
        return separatorDateString(fromDate: messageArray[indexPath.section].sentDate)
        //}
        
        //return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString?
    {
        let lastMessageIndex = messageArray.count - 1
        
        if indexPath.section == lastMessageIndex && messageArray[lastMessageIndex].fromAccountIdentifier == currentUser!.associatedIdentifier
        {
            let boldAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 12),
                                                                 .foregroundColor: UIColor.gray]
            
            if let readDate = messageArray[lastMessageIndex].readDate
            {
                let readString = "Read \(formattedDateString(fromDate: readDate))"
                let attributedReadString = NSMutableAttributedString(string: readString)
                
                let readLength = "Read".count
                
                let regularAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12),
                                                                        .foregroundColor: UIColor.lightGray]
                
                attributedReadString.addAttributes(boldAttributes, range: NSRange(location: 0, length: readLength))
                
                attributedReadString.addAttributes(regularAttributes, range: NSRange(location: readLength, length: attributedReadString.length - readLength))
                
                return attributedReadString
            }
            else
            {
                return NSAttributedString(string: "Delivered", attributes: boldAttributes)
            }
        }
        
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString?
    {
        
        let dateString = secondaryDateFormatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    //    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString?
    //    {
    //        return NSAttributedString(string: message.sender.displayName, attributes: [.font: UIFont.systemFont(ofSize: 12)])
    //    }
}

extension MessagesController: MessagesLayoutDelegate
{
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat
    {
        let lastMessageIndex = messageArray.count - 1
        
        if indexPath.section == lastMessageIndex && messageArray[lastMessageIndex].fromAccountIdentifier == currentUser!.associatedIdentifier
        {
            return 20.0
        }
        else if indexPath.section == lastMessageIndex
        {
            return 5
        }
        //
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat
    {
        if indexPath.section == 0
        {
            return 10
        }
        
        return 0
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat
    {
        if (indexPath.section - 1) > -1
        {
            if messageArray[indexPath.section].sentDate.amountOfSeconds(from: messageArray[indexPath.section - 1].sentDate) > 5400
            {
                return 25
            }
        }
        
        if indexPath.section == 0
        {
            return 15
        }
        
        return 0
    }
}

extension MessagesController: InputBarAccessoryViewDelegate
{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String)
    {
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.text = ""
        inputBar.inputTextView.placeholder = "Sending..."
        inputBar.inputTextView.tintColor = .clear
        
        let sentDate = Date()
        
        MessageSerialiser().createMessage(fromAccountWithIdentifier: accountIdentifier, inConversationWithIdentifier: conversationIdentifier, messageContent: text) { (wrappedIdentifier, createMessageError) in
            if let returnedIdentifier = wrappedIdentifier
            {
                let newMessage = Message(associatedIdentifier: returnedIdentifier,
                                         fromAccountIdentifier: accountIdentifier,
                                         messageContent: text,
                                         readDate: nil,
                                         sentDate: sentDate)
                
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa"
                inputBar.inputTextView.tintColor = .systemRed
                
                if let newConversation = self.newConversation
                {
                    newConversation.associatedMessages.append(newMessage)
                }
                
                self.messageArray.append(newMessage)
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
            else
            {
                PresentationManager().errorAlertController(withTitle: nil,
                                                           withMessage: nil,
                                                           extraneousInformation: createMessageError!,
                                                           withCancelButtonTitle: nil,
                                                           withAlternateSelectors: nil,
                                                           preferredActionIndex: nil,
                                                           withFileName: #file,
                                                           withLineNumber: #line,
                                                           withFunctionTitle: #function,
                                                           networkDependent: true, canFileReport: true)
                
                report(createMessageError ?? "An unknown error occurred.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
            }
        }
    }
}

extension MessagesController: MessagesDisplayDelegate
{
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView)
    {
        if messageArray[indexPath.section].fromAccountIdentifier != accountIdentifier
        {
            if let profileImageData = otherUser.userData.profileImageData,
                let imageData = Data(base64Encoded: profileImageData[0], options: .ignoreUnknownCharacters)
            {
                avatarView.image = UIImage(data: imageData)
            }
            else
            {
                avatarView.set(avatar: Avatar(image: nil, initials: "\(otherUser.firstName.stringCharacters[0].uppercased())\(otherUser.lastName.stringCharacters[0].uppercased())"))
            }
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle
    {
        return message.sender.senderId == accountIdentifier ? .bubbleTail(.bottomRight, .curved) : .bubbleTail(.bottomLeft, .curved)
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor
    {
        return message.sender.senderId == accountIdentifier ? UIColor(hex: 0x75B6EA) /*.systemBlue*/ : UIColor(hex: 0xE5E5EA)
    }
    
}

extension Message: MessageType
{
    public struct Sender: SenderType
    {
        public let senderId: String
        
        public let displayName: String
    }
    
    var messageId: String
    {
        return associatedIdentifier
    }
    
    var sender: SenderType
    {
        return Sender(senderId: fromAccountIdentifier, displayName: "??")
    }
    
    var kind: MessageKind
    {
        return .text(messageContent)
    }
}
