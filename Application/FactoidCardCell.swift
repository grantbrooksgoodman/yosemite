//
//  FactoidCardCell.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 19/09/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import UIKit

class FactoidCardCell: UITableViewCell, RadioButtonControllerDelegate {
    
    //==================================================//
    
    /* MARK: - Interface Builder UI Elements */
    
    //UILabels
    @IBOutlet weak var editLabel: UILabel!
    @IBOutlet weak var requiredLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    //Other Elements
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var showRadioButton: RadioButton!
    
    //==================================================//
    
    /* MARK: - Overridden Functions */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Set up the «RadioButtonController».
        let radioButtonsController: RadioButtonController?
        radioButtonsController = RadioButtonController(buttons: showRadioButton)
        radioButtonsController!.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //==================================================//
    
    /* MARK: - Interface Builder Actions */
    
    @IBAction func showRadioButton(_ sender: Any) {
        showRadioButton.isSelected = !showRadioButton.isSelected
    }
}
