//
//  UserData.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 05/08/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import UIKit

class UserData {
    
    //==================================================//
    
    /* MARK: - Class-level Variable Declarations */
    
    //Arrays
    var profileImageData: [String]?
    
    //Integers
    var sexualPreference: Int!
    var studentType:      Int!
    
    //Strings
    var bioText:               String?
    
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
    //cuffing season date
    
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
    
    //==================================================//
    
    /* MARK: - Constructor Function */
    
    init(bioText: String?,
         birthDate: Date,
         lastActiveDate: Date,
         profileImageData: [String]?,
         sexualPreference: Int,
         studentType: Int) {
        self.bioText = bioText
        self.birthDate = birthDate
        self.lastActiveDate = lastActiveDate
        self.profileImageData = profileImageData
        self.sexualPreference = sexualPreference
        self.studentType = studentType
    }
    
    //==================================================//
    
    /* MARK: - Other Functions */
    
    func getSexualPreferenceString() -> String {
        switch sexualPreference as Int {
        case 1:
            return "Males"
        case 2:
            return "Females"
        case 12:
            return "M & F"
        case 13:
            return "M & Other"
        case 23:
            return "F & Other"
        default:
            return "Other"
        }
    }
    
    func getStudentTypeString() -> String {
        switch studentType as Int {
        case 1:
            return "Out-of-state"
        case 2:
            return "International"
        default:
            return "In-state"
        }
    }
    
    ///Serializes the **UserData's** metadata.
    func serialize() -> [String: Any] {
        var dataBundle: [String: Any] = [:]
        
        dataBundle["bioText"] = bioText ?? "!"
        dataBundle["birthDate"] = masterDateFormatter.string(from: birthDate)
        dataBundle["lastActive"] = secondaryDateFormatter.string(from: lastActiveDate)
        dataBundle["profileImageData"] = profileImageData ?? ["!"]
        dataBundle["sexualPreference"] = sexualPreference
        dataBundle["studentType"] = studentType
        
        return dataBundle
    }
}
