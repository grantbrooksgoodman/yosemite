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
    var isRequired: Bool!
    
    //Strings
    var title: String!
    var subtitle: String!
    
    //Other Declarations
    var dataType: UserData.DataType!
    var viewController: UIViewController!
    
    //--------------------------------------------------//
    
    /* Constructor Function */
    
    init(title: String, subtitle: String, isEditable: Bool, isRequired: Bool, dataType: UserData.DataType, viewController: UIViewController)
    {
        self.title = title
        self.subtitle = subtitle
        self.isEditable = isEditable
        self.isRequired = isRequired
        self.dataType = dataType
        self.viewController = viewController
    }
}
