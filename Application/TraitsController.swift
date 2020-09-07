//
//  TraitsController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 15/06/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class TraitsController: UIViewController
{
    //--------------------------------------------------//
    
    //Interface Builder User Interface Elements
    
    @IBOutlet weak var traitsEncapsulatingView: UIView!
    @IBOutlet weak var organisedButton: ShadowButton!
    @IBOutlet weak var busyButton: ShadowButton!
    @IBOutlet weak var stupidButton: ShadowButton!
    
    @IBOutlet weak var buttonFour: ShadowButton!
    @IBOutlet weak var buttonFive: ShadowButton!
    @IBOutlet weak var buttonSix: ShadowButton!
    @IBOutlet weak var buttonSeven: ShadowButton!
    @IBOutlet weak var buttonEight: ShadowButton!
    @IBOutlet weak var buttonNine: ShadowButton!
    
    //--------------------------------------------------//
    
    //Class-level Declarations
    
    var didFinishAnimating = true
    
    //--------------------------------------------------//
    
    //Override Functions
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        roundBorders(traitsEncapsulatingView)
        
        organisedButton.tag = aTagFor("organisedButton")
        busyButton.tag      = aTagFor("busyButton")
        stupidButton.tag    = aTagFor("stupidButton")
        buttonFour.tag      = aTagFor("buttonFour")
        buttonFive.tag      = aTagFor("buttonFive")
        buttonSix.tag       = aTagFor("buttonSix")
        buttonSeven.tag     = aTagFor("buttonSeven")
        buttonEight.tag     = aTagFor("buttonEight")
        buttonNine.tag      = aTagFor("buttonNine")
        traitsEncapsulatingView.tag = aTagFor("traitsEncapsulatingView")
        
        initialiseButtons([organisedButton, busyButton, stupidButton, buttonFour, buttonFive, buttonSix, buttonSeven, buttonEight, buttonNine])
    }
    
    //--------------------------------------------------//
    
    //Interface Builder Actions
    
    @IBAction func traitButton(_ sender: Any)
    {
        if let traitButton = (sender as? ShadowButton)
        {
            if traitButton.backgroundColor == .white
            {
                animateSet(forButton: traitButton, backgroundColour: UIColor(hex: 0x60C129), shadowColour: UIColor(hex: 0x3B9A1B))
            }
            else if traitButton.backgroundColor == UIColor(hex: 0x60C129)
            {
                animateSet(forButton: traitButton, backgroundColour: UIColor(hex: 0xE95A53), shadowColour: UIColor(hex: 0xD5443B))
            }
            else
            {
                animateSet(forButton: traitButton, backgroundColour: .white, shadowColour: UIColor(hex: 0xE1E0E1))
            }
        }
    }
    
    //--------------------------------------------------//
    
    //Independent Functions
    
    func initialiseButtons(_ withButtons: [ShadowButton])
    {
        for individualButton in withButtons
        {
            let doubleTapRecogniser = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_:)))
            doubleTapRecogniser.numberOfTapsRequired = 2
            individualButton.addGestureRecognizer(doubleTapRecogniser)
            
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
            individualButton.addGestureRecognizer(longPressRecognizer)
            
            individualButton.initialiseLayer(animateTouches: false, backgroundColour: .white, customBorderFrame: nil, customCornerRadius: nil, shadowColour: UIColor(hex: 0xE1E0E1).cgColor, instanceName: nil)
            individualButton.initialiseTranslation(allowedToAdjust: true, alternateString: nil, backUp: nil, useActivityIndicator: true)
        }
    }
    
    @objc func doubleTapped(_ withGesture: UITapGestureRecognizer)
    {
        var tappedButton: ShadowButton!
        
        if withGesture.view!.tag == aTagFor("organisedButton")   { tappedButton = organisedButton }
        else if withGesture.view!.tag == aTagFor("busyButton")   { tappedButton = busyButton }
        else if withGesture.view!.tag == aTagFor("stupidButton") { tappedButton = stupidButton }
        else if withGesture.view!.tag == aTagFor("buttonFour")   { tappedButton = buttonFour }
        else if withGesture.view!.tag == aTagFor("buttonFive")   { tappedButton = buttonFive }
        else if withGesture.view!.tag == aTagFor("buttonSix")    { tappedButton = buttonSix }
        else if withGesture.view!.tag == aTagFor("buttonSeven")  { tappedButton = buttonSeven }
        else if withGesture.view!.tag == aTagFor("buttonEight")  { tappedButton = buttonEight }
        else if withGesture.view!.tag == aTagFor("buttonNine")   { tappedButton = buttonNine }
        
        if tappedButton.backgroundColor != UIColor(hex: 0xE95A53)
        {
            animateSet(forButton: tappedButton, backgroundColour: UIColor(hex: 0xE95A53), shadowColour: UIColor(hex: 0xD5443B))
        }
        else
        {
            animateSet(forButton: tappedButton, backgroundColour: .white, shadowColour: UIColor(hex: 0xE1E0E1))
        }
    }
    
    @objc func longPressed(_ withGesture: UITapGestureRecognizer)
    {
        var tappedButton: ShadowButton!
        
        if withGesture.view!.tag == aTagFor("organisedButton")   { tappedButton = organisedButton }
        else if withGesture.view!.tag == aTagFor("busyButton")   { tappedButton = busyButton }
        else if withGesture.view!.tag == aTagFor("stupidButton") { tappedButton = stupidButton }
        else if withGesture.view!.tag == aTagFor("buttonFour")   { tappedButton = buttonFour }
        else if withGesture.view!.tag == aTagFor("buttonFive")   { tappedButton = buttonFive }
        else if withGesture.view!.tag == aTagFor("buttonSix")    { tappedButton = buttonSix }
        else if withGesture.view!.tag == aTagFor("buttonSeven")  { tappedButton = buttonSeven }
        else if withGesture.view!.tag == aTagFor("buttonEight")  { tappedButton = buttonEight }
        else if withGesture.view!.tag == aTagFor("buttonNine")   { tappedButton = buttonNine }
        
        if tappedButton.backgroundColor != .white && didFinishAnimating
        {
            animateSet(forButton: tappedButton, backgroundColour: .white, shadowColour: UIColor(hex: 0xE1E0E1))
        }
    }
    
    func animateSet(forButton: ShadowButton, backgroundColour: UIColor, shadowColour: UIColor)
    {
        didFinishAnimating = false
        
        UIView.animate(withDuration: 0.15, animations: {
            forButton.layer.shadowOffset = CGSize(width: 0, height: 0)
            
            forButton.frame.origin.y = forButton.frame.origin.y + 3
        }) { (_) in
            UIView.animate(withDuration: 0.15, animations: {
                forButton.layer.shadowOffset = CGSize(width: 0, height: 4)
                
                forButton.frame.origin.y = forButton.frame.origin.y - 3
                
                forButton.initialiseLayer(animateTouches: false, backgroundColour: backgroundColour, customBorderFrame: nil, customCornerRadius: nil, shadowColour: shadowColour.cgColor, instanceName: nil)
                
                let normalAttributes: [NSAttributedString.Key: Any] = [
                    .font:               UIFont(name: "SFUIText-Regular", size: 17)!,
                    .foregroundColor:    UIColor.black]
                
                let trueAttributes: [NSAttributedString.Key: Any] = [
                    .font:               UIFont(name: "SFUIText-Regular", size: 17)!,
                    .foregroundColor:    UIColor.white]
                
                let strikeThroughAttributes: [NSAttributedString.Key: Any] = [
                    .font:               UIFont(name: "SFUIText-Regular", size: 17)!,
                    .foregroundColor:    UIColor.white,
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .strikethroughColor: UIColor.white]
                
                if backgroundColour ==  UIColor(hex: 0x60C129)
                {
                    forButton.setAttributedTitle(NSMutableAttributedString(string: forButton.titleLabel!.text!, attributes: trueAttributes), for: .normal)
                }
                else if backgroundColour == UIColor(hex: 0xE95A53)
                {
                    forButton.setAttributedTitle(NSMutableAttributedString(string: forButton.titleLabel!.text!, attributes: strikeThroughAttributes), for: .normal)
                }
                else if backgroundColour == .white
                {
                    forButton.setAttributedTitle(NSMutableAttributedString(string: forButton.titleLabel!.text!, attributes: normalAttributes), for: .normal)
                }
            }) { (_) in
                self.didFinishAnimating = true
            }
        }
    }
}
