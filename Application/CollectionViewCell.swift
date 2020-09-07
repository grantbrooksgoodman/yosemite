//
//  MatchCell.swift
//  Yosemite
//
//  Created by Grant Brooks Goodman on 26/08/2020.
//  Copyright © 2020 NEOTechnica Corporation. All rights reserved.
//

import UIKit

class MatchCell: UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    override func draw(_ rect: CGRect)
    {
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
