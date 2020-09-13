//
//  EmploymentController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 18/05/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class EmploymentController: UIViewController
{
    //--------------------------------------------------//
    
    /* Interface Builder UI Elements */
    
    //Other Elements
    @IBOutlet weak var employmentStatusSegmentedControl: UISegmentedControl!
    @IBOutlet weak var somethingElseTextView: UITextView!
    
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    //CGRect Declarations
    var originalFrame:                      CGRect!
    var originalSomethingElseTextViewFrame: CGRect!
    
    var createAccountController: CreateAccountController!
    
    //--------------------------------------------------//
    
    /* Overridden Functions */
    
    override func viewDidLoad()
    {
        employmentStatusSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor(hex: 0x4B4B4B), .font: UIFont(name: "SFUIText-Bold", size: 12)!], for: .normal)
        
        //Add a rounded border to the «somethingElseTextView».
        somethingElseTextView.layer.borderWidth  = 2
        somethingElseTextView.layer.cornerRadius = 10
        
        somethingElseTextView.layer.borderColor = UIColor(hex: 0xE1E0E1).cgColor
        
        somethingElseTextView.clipsToBounds       = true
        somethingElseTextView.layer.masksToBounds = true
        
        somethingElseTextView.tag = aTagFor("somethingElseTextView")
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if let unwrappedCreateAccountController = self.parent as? CreateAccountController
        {
            createAccountController = unwrappedCreateAccountController
        }
        else
        {
            report("No CreateAccountController.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
        }
        
        originalFrame = view.frame
        originalSomethingElseTextViewFrame = somethingElseTextView.frame
    }
    
    //--------------------------------------------------//
    
    /* Interface Builder Actions */
    
    @IBAction func employmentStatusSegmentedControl(_ sender: Any)
    {
        somethingElseTextView.resignFirstResponder()
        createAccountController.continueButton.isEnabled = true
    }
    
    //--------------------------------------------------//
    
    /* Independent Functions */
    
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
                        //f***ed
                    }
                    else //If decreasing the «instructionTextView's» font by 1 would not make the size less than 10.
                    {
                        //Decrease the instruction text view's font size by 1.
                        somethingElseTextView.frame.size.height -= 1
                        view.frame.size.height -= 1
                        
                        if !(view.frame.maxY > minimumValue)
                        {
                            UIView.animate(withDuration: 0.3) {
                                self.somethingElseTextView.frame.size.height -= 4
                            }
                        }
                    }
                }
            }
        }
    }
}

extension EmploymentController: UITextViewDelegate
{
    func textViewDidEndEditing(_ textView: UITextView)
    {
        UIView.animate(withDuration: 0.4) {
            self.view.frame.size.height = self.originalFrame.size.height
            self.somethingElseTextView.frame = self.originalSomethingElseTextViewFrame
        }
        
        createAccountController.continueButton.isEnabled = (employmentStatusSegmentedControl.selectedSegmentIndex > -1) || (textView.text.noWhiteSpaceLowerCaseString != "")  
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool
    {
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if (text == "\n")
        {
            textView.resignFirstResponder()
        }
        
        if text.noWhiteSpaceLowerCaseString != ""
        {
            employmentStatusSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView)
    {
        createAccountController.continueButton.isEnabled = (employmentStatusSegmentedControl.selectedSegmentIndex > -1) || (textView.text.noWhiteSpaceLowerCaseString != "")
    }
}
