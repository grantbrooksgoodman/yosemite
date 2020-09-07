//
//  UserSerialiser.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 05/08/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

//Third-party Frameworks
import FirebaseDatabase

class UserSerialiser
{
    //--------------------------------------------------//
    
    //Public Functions
    
    /**
     Creates a **User** on the server with a provided identifier.
     
     - Parameter associatedIdentifier: The identifier to create the **User** with.
     - Parameter emailAddress: The **User's** e-mail address.
     - Parameter firstName: The **User's** first name.
     - Parameter lastName: The **User's** last name.
     - Parameter userData: The **UserData** associated with this **User.**
     - Parameter phoneNumber: The **User's** phone number.
     
     - Parameter returnedUser: The resulting **User** to be returned upon success.
     - Parameter errorDescriptor: The error descriptor to be returned upon failure.
     */
    func createUser(associatedIdentifier: String, emailAddress: String, firstName: String, lastName: String, userData: UserData, phoneNumber: String, completionHandler: @escaping(_ returnedUser: User?, _ errorDescriptor: String?) -> Void)
    {
        if verboseFunctionExposure { print("Creating User...") }
        
        let transformedFirstName = firstName
        CFStringTransform((transformedFirstName as! CFMutableString), nil, kCFStringTransformToLatin, false)
        CFStringTransform((transformedFirstName as! CFMutableString), nil, kCFStringTransformStripCombiningMarks, false)
        
        let transformedLastName = lastName
        CFStringTransform((transformedLastName as! CFMutableString), nil, kCFStringTransformToLatin, false)
        CFStringTransform((transformedLastName as! CFMutableString), nil, kCFStringTransformStripCombiningMarks, false)
        
        var dataBundle: [String:Any] = [:]
        
        dataBundle["emailAddress"]      = emailAddress
        dataBundle["firstName"]         = firstName
        dataBundle["lastName"]          = lastName
        dataBundle["matches"]           = ["!"]
        dataBundle["userData"]          = userData.convertToDataBundle()
        dataBundle["openConversations"] = ["!"]
        dataBundle["swipedLeftOn"]      = ["!"]
        dataBundle["swipedRightOn"]     = ["!"]
        dataBundle["phoneNumber"]       = phoneNumber
        
        GenericSerialiser().updateValue(onKey: "/allUsers/\(associatedIdentifier)", withData: dataBundle) { (wrappedError) in
            if let returnedError = wrappedError
            {
                if verboseFunctionExposure { print("Finished creating User!") }
                
                completionHandler(nil, errorInformation(forError: returnedError as NSError))
            }
            else
            {
                if verboseFunctionExposure { print("Finished creating User!") }
                
                let createdUser = User(associatedIdentifier: associatedIdentifier,
                                       emailAddress: emailAddress,
                                       firstName: firstName,
                                       lastName: lastName,
                                       matches: nil,
                                       openConversations: nil,
                                       phoneNumber: phoneNumber,
                                       swipedLeftOn: nil,
                                       swipedRightOn: nil,
                                       userData: userData)
                
                completionHandler(createdUser, nil)
            }
        }
    }
    
    func getRandomUsers(amountToGet: Int?, completionHandler: @escaping(_ returnedUserIdentifiers: [String]?, _ noticeDescriptor: String?) -> Void)
    {
        if verboseFunctionExposure { print("Getting random User...") }
        
        Database.database().reference().child("allUsers").observeSingleEvent(of: .value) { (returnedSnapshot) in
            if let returnedSnapshotAsDictionary = returnedSnapshot.value as? NSDictionary,
                let userIdentifiers = returnedSnapshotAsDictionary.allKeys as? [String]
            {
                if amountToGet == nil
                {
                    completionHandler(userIdentifiers.shuffledValue, nil)
                }
                else
                {
                    if amountToGet! > userIdentifiers.count
                    {
                        completionHandler(userIdentifiers.shuffledValue, "Requested amount was larger than database size.")
                    }
                    else if amountToGet! == userIdentifiers.count
                    {
                        completionHandler(userIdentifiers.shuffledValue, nil)
                    }
                    else if amountToGet! < userIdentifiers.count
                    {
                        completionHandler(Array(userIdentifiers.shuffledValue[0...amountToGet!]), nil)
                    }
                }
            }
            else
            {
                completionHandler(nil, "Unable to deserialise snapshot.")
            }
        }
    }
    
    /**
     Attempts to get a **User** from the server for a given identifier String.
     
     - Parameter withIdentifier: The identifier to query for.
     
     - Parameter returnedUser: The resulting **User** to be returned upon success.
     - Parameter errorDescriptor: The error descriptor to be returned upon failure.
     */
    func getUser(withIdentifier: String, completionHandler: @escaping(_ returnedUser: User?, _ errorDescriptor: String?) -> Void)
    {
        if verboseFunctionExposure { print("Getting User...") }
        
        Database.database().reference().child("allUsers").child(withIdentifier).observeSingleEvent(of: .value, with: { (returnedSnapshot) in
            if let returnedSnapshotAsDictionary = returnedSnapshot.value as? NSDictionary, let asDataBundle = returnedSnapshotAsDictionary as? [String:Any]
            {
                var mutableDataBundle = asDataBundle
                
                mutableDataBundle["associatedIdentifier"] = withIdentifier
                
                self.deSerialiseUser(fromDataBundle: mutableDataBundle) { (wrappedUser, wrappedErrorDescriptor) in
                    if verboseFunctionExposure { print("Finished getting User!") }
                    
                    completionHandler((wrappedErrorDescriptor != nil ? nil : wrappedUser), wrappedErrorDescriptor)
                }
            }
            else
            {
                if verboseFunctionExposure { print("Finished getting User!") }
                
                completionHandler(nil, "No user exists with the identifier \"\(withIdentifier)\".")
            }
        })
        { (returnedError) in
            if verboseFunctionExposure { print("Finished getting User!") }
            
            completionHandler(nil, "Unable to retrieve the specified data. (\(returnedError.localizedDescription))")
        }
    }
    
    enum SwipeDirection
    {
        case right
        case left
    }
    
    /**
     Removes a match between two **Users.**
     
     - Parameter forUserIdentifier: The identifier of the **User** to **update the match log for.**
     - Parameter withUserIdentifier: The identifier of the **User** to **update the match log with.**
     
     - Parameter completion: Returns `nil` when the **operation completed successfully.** Otherwise a String with an **error descriptor.**
     */
    func removeMatch(between forUserIdentifier: String, and withUserIdentifier: String, completion: @escaping(_ errorDescriptor: String?) -> Void)
    {
        var finalError: String?
        
        for individualUser in [forUserIdentifier, withUserIdentifier]
        {
            UserSerialiser().getUser(withIdentifier: individualUser) { (wrappedUser, getUserErrorDescriptor) in
                if let returnedUser = wrappedUser
                {
                    if let matches = returnedUser.matches
                    {
                        var updatedMatches = matches
                        updatedMatches = updatedMatches.filter( {$0 != (individualUser == forUserIdentifier ? withUserIdentifier : forUserIdentifier)} )
                        
                        GenericSerialiser().setValue(onKey: "/allUsers/\(individualUser)/matches", withData: (updatedMatches.count == 0 ? ["!"] : updatedMatches)) { (wrappedSetValueError) in
                            if let setValueError = wrappedSetValueError
                            {
                                if finalError == nil
                                {
                                    finalError = errorInformation(forError: (setValueError as NSError))
                                }
                                else
                                {
                                    finalError!.append("\n\(errorInformation(forError: (setValueError as NSError)))")
                                }
                                
                                if individualUser == withUserIdentifier
                                {
                                    completion(finalError)
                                }
                            }
                            else
                            {
                                if individualUser == withUserIdentifier
                                {
                                    self.undoSwipe(.right, on: withUserIdentifier) { (undoSwipeError) in
                                        if let undoSwipeError = undoSwipeError
                                        {
                                            if finalError == nil
                                            {
                                                finalError = undoSwipeError
                                            }
                                            else
                                            {
                                                finalError!.append("\n\(undoSwipeError)")
                                            }
                                            
                                            completion(finalError)
                                        }
                                        else
                                        {
                                            completion(finalError)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else
                {
                    completion(getUserErrorDescriptor ?? "An unknown error occurred.")
                }
            }
        }
    }
    
    /**
     Updates two **User's** match logs with each other's identifiers.
     
     - Parameter forUserIdentifier: The identifier of the **User** to **update the match log for.**
     - Parameter withUserIdentifier: The identifier of the **User** to **update the match log with.**
     
     - Parameter completion: Returns `nil` when the **operation completed successfully.** Otherwise a String with an **error descriptor.**
     */
    func updateMatches(for forUserIdentifier: String, with withUserIdentifier: String, completion: @escaping(_ errorDescriptor: String?) -> Void)
    {
        var finalError: String?
        
        for individualUser in [forUserIdentifier, withUserIdentifier]
        {
            UserSerialiser().getUser(withIdentifier: individualUser) { (wrappedUser, getUserErrorDescriptor) in
                if let returnedUser = wrappedUser
                {
                    var updatedMatches = returnedUser.matches ?? []
                    updatedMatches.append(individualUser == forUserIdentifier ? withUserIdentifier : forUserIdentifier)
                    
                    GenericSerialiser().setValue(onKey: "/allUsers/\(individualUser)/matches", withData: updatedMatches) { (wrappedSetValueError) in
                        if let setValueError = wrappedSetValueError
                        {
                            if finalError == nil
                            {
                                finalError = errorInformation(forError: (setValueError as NSError))
                            }
                            else
                            {
                                finalError!.append("\n\(errorInformation(forError: (setValueError as NSError)))")
                            }
                            
                            if individualUser == withUserIdentifier
                            {
                                completion(finalError)
                            }
                        }
                        else
                        {
                            if individualUser == withUserIdentifier
                            {
                                completion(finalError)
                            }
                        }
                    }
                }
                else
                {
                    completion(getUserErrorDescriptor ?? "An unknown error occurred.")
                }
            }
        }
    }
    
    /**
     Reverses a swipe for the current **User** in a particular `SwipeDirection.`
     
     **PREREQUISITE:** *currentUser* must **not** be `nil`.
     
     - Parameter inDirection: The `SwipeDirection` to undo.
     
     - Parameter userIdentifier: The identifier of the **User** being removed from the swipe log.
     - Parameter completion: Returns `nil` when the **operation completed successfully.** Otherwise a String with an **error descriptor.**
     */
    func undoSwipe(_ inDirection: SwipeDirection, on userIdentifier: String, completion: @escaping(_ errorDescriptor: String?) -> Void)
    {
        guard let currentUser = currentUser else { report("No «currentUser».", errorCode: nil, isFatal: true, metadata: [#file, #function, #line]); return }
        
        if inDirection == .right
        {
            if let swipedRightOn = currentUser.swipedRightOn,
                let index = swipedRightOn.firstIndex(of: userIdentifier)
            {
                var swipedOn = swipedRightOn.unique()
                swipedOn.remove(at: index)
                currentUser.swipedRightOn = swipedOn.unique().count == 0 ? nil : swipedOn.unique()
                
                GenericSerialiser().updateValue(onKey: "/allUsers/\(currentUser.associatedIdentifier!)", withData: ["swipedRightOn": (swipedOn.count == 0 ? ["!"] : swipedOn)]) { (updateValueErrorDescriptor) in
                    if let updateValueError = updateValueErrorDescriptor
                    {
                        completion(errorInformation(forError: (updateValueError as NSError)))
                    }
                    else
                    {
                        completion(nil)
                    }
                }
            }
        }
        else
        {
            if let swipedLeftOn = currentUser.swipedLeftOn,
                let index = swipedLeftOn.firstIndex(of: userIdentifier)
            {
                var swipedOn = swipedLeftOn.unique()
                swipedOn.remove(at: index)
                currentUser.swipedLeftOn = swipedOn.unique().count == 0 ? nil : swipedOn.unique()
                
                GenericSerialiser().updateValue(onKey: "/allUsers/\(currentUser.associatedIdentifier!)", withData: ["swipedLeftOn": (swipedOn.count == 0 ? ["!"] : swipedOn)]) { (updateValueErrorDescriptor) in
                    if let updateValueError = updateValueErrorDescriptor
                    {
                        completion(errorInformation(forError: (updateValueError as NSError)))
                    }
                    else
                    {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    /**
     Updates the current **User's** swipe log.
     
     **PREREQUISITE:** *currentUser* must **not** be `nil`.
     
     - Parameter inDirection: The `SwipeDirection` to swipe in.
     
     - Parameter userIdentifier: The identifier of the **User** being swiped on.
     - Parameter completion: Returns `nil` when the **operation completed successfully.** Otherwise a String with an **error descriptor.**
     */
    func swipe(_ inDirection: SwipeDirection, on userIdentifier: String, completion: @escaping(_ errorDescriptor: String?) -> Void)
    {
        guard let currentUser = currentUser else { report("No «currentUser».", errorCode: nil, isFatal: true, metadata: [#file, #function, #line]); return }
        
        currentUser.updateLastActiveDate()
        
        if inDirection == .right
        {
            guard let swipedRightOn = currentUser.swipedRightOn else
            {
                currentUser.swipedRightOn = [userIdentifier]
                
                GenericSerialiser().updateValue(onKey: "/allUsers/\(currentUser.associatedIdentifier!)", withData: ["swipedRightOn": [userIdentifier]]) { (updateValueErrorDescriptor) in
                    if let updateValueError = updateValueErrorDescriptor
                    {
                        completion(errorInformation(forError: (updateValueError as NSError)))
                    }
                    else
                    {
                        completion(nil)
                    }
                }; return
            }
            
            var swipedOn = swipedRightOn.unique()
            swipedOn.append(userIdentifier)
            currentUser.swipedRightOn = swipedOn.unique()
            
            GenericSerialiser().updateValue(onKey: "/allUsers/\(currentUser.associatedIdentifier!)", withData: ["swipedRightOn": swipedOn]) { (updateValueErrorDescriptor) in
                if let updateValueError = updateValueErrorDescriptor
                {
                    completion(errorInformation(forError: (updateValueError as NSError)))
                }
                else
                {
                    completion(nil)
                }
            }
        }
        else
        {
            guard let swipedLeftOn = currentUser.swipedLeftOn else
            {
                currentUser.swipedLeftOn = [userIdentifier]
                
                GenericSerialiser().updateValue(onKey: "/allUsers/\(currentUser.associatedIdentifier!)", withData: ["swipedLeftOn": [userIdentifier]]) { (updateValueErrorDescriptor) in
                    if let updateValueError = updateValueErrorDescriptor
                    {
                        completion(errorInformation(forError: (updateValueError as NSError)))
                    }
                    else
                    {
                        completion(nil)
                    }
                }; return
            }
            
            var swipedOn = swipedLeftOn.unique()
            swipedOn.append(userIdentifier)
            currentUser.swipedLeftOn = swipedOn.unique()
            
            GenericSerialiser().updateValue(onKey: "/allUsers/\(currentUser.associatedIdentifier!)", withData: ["swipedLeftOn": swipedOn]) { (updateValueErrorDescriptor) in
                if let updateValueError = updateValueErrorDescriptor
                {
                    completion(errorInformation(forError: (updateValueError as NSError)))
                }
                else
                {
                    completion(nil)
                }
            }
        }
    }
    
    /**
     Attempts to get **Users** from the server for an Array of identifier Strings.
     
     - Parameter withIdentifiers: The identifiers to query for.
     
     - Parameter returnedUsers: The resulting **Users** to be returned upon success.
     - Parameter errorDescriptors: The error descriptors to be returned upon failure.
     */
    func getUsers(withIdentifiers: [String], completionHandler: @escaping(_ returnedUsers: [User]?, _ errorDescriptors: [String]?) -> Void)
    {
        if verboseFunctionExposure { print("Getting Users...") }
        
        var userArray: [User]! = []
        var errorDescriptorArray: [String]! = []
        
        if withIdentifiers.count > 0
        {
            for individualIdentifier in withIdentifiers
            {
                getUser(withIdentifier: individualIdentifier) { (wrappedUser, wrappedErrorDescriptor) in
                    if let returnedUser = wrappedUser
                    {
                        userArray.append(returnedUser)
                    }
                    else
                    {
                        errorDescriptorArray.append(wrappedErrorDescriptor!)
                    }
                    
                    if userArray.count + errorDescriptorArray.count == withIdentifiers.count
                    {
                        if verboseFunctionExposure { print("Finished getting Users!") }
                        
                        completionHandler(userArray.count == 0 ? nil : userArray, errorDescriptorArray.count == 0 ? nil : errorDescriptorArray)
                    }
                }
            }
        }
        else
        {
            if verboseFunctionExposure { print("Finished getting Users!") }
            
            completionHandler(nil, ["No identifiers passed!"])
        }
    }
    
    //--------------------------------------------------//
    
    //Private Functions
    
    ////Converts a data bundle into a **UserData** object.
    private func deSerialiseUserData(withBundle: [String:Any]) -> UserData?
    {
        guard let avatarImageData       = withBundle["avatarImageData"] as? String
            else { report("IFM", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return nil }
        
        guard let bioText               = withBundle["bioText"] as? String
            else { report("IFM", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return nil }
        
        guard let birthDate             = withBundle["birthDate"] as? String,
            let birthDateAsDate         = masterDateFormatter.date(from: birthDate)
            else { report("IFM", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return nil }
        
        guard let callsHome             = withBundle["callsHome"] as? String
            else { report("IFM", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return nil }
        
        guard let gender                = withBundle["gender"] as? Int
            else { report("IFM", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return nil }
        
        guard let greekLifeOrganisation = withBundle["greekLifeOrganisation"] as? String
            else { report("IFM", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return nil }
        
        guard let lastActive            = withBundle["lastActive"] as? String,
            let lastActiveDate          = secondaryDateFormatter.date(from: lastActive)
            else { report("IFM", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return nil }
        
        guard let lookingFor            = withBundle["lookingFor"] as? [String]
            else { report("IFM", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return nil }
        
        guard let major                 = withBundle["major"] as? String
            else { report("IFM", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return nil }
        
        guard let profileImageData      = withBundle["profileImageData"] as? [String]
            else { report("IFM", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return nil }
        
        guard let sexualPreference      = withBundle["sexualPreference"] as? Int
            else { report("IFM", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return nil }
        
        guard let sports                = withBundle["sports"] as? [String]
            else { report("IFM", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return nil }
        
        guard let studentType           = withBundle["studentType"] as? Int
            else { report("IFM", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return nil }
        
        guard let yearCode              = withBundle["yearCode"] as? Int
            else { report("IFM", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return nil }
        
        guard let yearExplanation       = withBundle["yearExplanation"] as? String
            else { report("IFM", errorCode: nil, isFatal: false, metadata: [#file, #function, #line]); return nil }
        
        return UserData(avatarImageData: avatarImageData,
                        bioText: bioText,
                        birthDate: birthDateAsDate,
                        callsHome: callsHome == "!" ? nil : callsHome,
                        gender: gender,
                        greekLifeOrganisation: greekLifeOrganisation,
                        lastActiveDate: lastActiveDate,
                        lookingFor: lookingFor == ["!"] ? nil : lookingFor,
                        major: major,
                        profileImageData: profileImageData == ["!"] ? nil : profileImageData,
                        sexualPreference: sexualPreference,
                        sports: sports == ["!"] ? nil : sports,
                        studentType: studentType,
                        yearCode: yearCode,
                        yearExplanation: yearExplanation == "!" ? nil : yearExplanation)
    }
    
    private func deSerialiseUser(fromDataBundle: [String:Any], completionHandler: @escaping(_ deSerialisedUser: User?, _ errorDescriptor: String?) -> Void)
    {
        if verboseFunctionExposure { print("Deserialising the User...") }
        
        guard let associatedIdentifier = fromDataBundle["associatedIdentifier"] as? String
            else { completionHandler(nil, "Unable to deserialise «associatedIdentifier»."); return }
        
        guard let emailAddress = fromDataBundle["emailAddress"] as? String
            else { completionHandler(nil, "Unable to deserialise «emailAddress»."); return }
        
        guard let firstName = fromDataBundle["firstName"] as? String
            else { completionHandler(nil, "Unable to deserialise «firstName»."); return }
        
        guard let lastName = fromDataBundle["lastName"] as? String
            else { completionHandler(nil, "Unable to deserialise «lastName»."); return }
        
        guard let matches = fromDataBundle["matches"] as? [String]
            else { completionHandler(nil, "Unable to deserialise «matches»."); return }
        
        guard let openConversations = fromDataBundle["openConversations"] as? [String]
            else { completionHandler(nil, "Unable to deserialise «openConversations»."); return }
        
        guard let phoneNumber = fromDataBundle["phoneNumber"] as? String
            else { completionHandler(nil, "Unable to deserialise «phoneNumber»."); return }
        
        guard let swipedLeftOn = fromDataBundle["swipedLeftOn"] as? [String]
            else { completionHandler(nil, "Unable to deserialise «swipedLeftOn»."); return }
        
        guard let swipedRightOn = fromDataBundle["swipedRightOn"] as? [String]
            else { completionHandler(nil, "Unable to deserialise «swipedRightOn»."); return }
        
        guard let userDataBundle = fromDataBundle["userData"] as? [String:Any]
            else { completionHandler(nil, "Unable to deserialise «userDataBundle»."); return }
        
        guard let userData = deSerialiseUserData(withBundle: userDataBundle) else {
            if verboseFunctionExposure { print("Finished deserialising the User!") }
            completionHandler(nil, "Unable to convert «userDataBundle» to UserData."); return
        }
        
        let deSerialisedUser = User(associatedIdentifier: associatedIdentifier,
                                    emailAddress: emailAddress,
                                    firstName: firstName,
                                    lastName: lastName,
                                    matches: matches == ["!"] ? nil : matches,
                                    openConversations: openConversations == ["!"] ? nil : openConversations,
                                    phoneNumber: phoneNumber,
                                    swipedLeftOn: swipedLeftOn == ["!"] ? nil : swipedLeftOn,
                                    swipedRightOn: swipedRightOn == ["!"] ? nil : swipedRightOn,
                                    userData: userData)
        
        if verboseFunctionExposure { print("Finished deserialising the User!") }
        
        completionHandler(deSerialisedUser, nil)
    }
}
