//
//  Translated-Button.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class TranslatedButton: UIButton
{
    //--------------------------------------------------//
    
    //Class-Level Variable Declarations
    
    //Other Variables
    ///An optional UIActivityIndicatorView to be displayed on the button while localisation is in progress.
    var activityIndicatorView: UIActivityIndicatorView?
    ///A Boolean value describing whether the button has been localised or not.
    var isLocalised = false
    ///The original font size of the button's title before localisation.
    var originalFontSize: CGFloat?
    ///The original English title of the button.
    var originalString: String?
    
    //--------------------------------------------------//
    
    //Initialiser Functions
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        if let unwrappedTitleLabel = titleLabel, let unwrappedText = unwrappedTitleLabel.text
        {
            originalFontSize = unwrappedTitleLabel.font.pointSize
            originalString = unwrappedText
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        if let unwrappedTitleLabel = titleLabel, let unwrappedText = unwrappedTitleLabel.text
        {
            originalFontSize = unwrappedTitleLabel.font.pointSize
            originalString = unwrappedText
        }
    }
    
    //--------------------------------------------------//
    
    //Constructor Function
    
    /**
     Translates the button.
     
     - Parameter allowedToAdjust: A boolean indicating whether or not the button is allowed to adjust its text size.
     - Parameter alternateString: The string to localise for languages other than English, if applicable.
     - Parameter backUp: The back-up if **alternateString** ends up truncated.
     - Parameter useActivityIndicator: A boolean indicating whether or not to display a UIActivityIndicator in the centre of the button while translation takes place.
     */
    func initialiseTranslation(allowedToAdjust: Bool, alternateString: String?, backUp: String?, useActivityIndicator: Bool)
    {
        if languageCode != "en"
        {
            if let unwrappedAlternateString = alternateString
            {
                localiseButton(adjustmentAllowed: allowedToAdjust, backUp: backUp, useActivityIndicator: useActivityIndicator, withString: unwrappedAlternateString)
            }
            else
            {
                if let unwrappedTitleLabel = titleLabel, let unwrappedText = unwrappedTitleLabel.text
                {
                    localiseButton(adjustmentAllowed: allowedToAdjust, backUp: backUp, useActivityIndicator: useActivityIndicator, withString: unwrappedText)
                }
                else
                {
                    report("Failed to unwrap title label and title text.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
                }
            }
        }
    }
    
    //--------------------------------------------------//
    
    //Private Function
    
    private func addTranslationProgressOverlay()
    {
        //LARGE = 37x37
        //MEDIUM = 20x20
        
        if let backgroundColour = backgroundColor
        {
            if let isLightColour = backgroundColour.isLight()
            {
                activityIndicatorView = UIActivityIndicatorView(style: ((frame.size.height < 40 || frame.size.width < 22) ? .medium : (isLightColour ? .large : .whiteLarge)))
            }
        }
        
        if let activityIndicator = activityIndicatorView
        {
            activityIndicator.frame = frame
            
            activityIndicator.startAnimating()
            superview!.addSubview(activityIndicator)
        }
    }
    
    private func localiseButton(adjustmentAllowed: Bool, backUp: String?, useActivityIndicator: Bool, withString: String)
    {
        if let unwrappedTitleLabel = titleLabel
        {
            unwrappedTitleLabel.text = originalString
            unwrappedTitleLabel.font = unwrappedTitleLabel.font.withSize(originalFontSize ?? unwrappedTitleLabel.font.pointSize)
            
            let previousAlpha = unwrappedTitleLabel.alpha
            
            unwrappedTitleLabel.alpha = 0
            
            if useActivityIndicator
            {
                addTranslationProgressOverlay()
            }
            
            Translator().suitableString(adjustmentAllowed: adjustmentAllowed, forLabel: unwrappedTitleLabel, withBackUpString: backUp, withString: withString) { (shouldAdjust, returnedString) in
                DispatchQueue.main.async {
                    //If a suitable string was found.
                    if let unwrappedShouldAdjust = shouldAdjust
                    {
                        openStream(forFile: #file, forFunction: #function, forLine: #line, withMessage: "Suitable string found!")
                        
                        //If the method says we should adjust the size.
                        if unwrappedShouldAdjust
                        {
                            logToStream(forLine: #line, withMessage: "Text size needs adjustment.")
                            
                            //If we are allowed to adjust the size.
                            if adjustmentAllowed
                            {
                                logToStream(forLine: #line, withMessage: "Great! We're allowed to adjust it.")
                                
                                //If the returned string is indeed different from what we gave it.
                                if returnedString != withString
                                {
                                    logToStream(forLine: #line, withMessage: "Returned string is validly different – adjusting size!")
                                    
                                    //Adjust the size and set the title text to the returned string.
                                    unwrappedTitleLabel.font = unwrappedTitleLabel.font.withSize(unwrappedTitleLabel.fontSizeThatFits(returnedString))
                                }
                                
                                UIView.animate(withDuration: 0.2, animations: {
                                    self.activityIndicatorView?.alpha = 0
                                    unwrappedTitleLabel.alpha = previousAlpha
                                }) { (didComplete) in
                                    if didComplete
                                    {
                                        self.activityIndicatorView?.removeFromSuperview()
                                    }
                                }
                                
                                self.isLocalised = true
                                
                                closeStream(onLine: #line, withMessage: "Setting the button's title text to the translated string!")
                                
                                self.setTitle(returnedString, for: .normal)
                            }
                            else //We're not allowed to adjust the size.
                            {
                                logToStream(forLine: #line, withMessage: "Uh-oh. We're not permitted to adjust the size.")
                                
                                UIView.animate(withDuration: 0.2, animations: {
                                    self.activityIndicatorView?.alpha = 0
                                    unwrappedTitleLabel.alpha = previousAlpha
                                }) { (didComplete) in
                                    if didComplete
                                    {
                                        self.activityIndicatorView?.removeFromSuperview()
                                    }
                                }
                                
                                self.isLocalised = false
                                
                                closeStream(onLine: #line, withMessage: "Setting the button's title text to the original English string.")
                                
                                //Set the title text to what it was before.
                                self.setTitle(withString, for: .normal)
                            }
                        }
                        else //Method says we don't need to adjust the size.
                        {
                            logToStream(forLine: #line, withMessage: "Perfect! We don't need to adjust the size to fit this text.")
                            
                            UIView.animate(withDuration: 0.2, animations: {
                                self.activityIndicatorView?.alpha = 0
                                unwrappedTitleLabel.alpha = previousAlpha
                            }) { (didComplete) in
                                if didComplete
                                {
                                    self.activityIndicatorView?.removeFromSuperview()
                                }
                            }
                            
                            self.isLocalised = true
                            
                            closeStream(onLine: #line, withMessage: "Setting the button's title text to the translated string!")
                            
                            //Set the title text to the returned string, don't adjust the size.
                            self.setTitle(returnedString, for: .normal)
                        }
                    }
                    else //A suitable string was not found.
                    {
                        logToStream(forLine: #line, withMessage: "A suitable string was not found...")
                        
                        UIView.animate(withDuration: 0.2, animations: {
                            self.activityIndicatorView?.alpha = 0
                            unwrappedTitleLabel.alpha = previousAlpha
                        }) { (didComplete) in
                            if didComplete
                            {
                                self.activityIndicatorView?.removeFromSuperview()
                            }
                        }
                        
                        self.isLocalised = false
                        
                        closeStream(onLine: #line, withMessage: "Setting the button's title text to the original English string.")
                        
                        //Set the title text to what it was before.
                        self.setTitle(withString, for: .normal)
                    }
                }
            }
        }
        else
        {
            isLocalised = false
            
            report("Failed to unwrap title label.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
        }
    }
}

extension UIColor
{
    // Check if the color is light or dark, as defined by the injected lightness threshold.
    // Some people report that 0.7 is best. I suggest to find out for yourself.
    // A nil value is returned if the lightness couldn't be determined.
    func isLight(threshold: Float = 0.5) -> Bool?
    {
        let originalCGColor = self.cgColor
        
        // Now we need to convert it to the RGB colorspace. UIColor.white / UIColor.black are greyscale and not RGB.
        // If you don't do this then you will crash when accessing components index 2 below when evaluating greyscale colors.
        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        guard let components = RGBCGColor?.components else {
            return nil
        }
        guard components.count >= 3 else {
            return nil
        }
        
        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }
}
