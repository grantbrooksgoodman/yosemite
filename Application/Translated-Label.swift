//
//  Translated-Label.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class TranslatedLabel: UILabel
{
    //--------------------------------------------------//
    
    //Required Initialisation Function
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        
        useText(text!)
    }
    
    //--------------------------------------------------//
    
    //Public Function
    
    func useText(_ withString: String)
    {
        text = ""
        
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        activityIndicatorView.startAnimating()
        addSubview(activityIndicatorView)
        
        Translator().suitableString(adjustmentAllowed: true, forLabel: self, withBackUpString: nil, withString: withString) { (shouldAdjust, returnedString) in
            DispatchQueue.main.async {
                //If a suitable string was found.
                if let unwrappedShouldAdjust = shouldAdjust
                {
                    //If the method says we should adjust the size.
                    if unwrappedShouldAdjust
                    {
                        //If the returned string is indeed different from what we gave it.
                        if returnedString != withString
                        {
                            //Adjust the font size to fit the returned string.
                            self.font = self.font.withSize(self.fontSizeThatFits(returnedString))
                        }
                        
                        if !self.isFullStringSupportedByFont(withFont: self.font, withString: returnedString)
                        {
                            self.font = UIFont.systemFont(ofSize: self.font.pointSize, weight: .semibold)
                        }
                        
                        activityIndicatorView.removeFromSuperview()
                        
                        //Set the text to the returned string after adjusting the size.
                        UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve, animations: {
                            self.text = returnedString
                        })
                    }
                    else //Method says we don't need to adjust the size.
                    {
                        if !self.isFullStringSupportedByFont(withFont: self.font, withString: returnedString)
                        {
                            self.font = UIFont.systemFont(ofSize: self.font.pointSize, weight: .semibold)
                        }
                        
                        activityIndicatorView.removeFromSuperview()
                        
                        //Set the text to the returned string, don't adjust the size.
                        UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve, animations: {
                            self.text = returnedString
                        })
                    }
                }
                else //A suitable string was not found.
                {
                    if !self.isFullStringSupportedByFont(withFont: self.font, withString: withString)
                    {
                        self.font = UIFont.systemFont(ofSize: self.font.pointSize, weight: .semibold)
                    }
                    
                    activityIndicatorView.removeFromSuperview()
                    
                    //Set the text to what it was before.
                    UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve, animations: {
                        self.text = withString
                    })
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
            if let temporaryCurrentTask = Translator().sessionTask
            {
                temporaryCurrentTask.cancel()
            }
            
            if self.text == ""
            {
                activityIndicatorView.removeFromSuperview()
                
                UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    self.text = withString.replacingOccurrences(of: "*", with: "")
                })
            }
        }
    }
    
    //--------------------------------------------------//
    
    //Private Function
    
    ///Function that returns whether or not the specified string is supported by the specified font.
    private func isFullStringSupportedByFont(withFont: UIFont!, withString: String!) -> Bool
    {
        var verifiedArray: [Bool]! = []
        
        while verifiedArray.count < withString.stringCharacters.count
        {
            for individualCharacter in withString.stringCharacters
            {
                if let firstScalar = individualCharacter.unicodeScalars.first
                {
                    verifiedArray.append((CTFontCopyCharacterSet((withFont as CTFont)) as CharacterSet).contains(firstScalar))
                }
            }
        }
        
        return !verifiedArray.contains(false)
    }
}
