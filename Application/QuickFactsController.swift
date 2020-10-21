//
//  QuickFactsController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 20/08/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit

class QuickFactsController: UIViewController
{
    //--------------------------------------------------//
    
    /* Interface Builder UI Elements */
    
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    //--------------------------------------------------//
    
    /* Overridden Functions */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let user = (self.parent as? CardPageController == nil) ? currentUser! : (self.parent as! CardPageController).user!
        
        let birthYear = Calendar.current.component(.year, from: user.userData.birthDate)
        let currentYear = Calendar.current.component(.year, from: Date())
        
        ageLabel.text = "\(currentYear - birthYear)"
        
        genderLabel.text = "\((user.factoidData.gender() == 0 ? "M" : (user.factoidData.gender() == 1 ? "F" : "NB")))"
        
        majorLabel.text = "\(user.factoidData.major())"
        
        var yearText: String?
        
        switch user.factoidData.yearCode() as Int
        {
        case 0:
            yearText = "Freshman"
        case 1:
            yearText = "Sophomore"
        case 2:
            yearText = "Junior"
        case 3:
            yearText = "Senior"
        case 4:
            yearText = "5th year"
        case 6:
            yearText = user.factoidData.yearExplanation()
        default:
            yearText = nil
        }
        
        if let year = yearText
        {
            yearLabel.text = "\(year)"
        }
        
        for line in view.subviews
        {
            if line.tag == aTagFor("lineView")
            {
                line.frame.size.width = f.width(line.frame.size.width)
            }
        }
        
        view.updateFrame()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        view.tag += 1
    }
    
    //--------------------------------------------------//
    
    /* Interface Builder Actions */
    
    //--------------------------------------------------//
    
    /* Independent Functions */
}
