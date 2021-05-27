//
//  PersonalQuestionCell.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 22/09/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import UIKit

class PersonalQuestionCell: UITableViewCell {
    
    //==================================================//
    
    /* MARK: - Interface Builder UI Elements */
    
    //Other Elements
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tickButton: ShadowButton!
    
    //==================================================//
    
    /* MARK: - Overridden Functions */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Add a rounded border to the text view.
        textView.layer.borderWidth  = 2
        textView.layer.cornerRadius = 10
        
        textView.layer.borderColor = UIColor(hex: 0xE1E0E1).cgColor
        
        textView.clipsToBounds       = true
        textView.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
