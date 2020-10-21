//
//  FactoidCard.swift
//  Yosemite
//
//  Created by Grant Brooks Goodman on 19/09/2020.
//  Copyright © 2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class FactoidCard
{
    //--------------------------------------------------//
    
    //Class-Level Variable Declarations
    
    //Booleans
    var isEditable: Bool!
    var isHidden:   Bool!
    var isRequired: Bool!
    
    //Strings
    var title: String!
    var subtitle: String!
    
    //Other Declarations
    var viewController: UIViewController!
    
    //--------------------------------------------------//
    
    /* Constructor Function */
    
    init(title: String, subtitle: String, isEditable: Bool, isHidden: Bool, isRequired: Bool, viewController: UIViewController)
    {
        self.title = title
        self.subtitle = subtitle
        self.isEditable = isEditable
        self.isHidden = isHidden
        self.isRequired = isRequired
        self.viewController = viewController
    }
}
