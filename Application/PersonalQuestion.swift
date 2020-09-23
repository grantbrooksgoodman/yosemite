//
//  PersonalQuestion.swift
//  Yosemite
//
//  Created by Grant Brooks Goodman on 22/09/2020.
//  Copyright © 2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class PersonalQuestion
{
    //--------------------------------------------------//
    
    //Class-Level Variable Declarations
    
    //Strings
    var title: String!
    var text: String?
    
    //--------------------------------------------------//
    
    /* Constructor Function */
    
    init(title: String, text: String?)
    {
        self.title = title
        self.text = text
    }
}
