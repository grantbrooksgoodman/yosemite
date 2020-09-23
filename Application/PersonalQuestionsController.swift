//
//  PersonalQuestionsController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 04/08/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit

class PersonalQuestionsController: UIViewController, MFMailComposeViewControllerDelegate
{
    //--------------------------------------------------//
    
    /* Interface Builder UI Elements */
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var cancelButton: ShadowButton!
    @IBOutlet weak var doneButton: ShadowButton!
    
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    var buildInstance: Build!
    
    var personalQuestions: [PersonalQuestion] = []
    
    //--------------------------------------------------//
    
    /* Initialiser Function */
    
    func initialiseController()
    {
        lastInitialisedController = self
        buildInstance = Build(self)
    }
    
    //--------------------------------------------------//
    
    /* Overridden Functions */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initialiseController()
        
        personalQuestions = [PersonalQuestion(title: "After work I like to...", text: nil),
                             PersonalQuestion(title: "Berkeley sex location bucket list...", text: nil),
                             PersonalQuestion(title: "I love it when...", text: nil),
                             PersonalQuestion(title: "I promise that...", text: nil),
                             PersonalQuestion(title: "I would love to meet...", text: "Your mother"),
                             PersonalQuestion(title: "It's a perfect match if...", text: nil),
                             PersonalQuestion(title: "My dealbreakers are...", text: nil),
                             PersonalQuestion(title: "My death row meal would be...", text: nil),
                             PersonalQuestion(title: "My favourite Cal memory was when...", text: nil),
                             PersonalQuestion(title: "My favourite quality in a person is...", text: nil),
                             PersonalQuestion(title: "My favourite website is...", text: nil),
                             PersonalQuestion(title: "My friends describe me as...", text: nil),
                             PersonalQuestion(title: "My secret superpower is...", text: "Flying"),
                             PersonalQuestion(title: "Never have I ever...", text: nil),
                             PersonalQuestion(title: "Nothing's better than...", text: nil),
                             PersonalQuestion(title: "When nobody's looking, I...", text: nil)]
        
        textView.delegate = self
        textView.textColor = .lightGray
        
        tableView.dataSource = self
        tableView.delegate = self
        
        cancelButton.initialiseLayer(animateTouches: true,
                                     backgroundColour: UIColor(hex: 0xE95A53),
                                     customBorderFrame: nil,
                                     customCornerRadius: nil,
                                     shadowColour: UIColor(hex: 0xD5443B).cgColor,
                                     instanceName: nil)
        
        doneButton.initialiseLayer(animateTouches: true,
                                   backgroundColour: UIColor(hex: 0x60C129),
                                   customBorderFrame: nil,
                                   customCornerRadius: nil,
                                   shadowColour: UIColor(hex: 0x3B9A1B).cgColor,
                                   instanceName: nil)
        
        //Add a rounded border to the text view.
        textView.layer.borderWidth  = 2
        textView.layer.cornerRadius = 10
        
        textView.layer.borderColor = UIColor(hex: 0xE1E0E1).cgColor
        
        textView.clipsToBounds       = true
        textView.layer.masksToBounds = true
        
        title = "Personal Questions"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        currentFile = #file
        buildInfoController?.view.isHidden = false
    }
    
    //--------------------------------------------------//
    
    /* Interface Builder Actions */
    
    @IBAction func cancelButton(_ sender: Any)
    {
        textView.resignFirstResponder()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.tableView.alpha = 1
        })
    }
    
    @IBAction func doneButton(_ sender: Any)
    {
        textView.resignFirstResponder()
        
        personalQuestions = personalQuestions.filter({$0.title != titleLabel.text})
        
        personalQuestions.append(PersonalQuestion(title: titleLabel.text!, text: textView.text))
        tableView.reloadData()
        
        for individualCell in tableView.subviews
        {
            if let individualCell = individualCell as? PersonalQuestionCell
            {
                individualCell.textView.alpha = 1
            }
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.tableView.alpha = 1
        })
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
            
            cancelButton.frame.origin.y = minimumValue - (cancelButton.frame.height + 10)
            doneButton.frame.origin.y = minimumValue - (doneButton.frame.height + 10)
            textView.frame.size.height = doneButton.frame.origin.y - (doneButton.frame.height + 100)
            
            UIView.animate(withDuration: 0.2, animations: {
                self.cancelButton.alpha = 1
                self.doneButton.alpha = 1
                self.textView.alpha = 1
                self.titleLabel.alpha = 1
            })
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        buildInstance.handleMailComposition(withController: controller, withResult: result, withError: error)
    }
    
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
            forShadowButton.setTitle("?", for: .normal)
            forShadowButton.titleLabel!.font = UIFont(name: "SFUIText-Heavy", size: 17)
            forShadowButton.initialiseLayer(animateTouches: false,
                                            backgroundColour: .orange /*UIColor(hex: 0xE95A53)*/,
                customBorderFrame: nil,
                customCornerRadius: nil,
                shadowColour: UIColor.clear.cgColor,
                instanceName: nil)
        }
    }
}

extension PersonalQuestionsController: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 0
        {
            return "Answered"
        }
        else
        {
            return "Unanswered"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return personalQuestions.filter({$0.text != nil}).count
        }
        else
        {
            return personalQuestions.filter({$0.text == nil}).count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 0
        {
            return 150
        }
        else
        {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let currentCell = tableView.dequeueReusableCell(withIdentifier: "PersonalQuestionCell") as! PersonalQuestionCell
        
        let answeredQuestions = personalQuestions.filter({$0.text != nil})
        let unansweredQuestions = personalQuestions.filter({$0.text == nil})
        
        if indexPath.section == 0
        {
            currentCell.titleLabel.text = answeredQuestions[indexPath.row].title
            currentCell.textView.text = answeredQuestions[indexPath.row].text!
            toggleCheckmark(currentCell.tickButton, isChecked: true)
            
            //currentCell.textView.font = UIFont(name: "SFUIText-Bold", size: 20)
            currentCell.textView.textColor = .black
            //currentCell.textView.textAlignment = .center
        }
        else
        {
            currentCell.titleLabel.text = unansweredQuestions[indexPath.row].title
            //currentCell.tickButton.frame.origin.y = currentCell.titleLabel.frame.origin.y - 5
            //currentCell.textView.alpha = 0
            
            toggleCheckmark(currentCell.tickButton, isChecked: false)
        }
        
        return currentCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let answeredQuestions = personalQuestions.filter({$0.text != nil})
        let unansweredQuestions = personalQuestions.filter({$0.text == nil})
        
        if indexPath.section == 0
        {
            titleLabel.text = answeredQuestions[indexPath.row].title
            
            UIView.animate(withDuration: 0.2, animations: {
                tableView.alpha = 0
                tableView.deselectRow(at: indexPath, animated: true)
            }) { (_) in
                self.textView.becomeFirstResponder()
            }
        }
        else
        {
            titleLabel.text = unansweredQuestions[indexPath.row].title
            
            UIView.animate(withDuration: 0.2, animations: {
                tableView.alpha = 0
                tableView.deselectRow(at: indexPath, animated: true)
            }) { (_) in
                self.textView.becomeFirstResponder()
            }
        }
    }
}

extension PersonalQuestionsController: UITextViewDelegate
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
        doneButton(doneButton!)
        
        return true
    }
}

