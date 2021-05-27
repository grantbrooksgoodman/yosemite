//
//  ShadowButton.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import UIKit

class ShadowButton: UIButton {
    
    //==================================================//
    
    /* MARK: - Class-level Variable Declarations */
    
    //Booleans
    override var isEnabled: Bool {
        didSet {
            layer.shadowColor = isEnabled ? enabledShadowColor : disabledShadowColor.cgColor
            layer.borderColor = isEnabled ? enabledShadowColor : disabledShadowColor.cgColor
            backgroundColor = isEnabled ? enabledBackgroundColor : disabledBackgroundColor
        }
    }
    private var animateTouches: Bool!
    
    //UIColors
    private var enabledBackgroundColor: UIColor!
    private var enabledShadowColor: CGColor!
    
    var disabledBackgroundColor = UIColor.gray
    var disabledShadowColor = UIColor.darkGray
    
    //Other Declarations
    var borderFrame: UIView?
    var fontSize: CGFloat!
    
    //==================================================//
    
    /* MARK: - Class Declaration */
    
    class func buttonWithType(_ buttonType: UIButton.ButtonType?) -> AnyObject {
        let currentButton = buttonWithType(buttonType) as! ShadowButton
        
        return currentButton
    }
    
    //==================================================//
    
    /* MARK: - Overridden Functions */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if animateTouches {
            let emptySize = CGSize(width: 0, height: 0)
            
            if let borderFrame = borderFrame {
                borderFrame.layer.shadowOffset = emptySize
                borderFrame.frame.origin.y = borderFrame.frame.origin.y + 3
            }
            
            layer.shadowOffset = emptySize
            frame.origin.y = frame.origin.y + 3
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if animateTouches {
            let modifiedSize = CGSize(width: 0, height: 4)
            
            if let borderFrame = borderFrame {
                borderFrame.layer.shadowOffset = modifiedSize
                borderFrame.frame.origin.y = borderFrame.frame.origin.y - 3
            }
            
            layer.shadowOffset = modifiedSize
            frame.origin.y = frame.origin.y - 3
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        if animateTouches {
            let modifiedSize = CGSize(width: 0, height: 4)
            
            if let borderFrame = borderFrame {
                borderFrame.layer.shadowOffset = modifiedSize
                borderFrame.frame.origin.y = borderFrame.frame.origin.y - 3
            }
            
            layer.shadowOffset = modifiedSize
            frame.origin.y = frame.origin.y - 3
        }
    }
    
    //==================================================//
    
    /* MARK: - Initializer Functions */
    
    func initializeLayer(animateTouches: Bool,
                         backgroundColor: UIColor,
                         customCornerRadius: CGFloat?,
                         shadowColor: CGColor) {
        self.animateTouches = animateTouches
        
        enabledBackgroundColor = backgroundColor
        enabledShadowColor = shadowColor
        
        self.backgroundColor = isEnabled ? enabledBackgroundColor : disabledBackgroundColor
        
        layer.borderColor = isEnabled ? enabledShadowColor : disabledShadowColor.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = customCornerRadius ?? 10
        layer.masksToBounds = false
        layer.shadowColor = isEnabled ? enabledShadowColor : disabledShadowColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 1
    }
    
    func initializeLayer(animateTouches: Bool,
                         backgroundColor: UIColor,
                         customBorderFrame: CGRect,
                         instanceName: String,
                         shadowColor: CGColor) {
        self.animateTouches = animateTouches
        
        enabledBackgroundColor = backgroundColor
        enabledShadowColor = shadowColor
        
        let tag = aTagFor("\(instanceName)_BORDER")
        
        superview!.addShadowBorder(backgroundColor: isEnabled ? enabledBackgroundColor : disabledBackgroundColor, borderColor: isEnabled ? enabledShadowColor : disabledShadowColor.cgColor, withFrame: customBorderFrame, withTag: tag)
        
        if let buttonBorder = superview!.viewWithTag(tag) {
            buttonBorder.center = center
            borderFrame = buttonBorder
        }
    }
}
