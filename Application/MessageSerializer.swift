//
//  MessageSerializer.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 12/05/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import UIKit

/* Third-party Frameworks */
import FirebaseDatabase

class MessageSerializer {
    
    //==================================================//
    
    /* MARK: - Creation Functions */
    
    /**
     Creates a **Message** on the server.
     
     - Parameter fromAccountWithIdentifier: The identifier of the account sending the **Message.**
     - Parameter inConversationWithIdentifier: The identifier of the **Conversation** to add this **Message** to.
     - Parameter messageContent: The textual content of the **Message.**
     
     - Parameter returnedIdentifier: The identifier of the new **Message** to be returned upon success.
     - Parameter errorDescriptor: The error descriptor to be returned upon failure.
     */
    func createMessage(fromAccountWithIdentifier: String, inConversationWithIdentifier: String?, messageContent: String, completionHandler: @escaping(_ returnedIdentifier: String?, _ errorDescriptor: String?) -> Void) {
        currentUser?.updateLastActiveDate()
        
        if verboseFunctionExposure { print("Creating Message...") }
        
        var dataBundle: [String: Any] = [:]
        
        dataBundle["fromAccount"]          = fromAccountWithIdentifier
        dataBundle["messageContent"]       = messageContent
        dataBundle["readDate"]             = "!"
        dataBundle["sentDate"]             = secondaryDateFormatter.string(from: Date())
        
        if let generatedKey = Database.database().reference().child("/allMessages/").childByAutoId().key {
            GenericSerializer().updateValue(onKey: "/allMessages/\(generatedKey)", withData: dataBundle) { (wrappedError) in
                if let returnedError = wrappedError {
                    if verboseFunctionExposure { print("Finished creating Message!") }
                    
                    completionHandler(nil, returnedError.localizedDescription)
                } else {
                    if let conversationIdentifier = inConversationWithIdentifier {
                        //Updates the conversation with the new message that's just been posted to the server.
                        GenericSerializer().getValues(atPath: "/allConversations/\(conversationIdentifier)/associatedMessages/") { (wrappedReturnedData) in
                            if let returnedData = wrappedReturnedData as? [String] {
                                var updatedArray = returnedData.filter({$0 != "!"})
                                updatedArray.append(generatedKey)
                                
                                GenericSerializer().setValue(onKey: "/allConversations/\(conversationIdentifier)/associatedMessages/", withData: updatedArray) { (wrappedError) in
                                    if let setValueError = wrappedError {
                                        if verboseFunctionExposure { print("Finished creating Message!") }
                                        
                                        completionHandler(nil, setValueError.localizedDescription)
                                    } else {
                                        GenericSerializer().setValue(onKey: "/allConversations/\(conversationIdentifier)/lastModified", withData: secondaryDateFormatter.string(from: Date())) { (wrappedError) in
                                            if let setValueError = wrappedError {
                                                if verboseFunctionExposure { print("Finished creating Message!") }
                                                
                                                completionHandler(nil, setValueError.localizedDescription)
                                            } else {
                                                if verboseFunctionExposure { print("Finished creating Message!") }
                                                
                                                completionHandler(generatedKey, nil)
                                            }
                                        }
                                    }
                                }
                            } else {
                                if verboseFunctionExposure { print("Finished creating Message!") }
                                
                                completionHandler(nil, "Unable to get existing messages.")
                            }
                        }
                    } else {
                        if verboseFunctionExposure { print("Finished creating Message!") }
                        
                        completionHandler(generatedKey, nil)
                    }
                }
            }
        } else {
            if verboseFunctionExposure { print("Finished creating Message!") }
            
            completionHandler(nil, "Unable to create key in database.")
        }
    }
    
    //==================================================//
    
    /* MARK: - Retrieval Functions */
    
    /**
     Attempts to get a **Message** from the server for a given identifier string.
     
     - Parameter withIdentifier: The identifier to query for.
     
     - Parameter returnedMessage: The resulting **Message** to be returned upon success.
     - Parameter errorDescriptor: The error descriptor to be returned upon failure.
     */
    func getMessage(withIdentifier: String, completionHandler: @escaping(_ returnedMessage: Message?, _ errorDescriptor: String?) -> Void) {
        if verboseFunctionExposure { print("Getting Message...") }
        
        Database.database().reference().child("allMessages").child(withIdentifier).observeSingleEvent(of: .value, with: { (returnedSnapshot) in
            if let returnedSnapshotAsDictionary = returnedSnapshot.value as? NSDictionary,
               let asDataBundle = returnedSnapshotAsDictionary as? [String: Any] {
                var mutableDataBundle = asDataBundle
                
                mutableDataBundle["associatedIdentifier"] = withIdentifier
                
                let deSerialisationResult = self.deSerializeMessage(fromDataBundle: mutableDataBundle)
                
                if let deSerializedMessage = deSerialisationResult.deSerializedMessage {
                    if verboseFunctionExposure { print("Finished getting Message!") }
                    
                    completionHandler(deSerializedMessage, nil)
                } else {
                    if verboseFunctionExposure { print("Finished getting Message!") }
                    
                    completionHandler(nil, deSerialisationResult.errorDescriptor!)
                }
            } else {
                if verboseFunctionExposure { print("Finished getting Message!") }
                
                completionHandler(nil, "No message exists with the identifier \"\(withIdentifier)\".")
            }
        }) { (returnedError) in
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
    func getMessages(withIdentifiers: [String], completionHandler: @escaping(_ returnedMessages: [Message]?, _ status: String?) -> Void) {
        if verboseFunctionExposure { print("Getting Messages...") }
        
        var messageArray: [Message]! = []
        var errorDescriptorArray: [String]! = []
        
        if withIdentifiers == ["!"] {
            completionHandler(nil, "Null/first message processed.")
        } else {
            if withIdentifiers.count > 0 {
                for individualIdentifier in withIdentifiers {
                    getMessage(withIdentifier: individualIdentifier) { (wrappedMessage, wrappedErrorDescriptor) in
                        if let returnedMessage = wrappedMessage {
                            messageArray.append(returnedMessage)
                        } else {
                            errorDescriptorArray.append(wrappedErrorDescriptor!)
                        }
                        
                        if messageArray.count + errorDescriptorArray.count == withIdentifiers.count {
                            if verboseFunctionExposure { print("Finished getting Messages!") }
                            
                            completionHandler(messageArray.count == 0 ? nil : messageArray, errorDescriptorArray.count == 0 ? nil : "Failed: \(errorDescriptorArray.joined(separator: "\n"))")
                        }
                    }
                }
            } else {
                if verboseFunctionExposure { print("Finished getting Messages!") }
                
                completionHandler(nil, "No identifiers passed!")
            }
        }
    }
    
    //==================================================//
    
    /* MARK: - Removal Functions */
    
    func deleteMessage(withIdentifier: String, completionHandler: @escaping(_ errorDescriptor: String?) -> Void) {
        GenericSerializer().updateValue(onKey: "/allMessages", withData: [withIdentifier: NSNull()]) { (wrappedError) in
            if let updateValueError = wrappedError {
                completionHandler(updateValueError.localizedDescription)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func deleteMessages(withIdentifiers: [String], completionHandler: @escaping(_ errorDescriptors: [String]?) -> Void) {
        if verboseFunctionExposure { print("Deleting Messages...") }
        
        var errorDescriptorArray: [String]! = []
        
        var amountProcessed = 0
        
        if withIdentifiers.count > 0 {
            for individualIdentifier in withIdentifiers {
                deleteMessage(withIdentifier: individualIdentifier) { (wrappedErrorDescriptor) in
                    if let deleteMessageError = wrappedErrorDescriptor {
                        errorDescriptorArray.append(deleteMessageError)
                    }
                    
                    amountProcessed += 1
                    
                    if amountProcessed == withIdentifiers.count {
                        if verboseFunctionExposure { print("Finished deleting Messages!") }
                        
                        completionHandler(errorDescriptorArray.count == 0 ? nil : errorDescriptorArray)
                    }
                }
            }
        } else {
            if verboseFunctionExposure { print("Finished deleting Messages!") }
            
            completionHandler(["No identifiers passed!"])
        }
    }
    
    //==================================================//
    
    /* MARK: - Other Functions */
    
    func updateReadDate(onMessageWithIdentifier: String, completionHandler: @escaping(_ errorDescriptor: String?) -> Void) {
        GenericSerializer().setValue(onKey: "/allMessages/\(onMessageWithIdentifier)/readDate", withData: secondaryDateFormatter.string(from: Date())) { (wrappedError) in
            if let returnedError = wrappedError {
                completionHandler(returnedError.localizedDescription)
            }
        }
    }
    
    //==================================================//
    
    /* MARK: - Private Functions */
    
    private func deSerializeMessage(fromDataBundle: [String: Any]) -> (deSerializedMessage: Message?, errorDescriptor: String?) {
        if verboseFunctionExposure { print("Deserializing Message...") }
        
        guard let associatedIdentifier = fromDataBundle["associatedIdentifier"] as? String else {
            return(nil, "Unable to deserialize «associatedIdentifier».")
        }
        
        guard let fromAccountIdentifier = fromDataBundle["fromAccount"] as? String else {
            return(nil, "Unable to deserialize «fromAccount».")
        }
        
        guard let messageContent = fromDataBundle["messageContent"] as? String else {
            return(nil, "Unable to deserialize «messageContent».")
        }
        
        guard let readDate = fromDataBundle["readDate"] as? String else {
            return(nil, "Unable to deserialize «readDate».")
        }
        
        guard let sentDate = fromDataBundle["sentDate"] as? String else {
            return(nil, "Unable to deserialize «sentDate».")
        }
        
        if let fullyDeSerializedSentDate = secondaryDateFormatter.date(from: sentDate) {
            if readDate != "!" {
                if let fullyDeSerializedReadDate = secondaryDateFormatter.date(from: readDate) {
                    let deSerializedMessage = Message(associatedIdentifier: associatedIdentifier, fromAccountIdentifier: fromAccountIdentifier, messageContent: messageContent, readDate: fullyDeSerializedReadDate, sentDate: fullyDeSerializedSentDate)
                    
                    if verboseFunctionExposure { print("Finished deserializing Message!") }
                    
                    return(deSerializedMessage, nil)
                } else {
                    if verboseFunctionExposure { print("Finished deserializing Message!") }
                    
                    return (nil, "Unable to convert «readDate» to Date.")
                }
            } else {
                let deSerializedMessage = Message(associatedIdentifier: associatedIdentifier, fromAccountIdentifier: fromAccountIdentifier, messageContent: messageContent, readDate: nil, sentDate: fullyDeSerializedSentDate)
                
                if verboseFunctionExposure { print("Finished deserializing Message!") }
                
                return(deSerializedMessage, nil)
            }
        } else {
            if verboseFunctionExposure { print("Finished deserializing Message!") }
            
            return (nil, "Unable to convert «sentDate» to Date.")
        }
    }
}
