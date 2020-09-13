//
//  BirthdateController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 16/06/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

import UIKit

//First-party Frameworks
class BirthdateController: UIViewController
{
    //--------------------------------------------------//
    
    /* Interface Builder UI Elements */
    
    @IBOutlet weak var birthdatePicker: UIDatePicker!
    
    //--------------------------------------------------//
    
    /* Overridden Functions */
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        birthdatePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -100, to: Calendar(identifier: .gregorian).startOfDay(for: Date()))!
        birthdatePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -18, to: Calendar(identifier: .gregorian).startOfDay(for: Date()))!
    }
}
