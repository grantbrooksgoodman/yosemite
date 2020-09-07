//
//  ConfidenceController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 26/05/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class ConfidenceController: UIViewController
{
    //--------------------------------------------------//
    
    //Interface Builder User Interface Elements
    
    @IBOutlet weak var confidenceEncapsulatingView: UIView!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var confidenceSlider: UISlider!
    @IBOutlet weak var otherPetsTextView: UITextView!
    
    //--------------------------------------------------//
    
    //Class-level Declarations
    
    //CGRect Declarations
    var originalFrame:                      CGRect!
    var originalSomethingElseTextViewFrame: CGRect!
    
    //String Declarations
    var normallyConfident    = "CONFIDENT"
    var notConfident         = "NOT CONFIDENT"
    var otherPetsPlaceholder = "Please separate your entries with a comma"
    var somewhatConfident    = "SOMEWHAT CONFIDENT"
    var veryConfident        = "VERY CONFIDENT"
    
    //--------------------------------------------------//
    
    //Override Functions
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        originalFrame                      = view.frame
        originalSomethingElseTextViewFrame = otherPetsTextView.frame
        
        //Set up «otherPetsTextView» with a placeholder String.
        otherPetsTextView.text = otherPetsPlaceholder
        otherPetsTextView.textColor = .lightGray
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Set «confidenceLabel's» text to the localised String.
        confidenceLabel.text = normallyConfident
        
        //Add a rounded border to «confidenceEncapsulatingView» and «otherPetsTextView».
        roundBorders(confidenceEncapsulatingView)
        roundBorders(otherPetsTextView)
    }
    
    //--------------------------------------------------//
    
    //Interface Builder Actions
    
    @IBAction func confidenceSlider(_ sender: Any)
    {
        //Round «confidenceSlider's» value to a whole number.
        confidenceSlider.value = round(confidenceSlider.value)
        
        //If «confidenceSlider's» value is 0.
        if confidenceSlider.value == 0
        {
            //Set «confidenceSlider's» text to the localised version of "NOT CONFIDENT".
            confidenceLabel.text = "= \(notConfident)".uppercased()
        }
        else if confidenceSlider.value < 3 //If «confidenceSlider's» value is less than 3 but greater than 0.
        {
            //Set «confidenceSlider's» text to the localised version of "SOMEWHAT CONFIDENT".
            confidenceLabel.text = "= \(somewhatConfident)".uppercased()
            
            //Change «confidenceSlider's» minimum track colour to red.
            confidenceSlider.minimumTrackTintColor = UIColor(hex: 0xE95A53)
        }
        else if confidenceSlider.value < 8 //If «confidenceSlider's» value is less than 8 but greater than 3.
        {
            //Set «confidenceSlider's» text to the localised version of "CONFIDENT".
            confidenceLabel.text = "= \(normallyConfident)".uppercased()
            
            //Change «confidenceSlider's» minimum track colour to orange.
            confidenceSlider.minimumTrackTintColor = UIColor(hex: 0xFF9B2E)
        }
        else if confidenceSlider.value < 10 //If «confidenceSlider's» value is less than 10 but greater than 8.
        {
            //Set «confidenceSlider's» text to the localised version of "VERY CONFIDENT".
            confidenceLabel.text = "= \(veryConfident)".uppercased()
            
            //Change «confidenceSlider's» minimum track colour to green.
            confidenceSlider.minimumTrackTintColor = UIColor(hex: 0x60C129)
        }
    }
    
    //--------------------------------------------------//
    
    //Independent Functions
    
    /**
     Called when the keyboard begins displaying.
     
     - Parameter withNotification: The Notification calling the function.
     */
    @objc func keyboardDidShow(_ withNotification: Notification)
    {
        //Get the keyboard's frame.
        if let keyboardFrame: NSValue = withNotification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        {
            //Convert the keyboard frame to a CGRect.
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            //Get the point where the keyboard begins.
            let minimumValue = keyboardRectangle.origin.y
            
            //If the keyboard obscures part of the view.
            if view.frame.maxY > minimumValue
            {
                //While the keyboard obscures part of the view.
                while minimumValue < view.frame.maxY
                {
                    //If decreasing the «instructionTextView's» font by 1 would make the size less than 10.
                    if view.frame.height - 1 < 50
                    {
                        #warning("Figure something out for this.")
                    }
                    else //If decreasing the «instructionTextView's» font by 1 would not make the size less than 10.
                    {
                        //Decrease the instruction text view's font size by 1.
                        otherPetsTextView.frame.size.height -= 1
                        view.frame.size.height              -= 1
                        
                        if !(view.frame.maxY > minimumValue)
                        {
                            UIView.animate(withDuration: 0.3) {
                                self.otherPetsTextView.frame.size.height -= 4
                            }
                        }
                    }
                }
            }
        }
    }
}

extension ConfidenceController: UITextViewDelegate
{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        //If the user presses "done".
        if (text == "\n")
        {
            //Dismiss the keyboard.
            textView.resignFirstResponder()
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        //Animate the reset of the view and «otherPetsTextView's» frames.
        UIView.animate(withDuration: 0.4) {
            self.view.frame.size.height = self.originalFrame.size.height
            self.otherPetsTextView.frame = self.originalSomethingElseTextViewFrame
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        //If the text view is in placeholder mode.
        if textView.textColor == .lightGray
        {
            //Take the text view out of placeholder mode.
            textView.text = ""
            textView.textColor = .black
        }
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool
    {
        //If the text view ends editing with nothing having been entered.
        if textView.text.noWhiteSpaceLowerCaseString == ""
        {
            //Put the text view back into placeholder mode.
            textView.text = otherPetsPlaceholder
            textView.textColor = .lightGray
        }
        
        return true
    }
}
