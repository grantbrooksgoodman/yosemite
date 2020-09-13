//
//  UserObject.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 05/08/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class User
{
    //--------------------------------------------------//
    
    //Class-Level Variable Declarations
    
    //Array Variables
    var matches:           [String]?
    var openConversations: [String]?
    var swipedLeftOn:      [String]?
    var swipedRightOn:     [String]?
    
    //String Variables
    var associatedIdentifier: String!
    var emailAddress:         String!
    var firstName:            String!
    var lastName:             String!
    var phoneNumber:          String!
    
    //Other Variables
    var userData: UserData!
    
    private var DSOpenConversations: [Conversation]?
    
    //--------------------------------------------------//
    
    /* Initialiser Function */
    
    init(associatedIdentifier: String,
         emailAddress: String,
         firstName: String,
         lastName: String,
         matches: [String]?,
         openConversations: [String]?,
         phoneNumber: String,
         swipedLeftOn: [String]?,
         swipedRightOn: [String]?,
         userData: UserData)
    {
        self.associatedIdentifier = associatedIdentifier
        self.emailAddress = emailAddress
        self.firstName = firstName
        self.lastName = lastName
        self.matches = matches
        self.openConversations = openConversations
        self.phoneNumber = phoneNumber
        self.swipedLeftOn = swipedLeftOn
        self.swipedRightOn = swipedRightOn
        self.userData = userData
    }
    
    //--------------------------------------------------//
    
    //Public Functions
    
    func deSerialiseConversations(completion: @escaping(_ conversations: [Conversation]?, _ error: String?) -> Void)
    {
        if let openConversations = openConversations
        {
            if let DSOpenConversations = DSOpenConversations
            {
                completion(DSOpenConversations, nil)
            }
            else
            {
                ConversationSerialiser().getConversations(withIdentifiers: openConversations) { (wrappedConversations, getConversationsErrorDescriptors) in
                    if let returnedConversations = wrappedConversations
                    {
                        //if a user has a conversation, that means they have a match already. it must.
                        self.DSOpenConversations = returnedConversations
                        
                        completion(returnedConversations, nil)
                    }
                    else if let errorDescriptors = getConversationsErrorDescriptors
                    {
                        completion(nil, errorDescriptors.joined(separator: "\n"))
                    }
                }
            }
        }
        else
        {
            completion(nil, "No Conversations to deserialise.")
        }
    }
    
    func updateLastActiveDate()
    {
        GenericSerialiser().setValue(onKey: "/allUsers/\(associatedIdentifier!)/userData/lastActive", withData: secondaryDateFormatter.string(from: Date())) { (setValueError) in
            if let setValueError = setValueError
            {
                report("Update last active date failed! \(setValueError.localizedDescription)", errorCode: (setValueError as NSError).code, isFatal: false, metadata: [#file, #function, #line])
            }
        }
    }
    
    func similarity(to user: User) -> (Int, Int)
    {
        var points = 0
        var pointsPossible = 45
        
        openStream(forFile: #file, forFunction: #function, forLine: #line, withMessage: "For \(user.firstName!)")
        
        if let mySports = userData.sports,
            let otherSports = user.userData.sports
        {
            let formattedMySports = mySports.lowercasedElements().removingSpecialCharacters()
            let formattedOtherSports = otherSports.lowercasedElements().removingSpecialCharacters()
            
            if formattedMySports.containsAny(in: formattedOtherSports)
            {
                for individualSport in formattedMySports
                {
                    if formattedOtherSports.contains(individualSport)
                    {
                        logToStream(forLine: #line, withMessage: "Shared sport!")
                        
                        points += 10
                    }
                    
                    pointsPossible += 10
                }
            }
            else
            {
                logToStream(forLine: #line, withMessage: "Also plays a sport!")
                
                points += 5
                pointsPossible += 10
            }
        }
        
        if let myCallsHome = userData.callsHome,
            let otherCallsHome = user.userData.callsHome
        {
            #warning("callsHome MUST BE A FORMATTED, RESTRICTED LOCATION STRING")
            if myCallsHome.lowercased() == otherCallsHome.lowercased()
            {
                logToStream(forLine: #line, withMessage: "Shared home!")
                points += 20
            }
            
            pointsPossible += 20
        }
        
        if userData.greekLifeOrganisation != nil && user.userData.greekLifeOrganisation != nil
        {
            logToStream(forLine: #line, withMessage: "Shared GLO!")
            points += 15
            pointsPossible += 15
        }
        
        if userData.major == user.userData.major
        {
            logToStream(forLine: #line, withMessage: "Shared major!")
            points += 20
        }
        
        let monthDayFormatter = DateFormatter()
        monthDayFormatter.dateFormat = "dd-MM"
        
        let myBirthDateString = monthDayFormatter.string(from: userData.birthDate)
        let otherBirthDateString = monthDayFormatter.string(from: user.userData.birthDate)
        
        if myBirthDateString == otherBirthDateString
        {
            logToStream(forLine: #line, withMessage: "Shared birthday!")
            points += 5
        }
        
        if let myLookingFor = userData.lookingFor,
            let otherLookingFor = user.userData.lookingFor
        {
            let formattedMyLookingFor = myLookingFor.lowercasedElements().removingSpecialCharacters()
            let formattedOtherLookingFor = otherLookingFor.lowercasedElements().removingSpecialCharacters()
            
            if formattedMyLookingFor.containsAny(in: formattedOtherLookingFor)
            {
                for individualLookingFor in formattedMyLookingFor
                {
                    if formattedOtherLookingFor.contains(individualLookingFor)
                    {
                        logToStream(forLine: #line, withMessage: "Shared looking for!")
                        
                        points += 10
                        pointsPossible += 10
                    }
                }
            }
            
            pointsPossible += 10
        }
        
        if userData.studentType == user.userData.studentType
        {
            logToStream(forLine: #line, withMessage: "Shared student type!")
            points += 10
        }
        
        if userData.yearCode == user.userData.yearCode
        {
            logToStream(forLine: #line, withMessage: "Shared year!")
            points += 10
        }
        
        closeStream(onLine: #line, withMessage: nil)
        
        return (points, pointsPossible)
    }
}

extension Sequence where Iterator.Element == String
{
    func containsAny(in array: [String]) -> Bool
    {
        for individualString in array
        {
            if contains(individualString)
            {
                return true
            }
        }
        
        return false
    }
    
    func lowercasedElements() -> [String]
    {
        var finalArray: [String]! = []
        
        for individualString in self
        {
            finalArray.append(individualString.lowercased())
        }
        
        return finalArray
    }
    
    func removingSpecialCharacters() -> [String]
    {
        let acceptableCharacters = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        
        var finalArray: [String]! = []
        
        for individualString in self
        {
            finalArray.append(individualString.filter { acceptableCharacters.contains($0) })
        }
        
        return finalArray
    }
}
