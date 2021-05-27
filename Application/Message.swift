//
//  Message.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 12/05/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import UIKit

class Message {
    
    //==================================================//
    
    /* MARK: - Class-level Variable Declarations */
    
    //Dates
    var readDate: Date?
    var sentDate: Date
    
    //Strings
    var associatedIdentifier:  String!
    var fromAccountIdentifier: String!
    var messageContent:        String!
    
    //==================================================//
    
    /* MARK: - Constructor Function */
    
    init(associatedIdentifier: String, fromAccountIdentifier: String, messageContent: String, readDate: Date?, sentDate: Date) {
        self.associatedIdentifier  = associatedIdentifier
        self.fromAccountIdentifier = fromAccountIdentifier
        self.messageContent        = messageContent
        self.readDate              = readDate
        self.sentDate              = sentDate
    }
    
    //==================================================//
    
    /* MARK: - Other Functions */
    
    ///Serializes the **Message's** metadata.
    func serialize() -> [String: Any] {
        var dataBundle: [String: Any] = [:]
        
        dataBundle["fromAccount"]          = fromAccountIdentifier
        dataBundle["messageContent"]       = messageContent
        dataBundle["readDate"]             = (readDate == nil ? "!" : masterDateFormatter.string(from: readDate!))
        dataBundle["sentDate"]             = masterDateFormatter.string(from: sentDate)
        
        return dataBundle
    }
}
