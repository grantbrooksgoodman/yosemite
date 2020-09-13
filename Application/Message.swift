//
//  Message.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 12/05/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class Message
{
    //--------------------------------------------------//
    
    //Class-Level Variable Declarations
    
    //Dates
    var readDate: Date?
    var sentDate: Date
    
    //Strings
    var associatedIdentifier:  String!
    var fromAccountIdentifier: String!
    var messageContent:        String!
    
    //--------------------------------------------------//
    
    /* Initialiser Function */
    
    /**
     - Parameter associatedIdentifier:
     - Parameter fromAccount: Must be an instance of either **Animal** or **User**.
     - Parameter messageContent:
     - Parameter sentDate:
     */
    init(associatedIdentifier: String, fromAccountIdentifier: String, messageContent: String, readDate: Date?, sentDate: Date)
    {
        self.associatedIdentifier  = associatedIdentifier
        self.fromAccountIdentifier = fromAccountIdentifier
        self.messageContent        = messageContent
        self.readDate              = readDate
        self.sentDate              = sentDate
    }
    
    //--------------------------------------------------//
    
    //Other Functions
    
    ///Serialises the **Message's** metadata.
    func convertToDataBundle() -> [String:Any]
    {
        var dataBundle: [String:Any] = [:]
        
        dataBundle["fromAccount"]          = fromAccountIdentifier
        dataBundle["messageContent"]       = messageContent
        dataBundle["readDate"]             = (readDate == nil ? "!" : masterDateFormatter.string(from: readDate!))
        dataBundle["sentDate"]             = masterDateFormatter.string(from: sentDate)
        
        return dataBundle
    }
}
