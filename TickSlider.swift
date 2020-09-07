//
//  TickSlider.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 26/05/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

import UIKit

class TickSlider: UISlider
{
    override var value: Float {
        willSet {
            print("willSet called")
        }
        didSet {
            print("didSet called")
            
        }
    }
    
    var thumbTextLabel: UILabel = UILabel()
    
    private var thumbFrame: CGRect
    {
        return thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        thumbTextLabel.frame = thumbFrame
        
        if thumbTextLabel.text != String(value).components(separatedBy: ".")[0]
        {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        
        thumbTextLabel.text = String(value).components(separatedBy: ".")[0]
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        addSubview(thumbTextLabel)
        thumbTextLabel.textAlignment = .center
        thumbTextLabel.font = UIFont(name: "SFUIText-Bold", size: 12)
        thumbTextLabel.textColor = UIColor(hex: 0x4B4B4B)
        thumbTextLabel.layer.zPosition = layer.zPosition + 1
    }
    
    override func draw(_ rect: CGRect)
    {
        let thumbRecte = thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
        
        let thumbOffset: CGFloat = thumbRecte.size.width / 2
        let numberOfTicksToDraw = roundf(maximumValue - minimumValue) + 1
        let distMinTickToMax = frame.size.width - (2 * thumbOffset)
        let distBetweenTicks = distMinTickToMax / CGFloat((numberOfTicksToDraw - 1))
        var xTickMarkPosition = thumbOffset //will change as tick marks are drawn across slider
        let yTickMarkStartingPosition = frame.size.height / 2 //will not change
        let yTickMarkEndingPosition = frame.size.height //will not change
        
        let tickPath = UIBezierPath.init()
        
        for individualIndex in 1...Int(numberOfTicksToDraw)
        {
            //grey = #E4E4E6
            //red = #E95A53
            
            let properColour = UIColor(hex: 0xE4E4E6)
            //
            //            if individualIndex == 6
            //            {
            //                properColour = UIColor(hex: 0xE4E4E6)
            //            }
            //            else if individualIndex > 6
            //            {
            //                properColour = UIColor(hex: 0x60C129)
            //            }
            
            drawLineFromPointToPoint(startX: xTickMarkPosition, toEndingX: xTickMarkPosition, startingY: yTickMarkStartingPosition, toEndingY: yTickMarkEndingPosition, ofColor: properColour, widthOfLine: 2, inView: self)
            
            xTickMarkPosition += distBetweenTicks
        }
        
        tickPath.stroke()
    }
    
    func drawLineFromPointToPoint(startX: CGFloat, toEndingX endX: CGFloat, startingY startY: CGFloat, toEndingY endY: CGFloat, ofColor lineColor: UIColor, widthOfLine lineWidth: CGFloat, inView view: UIView)
    {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: endX, y: endY))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth
        
        layer.insertSublayer(shapeLayer, at: 1)
    }
}

