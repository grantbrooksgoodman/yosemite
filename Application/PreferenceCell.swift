//
//  PreferenceCell.swift
//  Yosemite
//
//  Created by Grant Brooks Goodman on 19/09/2020.
//  Copyright © 2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class PreferenceCell: UITableViewCell
{
    //--------------------------------------------------//
    
    /* Interface Builder UI Elements */
    
    /* UILabels */
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var titleLabel:  UILabel!
    
    //--------------------------------------------------//
    
    /* Overridden Functions */
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
