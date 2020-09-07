//
//  QuickFactsView.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 07/08/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

import UIKit

class QuickFactsView: UIView
{
    //--------------------------------------------------//
    
    //Interface Builder UI Elements
    
    //UILabels
    @IBOutlet weak var ageLabel:    UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var majorLabel:  UILabel!
    @IBOutlet weak var titleLabel:  UILabel!
    @IBOutlet weak var yearLabel:   UILabel!
    
    //--------------------------------------------------//
    
    //Override Function
    
    override func draw(_ rect: CGRect)
    {
        frame.origin.y = f.y(460)
        
        for line in subviews
        {
            if line.tag == aTagFor("lineView")
            {
                line.updateFrame()
            }
        }
        
        tag = aTagFor("quickFactsView")
        
        //roundCorners(forViews: [self], withCornerType: 4)
    }
}
