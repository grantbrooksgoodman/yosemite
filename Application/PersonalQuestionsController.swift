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
import SwiftRandom

class PersonalQuestionsController: UIViewController, MFMailComposeViewControllerDelegate
{
    //--------------------------------------------------//
    
    /* Interface Builder UI Elements */
    
    //ShadowButtons
    @IBOutlet weak var cancelButton: ShadowButton!
    @IBOutlet weak var doneButton:   ShadowButton!
    
    //Other Elements
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    //Arrays
    var answeredQuestions:   [PersonalQuestion] = []
    var questionTitles =                          ["After work I like to...",
                                                   "Berkeley bucket list...",
                                                   "I love it when...",
                                                   "I promise that...",
                                                   "I would love to meet...",
                                                   "It's a perfect match if...",
                                                   "My dealbreakers are...",
                                                   "My death row meal would be...",
                                                   "My favourite Cal memory was when...",
                                                   "My favourite quality in a person is...",
                                                   "My favourite website is...",
                                                   "My friends describe me as...",
                                                   "My secret superpower is...",
                                                   "Never have I ever...",
                                                   "Nothing's better than...",
                                                   "When nobody's looking, I..."]
    var unansweredQuestions: [PersonalQuestion] = []
    
    //Other Elements
    var buildInstance: Build!
    
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
        
        //O(n)
        //Loop through each question in the array of question titles.
        for question in questionTitles
        {
            /*If the current User has answered questions,
             AND there are some titles that match up with them,
             AND if each question title can be found in the array.*/
            if let questionsAnswered = currentUser!.questionsAnswered,
                questionsAnswered.filter({$0.title == question}).count > 0,
                let index = questionsAnswered.firstIndex(where: {$0.title == question})
            {
                //Append the question with the answer to the array of Personal Questions.
                answeredQuestions.append(PersonalQuestion(title: question, text: questionsAnswered[index].text!))
            }
            else
            { /*If none of the above applied, i.e.
                 no answered questions ||
                 no titles match up ||
                 a question title couldn't be found in the array.*/
                
                //Append the question without an answer to the array of Personal Questions.
                unansweredQuestions.append(PersonalQuestion(title: question, text: nil))
            }
        }
        
        //If there are no questions that have been answered.
        if answeredQuestions.count == 0
        {
            //Disable the Edit button.
            editButton.tintColor = .clear
            editButton.isEnabled = false
        }
        
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
        var alreadyAnswered = false
        
        if textView.text.noWhiteSpaceLowerCaseString != ""
        {
            if let questionsAnswered = currentUser!.questionsAnswered
            {
                if questionsAnswered.filter({$0.title == titleLabel.text}).count > 0,
                    let index = questionsAnswered.firstIndex(where: {$0.title == titleLabel.text})
                {
                    currentUser!.questionsAnswered![index] = PersonalQuestion(title: titleLabel.text!, text: textView.text)
                    answeredQuestions[index].text = textView.text
                    alreadyAnswered = true
                }
                else
                {
                    if let index = unansweredQuestions.firstIndex(where: {$0.title == titleLabel.text!})
                    {
                        unansweredQuestions.remove(at: index)
                        answeredQuestions.append(PersonalQuestion(title: titleLabel.text!, text: textView.text))
                    }
                    
                    currentUser!.questionsAnswered!.append(PersonalQuestion(title: titleLabel.text!, text: textView.text))
                }
            }
            else
            {
                currentUser!.questionsAnswered = [PersonalQuestion(title: titleLabel.text!, text: textView.text)]
            }
        }
        
        if let index = (alreadyAnswered ? answeredQuestions : unansweredQuestions).firstIndex(where: {$0.title == titleLabel.text!})
        {
            (alreadyAnswered ? answeredQuestions : unansweredQuestions)[index].text = textView.text == "" ? nil : textView.text
            
            if let index = currentUser!.questionsAnswered?.firstIndex(where: {$0.title == titleLabel.text!})
            {
                currentUser!.questionsAnswered![index] = PersonalQuestion(title: titleLabel.text!, text: textView.text == "" ? nil : textView.text)
            }
        }
        
        tableView.reloadData()
        
        GenericSerialiser().updateValue(onKey: "/allUsers/\(currentUser!.associatedIdentifier!)/", withData: ["questionsAnswered": currentUser!.serialiseQuestionsAnswered()]) { (setValueError) in
            if let setValueError = setValueError
            {
                report(setValueError.localizedDescription, errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                
                AlertKit().errorAlertController(title: "Unable to edit question",
                                                message: nil,
                                                dismissButtonTitle: nil,
                                                additionalSelectors: nil,
                                                preferredAdditionalSelector: nil,
                                                canFileReport: true,
                                                extraInfo: "\(setValueError.localizedDescription) (\((setValueError as NSError).code))",
                    metadata: [#file, #function, #line],
                    networkDependent: true)
            }
            else
            {
                
                self.textView.resignFirstResponder()
                
                for individualCell in self.tableView.subviews
                {
                    if let individualCell = individualCell as? PersonalQuestionCell
                    {
                        individualCell.textView.alpha = 1
                    }
                }
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.tableView.alpha = 1
                })
                
                self.textView.text = ""
            }
        }
    }
    
    @IBAction func editButton(_ sender: Any)
    {
        tableView.isEditing = editButton.titleLabel!.text! == "Edit" ? true : false
        editButton.setTitle(editButton.titleLabel!.text! == "Edit" ? "Done" : "Edit", for: .normal)
        
        if editButton.titleLabel!.text! == "Done"
        {
            for cell in tableView.visibleCells
            {
                if let cell = cell as? PersonalQuestionCell
                {
                    cell.textView.frame.size.width += 70
                    cell.titleLabel.frame.size.width += 70
                }
            }
            
            currentUser!.questionsAnswered = answeredQuestions
            
            GenericSerialiser().updateValue(onKey: "/allUsers/\(currentUser!.associatedIdentifier!)/", withData: ["questionsAnswered": currentUser!.serialiseQuestionsAnswered()]) { (setValueError) in
                if let setValueError = setValueError
                {
                    report(setValueError.localizedDescription, errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                    
                    AlertKit().errorAlertController(title: "Unable to reorder",
                                                    message: nil,
                                                    dismissButtonTitle: nil,
                                                    additionalSelectors: nil,
                                                    preferredAdditionalSelector: nil,
                                                    canFileReport: true,
                                                    extraInfo: "\(setValueError.localizedDescription) (\((setValueError as NSError).code))",
                        metadata: [#file, #function, #line],
                        networkDependent: true)
                }
                else
                {
                    print("reorder successful")
                }
            }
        }
        else
        {
            for cell in tableView.visibleCells
            {
                if let cell = cell as? PersonalQuestionCell
                {
                    cell.textView.frame.size.width -= 70
                    cell.titleLabel.frame.size.width -= 70
                }
            }
        }
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
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        if indexPath.section == 0
        {
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath
    {
        if sourceIndexPath.section != proposedDestinationIndexPath.section
        {
            var row = 0
            
            if sourceIndexPath.section < proposedDestinationIndexPath.section
            {
                row = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
            }
            
            return IndexPath(row: row, section: sourceIndexPath.section)
        }
        
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        let movedObject = answeredQuestions[sourceIndexPath.row]
        
        answeredQuestions[sourceIndexPath.row] = answeredQuestions[destinationIndexPath.row]
        answeredQuestions[destinationIndexPath.row] = movedObject
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            let unansweredQuestion = answeredQuestions[indexPath.row]
            
            if let questionsAnswered = currentUser!.questionsAnswered,
                questionsAnswered.filter({$0.title == unansweredQuestion.title}).count > 0,
                let index = questionsAnswered.firstIndex(where: {$0.title == unansweredQuestion.title})
            {
                currentUser!.questionsAnswered!.remove(at: index)
            }
            
            GenericSerialiser().updateValue(onKey: "/allUsers/\(currentUser!.associatedIdentifier!)/", withData: ["questionsAnswered": currentUser!.serialiseQuestionsAnswered()]) { (updateValueError) in
                if let updateValueError = updateValueError as NSError?
                {
                    report(updateValueError.localizedDescription, errorCode: updateValueError.code, isFatal: false, metadata: [#file, #function, #line])
                    
                    AlertKit().errorAlertController(title: "Couldn't delete question",
                                                    message: nil,
                                                    dismissButtonTitle: nil,
                                                    additionalSelectors: nil,
                                                    preferredAdditionalSelector: nil,
                                                    canFileReport: true,
                                                    extraInfo: "\(updateValueError.localizedDescription) (\(updateValueError.code)",
                        metadata: [#file, #function, #line],
                        networkDependent: true)
                }
                else
                {
                    report("Deleted Question successfully.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                    
                    unansweredQuestion.text = nil
                    
                    self.unansweredQuestions.append(unansweredQuestion)
                    self.unansweredQuestions = self.unansweredQuestions.sorted(by: {$0.title < $1.title})
                    
                    self.answeredQuestions.remove(at: indexPath.row)
                    
                    tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        if indexPath.section == 0
        {
            return .delete
        }
        
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool
    {
        return false
    }
    
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
            return answeredQuestions.count
        }
        else
        {
            return unansweredQuestions.count
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
        
        //If the index path is for the answered questions.
        if indexPath.section == 0
        {
            //Set the current cell's text containers according to the answered questions array.
            currentCell.titleLabel.text = answeredQuestions[indexPath.row].title
            currentCell.textView.text = answeredQuestions[indexPath.row].text!
            toggleCheckmark(currentCell.tickButton, isChecked: true)
            
            //currentCell.textView.font = UIFont(name: "SFUIText-Bold", size: 20)
            currentCell.textView.textColor = .black
            //currentCell.textView.textAlignment = .center
        }
        else
        { //If the index path is for the unanswered questions.
            
            //Set the current cell's text containers according to the unanswered questions array.
            currentCell.titleLabel.text = unansweredQuestions[indexPath.row].title
            //currentCell.tickButton.frame.origin.y = currentCell.titleLabel.frame.origin.y - 5
            //currentCell.textView.alpha = 0
            
            toggleCheckmark(currentCell.tickButton, isChecked: false)
        }
        
        return currentCell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.section == 0
        {
            titleLabel.text = answeredQuestions[indexPath.row].title
            textView.text = answeredQuestions[indexPath.row].text ?? ""
            
            UIView.animate(withDuration: 0.15, animations: {
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
            //textView.text = ""
            textView.textColor = .black
        }
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool
    {
        //doneButton(doneButton!)
        
        return true
    }
}
