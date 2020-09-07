//
//  BiographicController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 16/06/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class BiographicController: UIViewController
{
    //--------------------------------------------------//
    
    //Interface Builder User Interface Elements
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var biographyTextView: UITextView!
    @IBOutlet weak var firstLivingSpaceImageView: UIImageView!
    @IBOutlet weak var secondLivingSpaceImageView: UIImageView!
    @IBOutlet weak var thirdLivingSpaceImageView: UIImageView!
    
    //--------------------------------------------------//
    
    //Class-level Declarations
    
    var biographyPlaceholder = "Add a short statement about yourself to be shown to shelters"
    var addImagePlaceholder = "Tap to add an image"
    var imagePicker: ImagePicker!
    
    var addImageRecogniser: UITapGestureRecognizer!
    
    //--------------------------------------------------//
    
    //Override Functions
    
    override func viewDidAppear(_ animated: Bool)
    {
        //Set up «biographyTextView» with a placeholder String.
        biographyTextView.text = biographyPlaceholder
        biographyTextView.textColor = .lightGray
        
        setUpViews()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        profileImageView.isUserInteractionEnabled = true
        firstLivingSpaceImageView.isUserInteractionEnabled = true
        secondLivingSpaceImageView.isUserInteractionEnabled = true
        thirdLivingSpaceImageView.isUserInteractionEnabled = true
        
        profileImageView.tag = aTagFor("profileImageView")
        firstLivingSpaceImageView.tag = aTagFor("firstLivingSpaceImageView")
        secondLivingSpaceImageView.tag = aTagFor("secondLivingSpaceImageView")
        thirdLivingSpaceImageView.tag = aTagFor("thirdLivingSpaceImageView")
        
        roundBorders(profileImageView)
        roundBorders(biographyTextView)
        roundBorders(firstLivingSpaceImageView)
        roundBorders(secondLivingSpaceImageView)
        roundBorders(thirdLivingSpaceImageView)
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    //--------------------------------------------------//
    
    //Independent Functions
    
    func setUpViews()
    {
        let imageViews = [profileImageView, firstLivingSpaceImageView, secondLivingSpaceImageView, thirdLivingSpaceImageView]
        
        for wrappedImageView in imageViews
        {
            if let imageView = wrappedImageView
            {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedLabel(_:)))
                
                let addLabel = UILabel(frame: CGRect(x: 2.5, y: 0, width: imageView.frame.size.width - 5, height: imageView.frame.size.height))
                addLabel.text = addImagePlaceholder
                addLabel.textColor = .black
                addLabel.font = UIFont(name: "SFUIText-Regular", size: 12)
                addLabel.numberOfLines = 2
                addLabel.textAlignment = .center
                addLabel.tag = imageView.tag + aTagFor("addLabel")
                addLabel.isUserInteractionEnabled = true
                addLabel.addGestureRecognizer(tapGesture)
                imageView.addSubview(addLabel)
                
                if languageCode != "en"
                {
                    addLabel.text = "+"
                    addLabel.font = UIFont(name: "SFUIText-Regular", size: 20)
                }
                
                imageView.bringSubviewToFront(addLabel)
            }
        }
    }
    
    @objc func tappedLabel(_ withGesture: UITapGestureRecognizer)
    {
        let imageViewTag = withGesture.view!.tag - aTagFor("addLabel")
        
        if let tappedImageView = view.findSubview(imageViewTag) as? UIImageView
        {
            imagePicker.displayRemove = tappedImageView.image != nil
            imagePicker.presentingImageView = imageViewTag
            
            self.imagePicker.present(from: withGesture.view!)
        }
    }
}

extension BiographicController: ImagePickerDelegate
{
    func didSelect(image: UIImage?)
    {
        if let presentingImageView = view.findSubview(imagePicker.presentingImageView) as? UIImageView,
            let addLabel = presentingImageView.findSubview(imagePicker.presentingImageView + aTagFor("addLabel")) as? UILabel
        {
            presentingImageView.image = image
            
            if image != nil
            {
                addLabel.text = ""
                //presentingImageView.addGestureRecognizer(addImageRecogniser)
                imagePicker.displayRemove = true
            }
            else
            {
                addLabel.text = addImagePlaceholder
                //addImageLabel.addGestureRecognizer(addImageRecogniser)
                imagePicker.displayRemove = false
            }
        }
    }
    
    func removeImage()
    {
        if let presentingImageView = view.findSubview(imagePicker.presentingImageView) as? UIImageView,
            let addLabel = presentingImageView.findSubview(imagePicker.presentingImageView + aTagFor("addLabel")) as? UILabel
        {
            presentingImageView.image = nil
            addLabel.text = addImagePlaceholder
            imagePicker.displayRemove = false
        }
    }
}

extension BiographicController: UITextViewDelegate
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
            textView.text = biographyPlaceholder
            textView.textColor = .lightGray
        }
        
        return true
    }
}
