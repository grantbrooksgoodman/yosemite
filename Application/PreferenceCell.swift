//
//  PreferenceCell.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 19/09/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import UIKit

class PreferenceCell: UITableViewCell {
    
    //==================================================//
    
    /* MARK: - Interface Builder UI Elements */
    
    //UILabels
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var titleLabel:  UILabel!
    
    //==================================================//
    
    /* MARK: - Overridden Functions */
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
