//
//  Conversation.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 29/04/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class Conversation
{
    //--------------------------------------------------//
    
    //Class-Level Variable Declarations
    
    //Array Variables
    var associatedMessages:       [Message]!
    var participantIdentifiers:   [String]!
    
    //Other Variables
    var associatedIdentifier: String!
    var lastModifiedDate: Date!
    
    var otherUser: User?
    
    //--------------------------------------------------//
    
    /* Constructor Function */
    
    init(associatedIdentifier: String, associatedMessages: [Message], lastModifiedDate: Date, participantIdentifiers: [String])
    {
        self.associatedIdentifier   = associatedIdentifier
        self.associatedMessages     = associatedMessages
        self.lastModifiedDate       = lastModifiedDate
        self.participantIdentifiers = participantIdentifiers
    }
    
    //--------------------------------------------------//
    
    //Other Functions
    
    ///Serialises the **Conversation's** metadata.
    func convertToDataBundle() -> [String:Any]
    {
        var dataBundle: [String:Any] = [:]
        
        dataBundle["associatedIdentifier"]     = associatedIdentifier
        dataBundle["associatedMessages"]       = messageIdentifiers() ?? ["!"] //failsafe. should NEVER return nil
        dataBundle["conversationParticipants"] = participantIdentifiers
        dataBundle["lastModified"]             = secondaryDateFormatter.string(from: lastModifiedDate)
        
        return dataBundle
    }
    
    func messageIdentifiers() -> [String]?
    {
        var identifierArray: [String]! = []
        
        for individualMessage in associatedMessages
        {
            identifierArray.append(individualMessage.associatedIdentifier)
            
            if associatedMessages.count == identifierArray.count
            {
                return identifierArray
            }
        }
        
        return nil
    }
}
