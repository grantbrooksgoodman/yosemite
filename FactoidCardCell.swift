//
//  FactoidCardCell.swift
//  Yosemite
//
//  Created by Grant Brooks Goodman on 19/09/2020.
//  Copyright © 2020 NEOTechnica Corporation. All rights reserved.
//

import UIKit

class FactoidCardCell: UITableViewCell, SSRadioButtonControllerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var showRadioButton: SSRadioButton!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var requiredLabel: UILabel!
    @IBOutlet weak var editLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        //Set up the «RadioButtonController».
        let radioButtonsController: SSRadioButtonsController?
        radioButtonsController = SSRadioButtonsController(buttons: showRadioButton)
        radioButtonsController!.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func showRadioButton(_ sender: Any)
    {
        showRadioButton.isSelected = !showRadioButton.isSelected
    }
}
