//
//  MessageSerialiser.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 12/05/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

//Third-party Frameworks
import FirebaseDatabase

class MessageSerialiser
{
    //--------------------------------------------------//
    
    //Public Functions
    
    func deleteMessage(withIdentifier: String, completionHandler: @escaping(_ errorDescriptor: String?) -> Void)
    {
        GenericSerialiser().updateValue(onKey: "/allMessages", withData: [withIdentifier: NSNull()]) { (wrappedError) in
            if let updateValueError = wrappedError
            {
                completionHandler(updateValueError.localizedDescription)
            }
            else
            {
                completionHandler(nil)
            }
        }
    }
    
    func deleteMessages(withIdentifiers: [String], completionHandler: @escaping(_ errorDescriptors: [String]?) -> Void)
    {
        if verboseFunctionExposure { print("Deleting Messages...") }
        
        var errorDescriptorArray: [String]! = []
        
        var amountProcessed = 0
        
        if withIdentifiers.count > 0
        {
            for individualIdentifier in withIdentifiers
            {
                deleteMessage(withIdentifier: individualIdentifier) { (wrappedErrorDescriptor) in
                    if let deleteMessageError = wrappedErrorDescriptor
                    {
                        errorDescriptorArray.append(deleteMessageError)
                    }
                    
                    amountProcessed += 1
                    
                    if amountProcessed == withIdentifiers.count
                    {
                        if verboseFunctionExposure { print("Finished deleting Messages!") }
                        
                        completionHandler(errorDescriptorArray.count == 0 ? nil : errorDescriptorArray)
                    }
                }
            }
        }
        else
        {
            if verboseFunctionExposure { print("Finished deleting Messages!") }
            
            completionHandler(["No identifiers passed!"])
        }
    }
    
    func updateReadDate(onMessageWithIdentifier: String, completionHandler: @escaping(_ errorDescriptor: String?) -> Void)
    {
        GenericSerialiser().setValue(onKey: "/allMessages/\(onMessageWithIdentifier)/readDate", withData: secondaryDateFormatter.string(from: Date())) { (wrappedError) in
            if let returnedError = wrappedError
            {
                completionHandler(returnedError.localizedDescription)
            }
        }
    }
    
    /**
     Creates a **Message** on the server.
     
     - Parameter fromAccountWithIdentifier: The identifier of the account sending the **Message.**
     - Parameter inConversationWithIdentifier: The identifier of the **Conversation** to add this **Message** to.
     - Parameter messageContent: The textual content of the **Message.**
     
     - Parameter returnedIdentifier: The identifier of the new **Message** to be returned upon success.
     - Parameter errorDescriptor: The error descriptor to be returned upon failure.
     */
    func createMessage(fromAccountWithIdentifier: String, inConversationWithIdentifier: String?, messageContent: String, completionHandler: @escaping(_ returnedIdentifier: String?, _ errorDescriptor: String?) -> Void)
    {
        currentUser?.updateLastActiveDate()
        
        if verboseFunctionExposure { print("Creating Message...") }
        
        var dataBundle: [String:Any] = [:]
        
        dataBundle["fromAccount"]          = fromAccountWithIdentifier
        dataBundle["messageContent"]       = messageContent
        dataBundle["readDate"]             = "!"
        dataBundle["sentDate"]             = secondaryDateFormatter.string(from: Date())
        
        if let generatedKey = Database.database().reference().child("/allMessages/").childByAutoId().key
        {
            GenericSerialiser().updateValue(onKey: "/allMessages/\(generatedKey)", withData: dataBundle) { (wrappedError) in
                if let returnedError = wrappedError
                {
                    if verboseFunctionExposure { print("Finished creating Message!") }
                    
                    completionHandler(nil, returnedError.localizedDescription)
                }
                else
                {
                    if let conversationIdentifier = inConversationWithIdentifier
                    {
                        //Updates the conversation with the new message that's just been posted to the server.
                        GenericSerialiser().getValues(atPath: "/allConversations/\(conversationIdentifier)/associatedMessages/") { (wrappedReturnedData) in
                            if let returnedData = wrappedReturnedData as? [String]
                            {
                                var updatedArray = returnedData.filter({$0 != "!"})
                                updatedArray.append(generatedKey)
                                
                                GenericSerialiser().setValue(onKey: "/allConversations/\(conversationIdentifier)/associatedMessages/", withData: updatedArray) { (wrappedError) in
                                    if let setValueError = wrappedError
                                    {
                                        if verboseFunctionExposure { print("Finished creating Message!") }
                                        
                                        completionHandler(nil, setValueError.localizedDescription)
                                    }
                                    else
                                    {
                                        GenericSerialiser().setValue(onKey: "/allConversations/\(conversationIdentifier)/lastModified", withData: secondaryDateFormatter.string(from: Date())) { (wrappedError) in
                                            if let setValueError = wrappedError
                                            {
                                                if verboseFunctionExposure { print("Finished creating Message!") }
                                                
                                                completionHandler(nil, setValueError.localizedDescription)
                                            }
                                            else
                                            {
                                                if verboseFunctionExposure { print("Finished creating Message!") }
                                                
                                                completionHandler(generatedKey, nil)
                                            }
                                        }
                                    }
                                }
                            }
                            else
                            {
                                if verboseFunctionExposure { print("Finished creating Message!") }
                                
                                completionHandler(nil, "Unable to get existing messages.")
                            }
                        }
                    }
                    else
                    {
                        if verboseFunctionExposure { print("Finished creating Message!") }
                        
                        completionHandler(generatedKey, nil)
                    }
                }
            }
        }
        else
        {
            if verboseFunctionExposure { print("Finished creating Message!") }
            
            completionHandler(nil, "Unable to create key in database.")
        }
    }
    
    /**
     Attempts to get a **Message** from the server for a given identifier String.
     
     - Parameter withIdentifier: The identifier to query for.
     
     - Parameter returnedMessage: The resulting **Message** to be returned upon success.
     - Parameter errorDescriptor: The error descriptor to be returned upon failure.
     */
    func getMessage(withIdentifier: String, completionHandler: @escaping(_ returnedMessage: Message?, _ errorDescriptor: String?) -> Void)
    {
        if verboseFunctionExposure { print("Getting Message...") }
        
        Database.database().reference().child("allMessages").child(withIdentifier).observeSingleEvent(of: .value, with: { (returnedSnapshot) in
            if let returnedSnapshotAsDictionary = returnedSnapshot.value as? NSDictionary, let asDataBundle = returnedSnapshotAsDictionary as? [String:Any]
            {
                var mutableDataBundle = asDataBundle
                
                mutableDataBundle["associatedIdentifier"] = withIdentifier
                
                let deSerialisationResult = self.deSerialiseMessage(fromDataBundle: mutableDataBundle)
                
                if let deSerialisedMessage = deSerialisationResult.deSerialisedMessage
                {
                    if verboseFunctionExposure { print("Finished getting Message!") }
                    
                    completionHandler(deSerialisedMessage, nil)
                }
                else
                {
                    if verboseFunctionExposure { print("Finished getting Message!") }
                    
                    completionHandler(nil, deSerialisationResult.errorDescriptor!)
                }
            }
            else
            {
                if verboseFunctionExposure { print("Finished getting Message!") }
                
                completionHandler(nil, "No message exists with the identifier \"\(withIdentifier)\".")
            }
        })
        { (returnedError) in
            if verboseFunctionExposure { print("Finished getting Message!") }
            
            completionHandler(nil, "Unable to retrieve the specified data. (\(returnedError.localizedDescription))")
        }
    }
    
    /**
     Attempts to get **Messages** from the server for an Array of identifier Strings.
     
     - Parameter withIdentifiers: The identifiers to query for.
     
     - Parameter returnedMessages: The resulting **Messages** to be returned upon success.
     - Parameter errorDescriptors: The error descriptors to be returned upon failure.
     */
    func getMessages(withIdentifiers: [String], completionHandler: @escaping(_ returnedMessages: [Message]?, _ status: String?) -> Void)
    {
        if verboseFunctionExposure { print("Getting Messages...") }
        
        var messageArray: [Message]! = []
        var errorDescriptorArray: [String]! = []
        
        if withIdentifiers == ["!"]
        {
            completionHandler(nil, "Null/first message processed.")
        }
        else
        {
            if withIdentifiers.count > 0
            {
                for individualIdentifier in withIdentifiers
                {
                    getMessage(withIdentifier: individualIdentifier) { (wrappedMessage, wrappedErrorDescriptor) in
                        if let returnedMessage = wrappedMessage
                        {
                            messageArray.append(returnedMessage)
                        }
                        else
                        {
                            errorDescriptorArray.append(wrappedErrorDescriptor!)
                        }
                        
                        if messageArray.count + errorDescriptorArray.count == withIdentifiers.count
                        {
                            if verboseFunctionExposure { print("Finished getting Messages!") }
                            
                            completionHandler(messageArray.count == 0 ? nil : messageArray, errorDescriptorArray.count == 0 ? nil : "Failed: \(errorDescriptorArray.joined(separator: "\n"))")
                        }
                    }
                }
            }
            else
            {
                if verboseFunctionExposure { print("Finished getting Messages!") }
                
                completionHandler(nil, "No identifiers passed!")
            }
        }
    }
    
    //--------------------------------------------------//
    
    //Private Functions
    
    private func deSerialiseMessage(fromDataBundle: [String:Any]) -> (deSerialisedMessage: Message?, errorDescriptor: String?)
    {
        if verboseFunctionExposure { print("Deserialising Message...") }
        
        guard let associatedIdentifier = fromDataBundle["associatedIdentifier"] as? String else { return(nil, "Unable to deserialise «associatedIdentifier».") }
        guard let fromAccountIdentifier = fromDataBundle["fromAccount"] as? String else { return(nil, "Unable to deserialise «fromAccount».") }
        guard let messageContent = fromDataBundle["messageContent"] as? String else { return(nil, "Unable to deserialise «messageContent».") }
        guard let readDate = fromDataBundle["readDate"] as? String else { return(nil, "Unable to deserialise «readDate».") }
        guard let sentDate = fromDataBundle["sentDate"] as? String else { return(nil, "Unable to deserialise «sentDate».") }
        
        if let fullyDeSerialisedSentDate = secondaryDateFormatter.date(from: sentDate)
        {
            if readDate != "!"
            {
                if let fullyDeSerialisedReadDate = secondaryDateFormatter.date(from: readDate)
                {
                    let deSerialisedMessage = Message(associatedIdentifier: associatedIdentifier, fromAccountIdentifier: fromAccountIdentifier, messageContent: messageContent, readDate: fullyDeSerialisedReadDate, sentDate: fullyDeSerialisedSentDate)
                    
                    if verboseFunctionExposure { print("Finished deserialising Message!") }
                    
                    return(deSerialisedMessage, nil)
                }
                else
                {
                    if verboseFunctionExposure { print("Finished deserialising Message!") }
                    
                    return (nil, "Unable to convert «readDate» to Date.")
                }
            }
            else
            {
                let deSerialisedMessage = Message(associatedIdentifier: associatedIdentifier, fromAccountIdentifier: fromAccountIdentifier, messageContent: messageContent, readDate: nil, sentDate: fullyDeSerialisedSentDate)
                
                if verboseFunctionExposure { print("Finished deserialising Message!") }
                
                return(deSerialisedMessage, nil)
            }
        }
        else
        {
            if verboseFunctionExposure { print("Finished deserialising Message!") }
            
            return (nil, "Unable to convert «sentDate» to Date.")
        }
    }
}
