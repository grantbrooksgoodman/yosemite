//
//  ChatCell.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 24/07/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import UIKit

/* Third-party Frameworks */
import MessageKit

class ChatCell: UITableViewCell {
    
    //==================================================//
    
    /* MARK: - Interface Builder UI Elements */
    
    //UILabels
    @IBOutlet weak var nameLabel:    UILabel!
    @IBOutlet weak var previewTextView: UITextView!
    
    //Other Elements
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var unreadView: UIView!
    
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var recentlyActiveView: UIView!
    
    //==================================================//
    
    /* MARK: - Overridden Functions */
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
