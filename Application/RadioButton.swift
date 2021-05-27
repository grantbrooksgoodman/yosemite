//
//  RadioButton.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 28/04/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import Foundation
import UIKit

@IBDesignable
class RadioButton: UIButton {
    
    //==================================================//
    
    /* MARK: - Interface Builder UI Elements */
    
    //CGFloats
    @IBInspectable var circleRadius: CGFloat = 5
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        } set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    //Other Elements
    @IBInspectable var circleColor: UIColor = UIColor.red {
        didSet {
            circleLayer.strokeColor = circleColor.cgColor
            self.toggle()
        }
    }
    
    //==================================================//
    
    /* MARK: - Class-level Variable Declarations */
    
    //CAShapeLayer Declarations
    fileprivate var circleLayer     = CAShapeLayer()
    fileprivate var fillCircleLayer = CAShapeLayer()
    
    //Other Declarations
    override var isSelected: Bool {
        didSet {
            toggle()
        }
    }
    
    //==================================================//
    
    /* MARK: - Overridden Functions */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circleLayer.frame = bounds
        circleLayer.path = circlePath().cgPath
        
        fillCircleLayer.frame = bounds
        fillCircleLayer.path = fillCirclePath().cgPath
        
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: (2 * circleRadius + 4 * circleLayer.lineWidth), bottom: 0, right: 0)
    }
    
    override func prepareForInterfaceBuilder() {
        initialize()
    }
    
    //==================================================//
    
    /* MARK: - Initializer Function */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    //==================================================//
    
    /* MARK: - Public Functions */
    
    ///Toggles the selected state of the radio button.
    func toggle() {
        if self.isSelected {
            fillCircleLayer.fillColor = circleColor.cgColor
        } else {
            fillCircleLayer.fillColor = UIColor.clear.cgColor
        }
    }
    
    //==================================================//
    
    /* MARK: - Private Functions */
    
    fileprivate func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: 2 * circleRadius, height: 2 * circleRadius)
        
        circleFrame.origin.x = circleLayer.lineWidth
        
        circleFrame.origin.y = bounds.height / 2 - circleFrame.height / 2
        
        return circleFrame
    }
    
    fileprivate func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame())
    }
    
    fileprivate func fillCirclePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame().insetBy(dx: 2, dy: 2))
    }
    
    fileprivate func initialize() {
        circleLayer.frame = bounds
        circleLayer.lineWidth = 2
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = circleColor.cgColor
        layer.addSublayer(circleLayer)
        
        fillCircleLayer.frame = bounds
        fillCircleLayer.lineWidth = 2
        fillCircleLayer.fillColor = UIColor.clear.cgColor
        fillCircleLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(fillCircleLayer)
        
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: (4 * circleRadius + 4 * circleLayer.lineWidth), bottom: 0, right: 0)
        self.toggle()
    }
}
