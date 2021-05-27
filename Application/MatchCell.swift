//
//  MatchCell.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 26/08/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import UIKit

class MatchCell: UICollectionViewCell {
    
    //==================================================//
    
    /* MARK: - Interface Builder UI Elements */
    
    //Other Elements
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var nameLabel: UILabel!
    
    //==================================================//
    
    /* MARK: - Overridden Functions */
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        imageView.layer.borderColor = UIColor(hex: 0xE1E0E1).cgColor
        imageView.layer.borderWidth = 2
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        
        //        let intrinsicNameContentWidth = nameLabel.sizeThatFits(nameLabel.intrinsicContentSize).width
        //
        //        nameLabel.frame.size.width = intrinsicNameContentWidth
        //        nameLabel.center.x = center.x
    }
}
