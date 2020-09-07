//
//  GradientLabel.swift
//  Gamma
//
//  Created by Grant Brooks Goodman on 03/07/2020.
//  Copyright © 2020 NEOTechnica Corporation. All rights reserved.
//

import UIKit

class GradientLabel: TranslatedLabel
{
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        let gradient = CAGradientLayer()
        
        //82ea83
        //00C7FA
        gradient.frame = bounds
        gradient.colors = [backgroundColor!.cgColor, tintColor!.cgColor]
        gradient.cornerRadius = 8
        // gradient.fr
        gradient.masksToBounds = true
        
        //UIGraphicsBeginImageContext(gradient.frame.size)
        UIGraphicsBeginImageContextWithOptions(gradient.frame.size, false, 0)
        
        imageFromLayer(layer: gradient).draw(in: gradient.bounds)
        
        let imageToSet: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        backgroundColor = UIColor(patternImage: imageToSet)
        
        //self.layer.cornerRadius = self.frame.size.height / 2
        //self.layer.masksToBounds = true;
        
        //addShadowBorder(backgroundColour: .clear, borderColour: UIColor.darkGray.cgColor, withFrame: bounds, withTag: 0)
        
        //applyShadowWithCornerRadius(color: .darkGray, opacity: 1, radius: 4, edge: .Right, shadowSpace: 1)
    }
    
    func imageFromLayer(layer:CALayer) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, layer.isOpaque, 0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
}
