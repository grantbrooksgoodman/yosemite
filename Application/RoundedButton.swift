//
//  RoundedButton.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import UIKit

class RoundedButton: UIButton {
    
    //==================================================//
    
    /* MARK: - Class-level Variable Declarations */
    
    //UIColors
    var preferredMainColor:     UIColor!
    var preferredOpposingColor: UIColor!
    
    //Other Declarations
    var fontSize: CGFloat!
    
    //==================================================//
    
    /* MARK: - Class Declaration */
    
    class func buttonWithType(_ buttonType: UIButton.ButtonType?) -> AnyObject {
        //RED COLOUR: FF4E4E
        
        let currentButton = buttonWithType(buttonType) as! RoundedButton
        
        return currentButton
    }
    
    //==================================================//
    
    /* MARK: - Overridden Functions */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        UIView.animate(withDuration: 0.1, animations: {
            self.isHighlighted = true
            
            self.setTitleColor(self.preferredOpposingColor, for: .normal)
            
            self.backgroundColor = self.preferredMainColor
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.isHighlighted = false
            
            self.setTitleColor(self.preferredMainColor, for: .normal)
            
            self.backgroundColor = .clear
        })
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    
    //==================================================//
    
    /* MARK: - Initializer Function */
    
    func initializeWith(buttonTitle: String?, isEnabled: Bool, mainColor: UIColor, opposingColor: UIColor, preferredTarget: Selector?, withFontSize: CGFloat?, withAlpha: CGFloat) {
        preferredMainColor = mainColor
        preferredOpposingColor = opposingColor
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
            self.alpha = withAlpha
            
            self.isEnabled = isEnabled
            self.isUserInteractionEnabled = isEnabled
            
            self.layer.borderWidth = 1
            self.layer.cornerRadius = 5
            
            if let unwrappedButtonTitle = buttonTitle {
                self.setTitle(unwrappedButtonTitle.uppercased(), for: .normal)
            } else {
                self.setTitle(self.titleLabel!.text!.uppercased(), for: .normal)
            }
            
            self.titleLabel!.adjustsFontSizeToFitWidth = true
            
            if let unwrappedFontSize = withFontSize {
                self.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: unwrappedFontSize)
            } else {
                self.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            }
            
            if isEnabled {
                self.layer.borderColor = self.preferredMainColor.cgColor
                
                self.setTitleColor(self.preferredMainColor, for: .normal)
                self.setTitleColor(self.preferredOpposingColor, for: .highlighted)
            } else {
                self.layer.borderColor = UIColor.gray.cgColor
                
                self.setTitleColor(.gray, for: .normal)
            }
            
            if preferredTarget != nil {
                self.addTarget(lastInitializedController, action: preferredTarget!, for: .touchUpInside)
            }
        })
    }
    
    //==================================================//
    
    /* MARK: - Other Functions */
    
    func disableButton() {
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
            self.isEnabled = false
            self.isUserInteractionEnabled = false
            
            self.layer.borderColor = UIColor.gray.cgColor
            
            self.setTitleColor(.gray, for: .normal)
        })
    }
    
    func enableButton() {
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
            self.isEnabled = true
            self.isUserInteractionEnabled = true
            
            self.layer.borderColor = self.preferredMainColor.cgColor
            
            self.setTitleColor(self.preferredMainColor, for: .normal)
            self.setTitleColor(self.preferredOpposingColor, for: .highlighted)
        })
    }
    
    func setTarget(withSelector: Selector) {
        self.addTarget(lastInitializedController, action: withSelector, for: .touchUpInside)
    }
    
    func setTitle(withString: String) {
        UIView.transition(with: titleLabel!, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.setTitle(withString.uppercased(), for: .normal)
        })
    }
}
