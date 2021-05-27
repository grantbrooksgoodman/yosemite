//
//  RadioButtonController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 28/04/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import Foundation
import UIKit

//==================================================//

/* MARK: - Protocols */

/// RadioButtonControllerDelegate. Delegate optionally implements didSelectButton that receives selected button.
@objc protocol RadioButtonControllerDelegate {
    /**
     This function is called when a button is selected. If 'shouldLetDeSelect' is true, and a button is deselected, this function
     is called with a nil.
     */
    @objc optional func didSelectButton(_ aButton: UIButton?)
}

//==================================================//

/* MARK: - Class */

class RadioButtonController : NSObject {
    
    //==================================================//
    
    /* MARK: - Class-level Variable Declarations */
    
    fileprivate var buttonsArray = [UIButton]()
    fileprivate weak var currentSelectedButton: UIButton? = nil
    weak var delegate: RadioButtonControllerDelegate? = nil
    
    /**
     Set whether a selected radio button can be deselected or not. Default value is false.
     */
    var shouldLetDeSelect = false
    
    //==================================================//
    
    /* MARK: - Constructor Function */
    
    /**
     Variadic parameter init that accepts UIButtons.
     
     - parameter buttons: Buttons that should behave as Radio Buttons
     */
    init(buttons: UIButton...) {
        super.init()
        
        for aButton in buttons {
            aButton.addTarget(self, action: #selector(RadioButtonController.pressed(_:)), for: UIControl.Event.touchUpInside)
        }
        
        self.buttonsArray = buttons
    }
    
    //==================================================//
    
    /* MARK: - Other Functions */
    
    /**
     Add a UIButton to Controller
     
     - parameter button: Add the button to controller.
     */
    func addButton(_ aButton: UIButton) {
        buttonsArray.append(aButton)
        
        aButton.addTarget(self, action: #selector(RadioButtonController.pressed(_:)), for: UIControl.Event.touchUpInside)
    }
    
    @objc func pressed(_ sender: UIButton) {
        if(sender.isSelected) {
            if shouldLetDeSelect {
                sender.isSelected = false
                currentSelectedButton = nil
            }
        } else {
            for aButton in buttonsArray {
                aButton.isSelected = false
            }
            
            sender.isSelected = true
            currentSelectedButton = sender
        }
        
        delegate?.didSelectButton?(currentSelectedButton)
    }
    
    /** 
     Remove a UIButton from controller.
     
     - parameter button: Button to be removed from controller.
     */
    func removeButton(_ aButton: UIButton) {
        var iteratingButton: UIButton? = nil
        
        if(buttonsArray.contains(aButton)) {
            iteratingButton = aButton
        }
        
        if(iteratingButton != nil) {
            buttonsArray.remove(at: buttonsArray.firstIndex(of: iteratingButton!)!)
            
            iteratingButton!.removeTarget(self, action: #selector(RadioButtonController.pressed(_:)), for: UIControl.Event.touchUpInside)
            iteratingButton!.isSelected = false
            
            if currentSelectedButton == iteratingButton {
                currentSelectedButton = nil
            }
        }
    }
    
    /**
     Set an array of UIButons to behave as controller.
     
     - parameter buttonArray: Array of buttons
     */
    func setButtonsArray(_ aButtonsArray: [UIButton]) {
        for aButton in aButtonsArray {
            aButton.addTarget(self, action: #selector(RadioButtonController.pressed(_:)), for: UIControl.Event.touchUpInside)
        }
        
        buttonsArray = aButtonsArray
    }
    
    /**
     Get the currently selected button.
     
     - returns: Currenlty selected button.
     */
    func selectedButton() -> UIButton? {
        return currentSelectedButton
    }
}
