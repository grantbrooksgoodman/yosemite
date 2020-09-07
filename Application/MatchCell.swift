//
//  MatchCell.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 26/08/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

import MessageKit

class MatchCell: UITableViewCell
{
    //--------------------------------------------------//
    
    //Interface Builder User Interface Elements
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //--------------------------------------------------//
    
    //Override Functions
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int)
    {
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    }
}
