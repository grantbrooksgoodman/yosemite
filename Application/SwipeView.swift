//
//  SwipeView.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 17/07/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import UIKit

/* Third-party Frameworks */
import Koloda

class SwipeView: OverlayView {
    @IBOutlet weak var swipeLabel: UILabel!
    
    override var overlayState: SwipeResultDirection? {
        didSet {
            if let swipeDirection = overlayState {
                if swipeDirection == .left {
                    swipeLabel.text = "🚫"
                    swipeLabel.frame.origin.y = 0
                    swipeLabel.frame.origin.x = frame.size.width - swipeLabel.frame.size.width
                } else if swipeDirection == .right {
                    swipeLabel.text = "💚"
                    swipeLabel.frame.origin.y = 0
                    swipeLabel.frame.origin.x = 0
                }
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        let maskPathForView = UIBezierPath(roundedRect: swipeLabel.bounds,
                                           byRoundingCorners: .allCorners,
                                           cornerRadii: CGSize(width: 10, height: 10))
        
        let maskLayerForView = CAShapeLayer()
        
        maskLayerForView.frame = swipeLabel.bounds
        maskLayerForView.path = maskPathForView.cgPath
        
        swipeLabel.layer.mask = maskLayerForView
        swipeLabel.layer.masksToBounds = false
        swipeLabel.clipsToBounds = true
        
        //swipeLabel.sizeToFit()
        //swipeLabel.center = self.convert(self.center, from: self.superview)
        
        //swipeLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
    }
}
