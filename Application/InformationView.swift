//
//  InformationView.swift
//  Gamma
//
//  Created by Grant Brooks Goodman on 17/07/2020.
//  Copyright © 2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

//Third-party Frameworks
import Koloda

class InformationView: UIView
{
    //--------------------------------------------------//
    
    //Interface Builder User Interface Elements
    
    //ShadowButtons
    @IBOutlet weak var backButton:            ShadowButton!
    @IBOutlet weak var goodWithKidsRadioView: ShadowButton!
    @IBOutlet weak var neuteredRadioView:     ShadowButton!
    @IBOutlet weak var vaccinatedRadioView:   ShadowButton!
    
    //TranslatedLabels
    @IBOutlet weak var ancillaryLabel:    TranslatedLabel!
    @IBOutlet weak var breedLabel:        TranslatedLabel!
    @IBOutlet weak var colourLabel:       TranslatedLabel!
    @IBOutlet weak var goodWithKidsLabel: TranslatedLabel!
    @IBOutlet weak var neuteredLabel:     TranslatedLabel!
    @IBOutlet weak var subtitleLabel:     TranslatedLabel!
    @IBOutlet weak var vaccinatedLabel:   TranslatedLabel!
    
    //UILabels
    @IBOutlet weak var nameLabel:   UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    //UITextViews
    @IBOutlet weak var biographyTextView: UITextView!
    @IBOutlet weak var commentsTextView:  UITextView!
    
    //Other Elements
    @IBOutlet weak var profileImageView: UIImageView!
    
    //--------------------------------------------------//
    
    //Override Functions
    
    override func draw(_ rect: CGRect)
    {
        roundBorders(commentsTextView)
        roundBorders(profileImageView)
        
        roundCorners(forViews: [self], withCornerType: 0)
        
        if let breedTitleLabel       = findSubview(aTagFor("breedTitleLabel"))      as? UILabel,
            let colourTitleLabel     = findSubview(aTagFor("colourTitleLabel"))     as? UILabel,
            let shelterCommentsLabel = findSubview(aTagFor("shelterCommentsLabel")) as? UILabel,
            let weightTitleLabel     = findSubview(aTagFor("weightTitleLabel"))     as? UILabel
        {
            ancillaryRound(forViews: [breedTitleLabel, colourTitleLabel, nameLabel, shelterCommentsLabel, weightTitleLabel])
        }
        
        backButton.initialiseLayer(animateTouches: true,
                                   backgroundColour: UIColor(hex: 0xE95A53),
                                   customBorderFrame: nil,
                                   customCornerRadius: nil,
                                   shadowColour: UIColor(hex: 0xD5443B).cgColor,
                                   instanceName: nil)
    }
    
    //--------------------------------------------------//
    
    //Independent Functions
    
    func toggleCheckmark(_ forShadowButton: ShadowButton, isChecked: Bool)
    {
        if isChecked
        {
            forShadowButton.setTitle("✓", for: .normal)
            forShadowButton.titleLabel!.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.heavy)
            forShadowButton.initialiseLayer(animateTouches: false,
                                            backgroundColour: UIColor(hex: 0x60C129),
                                            customBorderFrame: nil,
                                            customCornerRadius: nil,
                                            shadowColour: UIColor.clear.cgColor,
                                            instanceName: nil)
        }
        else
        {
            forShadowButton.setTitle("X", for: .normal)
            forShadowButton.titleLabel!.font = UIFont(name: "SFUIText-Heavy", size: 17)
            forShadowButton.initialiseLayer(animateTouches: false,
                                            backgroundColour: UIColor(hex: 0xE95A53),
                                            customBorderFrame: nil,
                                            customCornerRadius: nil,
                                            shadowColour: UIColor.clear.cgColor,
                                            instanceName: nil)
        }
    }
    
    //--------------------------------------------------//
    
    //Interface Builder Actions
    
    @IBAction func backButton(_ sender: Any)
    {
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 0
            
            if let cardController   = self.superview!.parentViewController! as? CardController,
                let kolodaView      = cardController.kolodaView,
                let currentCardView = kolodaView.viewForCard(at: kolodaView.currentCardIndex) as? CardView
            {
                currentCardView.nameLabel.alpha = 0.9
                currentCardView.informationButton.alpha = 0.9
                currentCardView.subtitleLabel.alpha = 0.9
                
                kolodaView.isUserInteractionEnabled = true
            }
        })
    }
}

extension UIView
{
    var parentViewController: UIViewController?
    {
        var parentResponder: UIResponder? = self
        while parentResponder != nil
        {
            parentResponder = parentResponder?.next
            
            if let viewController = parentResponder as? UIViewController
            {
                return viewController
            }
        }
        
        return nil
    }
}
