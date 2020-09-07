//
//  UserDataBundle.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 05/08/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class UserData
{
    //--------------------------------------------------//
    
    //Class-Level Variable Declarations
    
    //Arrays
    var lookingFor:       [String]?
    var profileImageData: [String]?
    var sports:           [String]? //10pts
    
    //Integers
    var gender:           Int!
    var sexualPreference: Int!
    var studentType:      Int!
    var yearCode:         Int!
    
    //Strings
    var avatarImageData:       String?
    var bioText:               String?
    var callsHome:             String? //20pts
    var greekLifeOrganisation: String? //15pts
    var major:                 String! //20pts
    var yearExplanation:       String?
    
    //Other Declarations
    var birthDate: Date! //5pts
    var lastActiveDate: Date!
    
    //make structs for these
    
    //lookingFor:       10pts
    //relationship
    //something casual
    //study buddy
    //workout partner
    //roommate
    //friend
    //nothing in particular
    
    //sexualPreference:
    //1 = males
    //2 = females
    //3 = other
    //  12 = males & females
    //  13 = males & other
    //  23 = females & other
    
    //studentType:      10pts
    //0 = in-state
    //1 = out-of-state
    //2 = international
    
    //gender:
    //0 = male
    //1 = female
    //2 = other
    
    //yearCode:         10pts
    //0 = freshman
    //1 = sophomore
    //2 = junior
    //3 = senior
    //4 = 5th year
    //5 = other
    
    //max 100 pts.
    //decreases with each thing both don't specify
    
    //--------------------------------------------------//
    
    //Prerequisite Initialisation Function
    
    init(avatarImageData: String?,
         bioText: String?,
         birthDate: Date,
         callsHome: String?,
         gender: Int,
         greekLifeOrganisation: String?,
         lastActiveDate: Date,
         lookingFor: [String]?,
         major: String,
         profileImageData: [String]?,
         sexualPreference: Int,
         sports: [String]?,
         studentType: Int,
         yearCode: Int,
         yearExplanation: String?)
    {
        self.avatarImageData = avatarImageData
        self.bioText = bioText
        self.birthDate = birthDate
        self.callsHome = callsHome
        self.gender = gender
        self.greekLifeOrganisation = greekLifeOrganisation
        self.lastActiveDate = lastActiveDate
        self.lookingFor = lookingFor
        self.major = major
        self.profileImageData = profileImageData
        self.sexualPreference = sexualPreference
        self.sports = sports
        self.studentType = studentType
        self.yearCode = yearCode
        self.yearExplanation = yearExplanation
    }
    
    //--------------------------------------------------//
    
    //Other Functions
    
    ///Serialises the **UserData's** metadata.
    func convertToDataBundle() -> [String:Any]
    {
        var dataBundle: [String:Any] = [:]
        
        dataBundle["avatarImageData"] = avatarImageData ?? "!"
        dataBundle["bioText"] = bioText ?? "!"
        dataBundle["birthDate"] = masterDateFormatter.string(from: birthDate)
        dataBundle["callsHome"] = callsHome ?? "!"
        dataBundle["gender"] = gender
        dataBundle["greekLifeOrganisation"] = greekLifeOrganisation ?? "!"
        dataBundle["lastActive"] = secondaryDateFormatter.string(from: lastActiveDate)
        dataBundle["lookingFor"] = lookingFor ?? ["!"]
        dataBundle["major"] = major
        dataBundle["profileImageData"] = profileImageData ?? ["!"]
        dataBundle["sexualPreference"] = sexualPreference
        dataBundle["sports"] = sports ?? ["!"]
        dataBundle["studentType"] = studentType
        dataBundle["yearCode"] = yearCode
        dataBundle["yearExplanation"] = yearExplanation ?? "!"
        
        return dataBundle
    }
}
