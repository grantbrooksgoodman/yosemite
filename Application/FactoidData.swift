//
//  FactoidData.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 10/10/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class FactoidData
{
    //--------------------------------------------------//
    
    //Class-Level Variable Declarations
    
    //Tuples
    var callsHome:             ((Int, Bool), String)?
    var greekLifeOrganisation: ((Int, Bool), String)?
    var sports:                ((Int, Bool), [String])?
    
    //Other Declarations
    var lookingFor: [String]?
    var quickFacts: [String:Any] //gender, major, yearCode, yearExplanation
    
    //--------------------------------------------------//
    
    /* Initialiser Function */
    
    init(callsHome:             ((Int, Bool), String)?,
         greekLifeOrganisation: ((Int, Bool), String)?,
         lookingFor:            [String]?,
         quickFacts:            [String:Any],
         sports:                ((Int, Bool), [String])?)
    {
        self.callsHome = callsHome
        self.greekLifeOrganisation = greekLifeOrganisation
        self.lookingFor = lookingFor
        self.quickFacts = quickFacts
        self.sports = sports
    }
    
    //--------------------------------------------------//
    
    //Other Functions
    
    func gender() -> Int
    {
        return quickFacts["gender"] as! Int
    }
    
    func major() -> String
    {
        return quickFacts["major"] as! String
    }
    
    func yearCode() -> Int
    {
        return quickFacts["yearCode"] as! Int
    }
    
    func yearExplanation() -> String
    {
        if let yearExplanation = quickFacts["yearExplanation"] as? String, yearExplanation != "!"
        {
            return yearExplanation
        }
        
        return "Other"
    }
    
    ///Serialises the **FactoidData's** metadata.
    func serialise() -> [String:Any]
    {
        var dataBundle: [String:Any] = [:]
        
        var serialisedCallsHome:             [Any] = ["!"]
        var serialisedGreekLifeOrganisation: [Any] = ["!"]
        var serialisedSports:                [Any] = ["!"]
        
        if let unwrappedCallsHome = callsHome
        {
            serialisedCallsHome = [unwrappedCallsHome.0.0, unwrappedCallsHome.0.1, unwrappedCallsHome.1]
        }
        
        if let unwrappedGreekLifeOrganisation = greekLifeOrganisation
        {
            serialisedGreekLifeOrganisation = [unwrappedGreekLifeOrganisation.0.0, unwrappedGreekLifeOrganisation.0.1, unwrappedGreekLifeOrganisation.1]
        }
        
        if let unwrappedSports = sports
        {
            serialisedSports = [unwrappedSports.0.0, unwrappedSports.0.1]
            serialisedSports.append(contentsOf: unwrappedSports.1)
        }
        
        dataBundle["callsHome"] = serialisedCallsHome
        dataBundle["greekLifeOrganisation"] = serialisedGreekLifeOrganisation
        dataBundle["lookingFor"] = lookingFor ?? ["!"]
        dataBundle["quickFacts"] = quickFacts
        dataBundle["sports"] = serialisedSports
        
        return dataBundle
    }
    
    func getYearString() -> String
    {
        switch quickFacts["yearCode"] as! Int
        {
        case 0:
            return "Freshman"
        case 1:
            return "Sophomore"
        case 2:
            return "Junior"
        case 3:
            return "Senior"
        case 4:
            return "5th year"
        default:
            if let yearExplanation = quickFacts["yearExplanation"] as? String
            {
                return yearExplanation
            }
            
            return "Other"
        }
    }
    
    func getGenderString(short: Bool) -> String
    {
        switch quickFacts["gender"] as! Int
        {
        case 0:
            return short ? "M" : "Male"
        case 1:
            return short ? "F" : "Female"
        default:
            return short ? "NB" : "Non-binary"
        }
    }
}
