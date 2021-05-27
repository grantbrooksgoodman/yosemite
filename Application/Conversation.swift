//
//  Conversation.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 29/04/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import UIKit

class Conversation {
    
    //==================================================//
    
    /* MARK: - Class-level Variable Declarations */
    
    //Arrays
    var associatedMessages: [Message]!
    var participantIdentifiers: [String]!
    
    //Other Declarations
    var associatedIdentifier: String!
    var lastModifiedDate: Date!
    
    var otherUser: User?
    
    //==================================================//
    
    /* MARK: - Constructor Function */
    
    init(associatedIdentifier: String, associatedMessages: [Message], lastModifiedDate: Date, participantIdentifiers: [String]) {
        self.associatedIdentifier   = associatedIdentifier
        self.associatedMessages     = associatedMessages
        self.lastModifiedDate       = lastModifiedDate
        self.participantIdentifiers = participantIdentifiers
    }
    
    //==================================================//
    
    /* MARK: - Other Functions */
    
    func messageIdentifiers() -> [String]? {
        var identifierArray: [String]! = []
        
        for individualMessage in associatedMessages {
            identifierArray.append(individualMessage.associatedIdentifier)
            
            if associatedMessages.count == identifierArray.count {
                return identifierArray
            }
        }
        
        return nil
    }
    
    ///Serializes the **Conversation's** metadata.
    func serialize() -> [String: Any] {
        var dataBundle: [String: Any] = [:]
        
        dataBundle["associatedIdentifier"]     = associatedIdentifier
        dataBundle["associatedMessages"]       = messageIdentifiers() ?? ["!"] //failsafe. should NEVER return nil
        dataBundle["conversationParticipants"] = participantIdentifiers
        dataBundle["lastModified"]             = secondaryDateFormatter.string(from: lastModifiedDate)
        
        return dataBundle
    }
}
