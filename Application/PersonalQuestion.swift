//
//  PersonalQuestion.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 22/09/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import UIKit

class PersonalQuestion {
    
    //==================================================//
    
    /* MARK: - Class-level Variable Declarations */
    
    //Strings
    var title: String!
    var text: String?
    
    //==================================================//
    
    /* MARK: - Constructor Function */
    
    init(title: String, text: String?) {
        self.title = title
        self.text = text
    }
}
