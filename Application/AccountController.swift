//
//  AccountController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 19/09/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit

class AccountController: UIViewController, MFMailComposeViewControllerDelegate
{
    //--------------------------------------------------//
    
    /* Interface Builder UI Elements */
    
    @IBOutlet weak var basicInfoEncapsulatingView: UIView!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var accountInfoTableView: UITableView!
    
    @IBOutlet weak var optionsTableView: UITableView!
    
    @IBOutlet weak var otherInfoTableView: UITableView!
    
    
    @IBOutlet weak var accountInfoLabel: UILabel!
    @IBOutlet weak var otherInfoLabel: UILabel!
    @IBOutlet weak var optionsLabel: UILabel!
    
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    var buildInstance: Build!
    var userDataTuples: [(String, String)]?
    var mutableDataTuples: [(String, String)]?
    
    let accountInfoTupleArray = [("Birthdate", masterDateFormatter.string(from: currentUser!.userData.birthDate)),
                                 ("E-mail",    currentUser!.emailAddress),
                                 ("Year",      currentUser!.factoidData.getYearString())]
    
    let otherInfoTupleArray = [("Gender",            currentUser!.factoidData.getGenderString(short: false)),
                               ("Major",             currentUser!.factoidData.major()),
                               ("Phone number",      currentUser!.phoneNumber),
                               ("Sexual preference", currentUser!.userData.getSexualPreferenceString())]
    
    let optionsArray = ["View your card", "Edit Factoid Cards", "Edit Personal Questions"]
    
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
        
        bioTextField.text = currentUser!.userData.bioText ?? ""
        nameLabel.text = "\(currentUser!.firstName!) \(currentUser!.lastName!)"
        
        if let imageDataArray = currentUser!.userData.profileImageData,
            let imageData = Data(base64Encoded: imageDataArray[0], options: .ignoreUnknownCharacters)
        {
            profileImageView.image = UIImage(data: imageData)
        }
        
        accountInfoTableView.tag = aTagFor("accountInfoTableView")
        otherInfoTableView.tag = aTagFor("otherInfoTableView")
        optionsTableView.tag = aTagFor("optionsTableView")
        
        roundBorders(profileImageView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.sizeAndShowTableViews()
        }
    }
    
    func sizeAndShowTableViews()
    {
        //accountInfoLabel is 5 under basicInfoEncapsulatingView
        //accountInfoTableView is 5 under accountInfoLabel
        //otherInfoLabel is 5 under accountInfoTableView
        //otherInfoTableView is 5 under otherInfoLabel
        //optionsLabel is 5 under otherInfoTableView
        //optionsTableView is 5 under optionsLabel
        
        accountInfoTableView.frame.size.height = accountInfoTableView.contentSize.height
        otherInfoTableView.frame.size.height = otherInfoTableView.contentSize.height
        optionsTableView.frame.size.height = optionsTableView.contentSize.height
        
        accountInfoLabel.frame.origin.y = basicInfoEncapsulatingView.frame.maxY + 15
        accountInfoTableView.frame.origin.y = accountInfoLabel.frame.maxY + 5
        
        otherInfoLabel.frame.origin.y = accountInfoTableView.frame.maxY + 15
        otherInfoTableView.frame.origin.y = otherInfoLabel.frame.maxY + 5
        
        optionsLabel.frame.origin.y = otherInfoTableView.frame.maxY + 15
        optionsTableView.frame.origin.y = optionsLabel.frame.maxY + 5
        
        UIView.animate(withDuration: 0.2) {
            self.accountInfoLabel.alpha = 1
            self.otherInfoLabel.alpha = 1
            self.optionsLabel.alpha = 1
            
            self.accountInfoTableView.alpha = 1
            self.otherInfoTableView.alpha = 1
            self.optionsTableView.alpha = 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        currentFile = #file
        buildInfoController?.view.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        title = ""
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        UIView.transition(with: self.navigationController!.navigationBar, duration: 0.1, options: [.transitionCrossDissolve], animations: {
            self.title = "Account"
        })
        
    }
    
    //--------------------------------------------------//
    
    /* Interface Builder Actions */
    
    //--------------------------------------------------//
    
    /* Independent Functions */
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        buildInstance.handleMailComposition(withController: controller, withResult: result, withError: error)
    }
}

extension AccountController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if UIScreen.main.bounds.height == 667
        {
            return 40
        }
        else if UIScreen.main.bounds.height == 568
        {
            return 32
        }
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tableView.tag == aTagFor("accountInfoTableView") ? accountInfoTupleArray.count : (tableView.tag == aTagFor("otherInfoTableView") ? otherInfoTupleArray.count : optionsArray.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView.tag == aTagFor("accountInfoTableView")
        {
            let currentCell = tableView.dequeueReusableCell(withIdentifier: "PreferenceCell") as! PreferenceCell
            
            currentCell.titleLabel.text = accountInfoTupleArray[indexPath.row].0
            currentCell.detailLabel.text = accountInfoTupleArray[indexPath.row].1
            
            if UIScreen.main.bounds.height == 667
            {
                currentCell.titleLabel.frame.size.height -= 4
                currentCell.detailLabel.frame.size.height -= 4
            }
            else if UIScreen.main.bounds.height == 568
            {
                currentCell.titleLabel.frame.size.height -= 12
                currentCell.detailLabel.frame.size.height -= 12
                
                currentCell.titleLabel.font = UIFont.systemFont(ofSize: 12)
                currentCell.detailLabel.font = UIFont.systemFont(ofSize: 12)
            }
            
            return currentCell
        }
        else if tableView.tag == aTagFor("otherInfoTableView")
        {
            let currentCell = tableView.dequeueReusableCell(withIdentifier: "MutableCell") as! PreferenceCell
            
            currentCell.titleLabel.text = otherInfoTupleArray[indexPath.row].0
            currentCell.detailLabel.text = otherInfoTupleArray[indexPath.row].1
            
            if UIScreen.main.bounds.height == 667
            {
                currentCell.titleLabel.frame.size.height -= 4
                currentCell.detailLabel.frame.size.height -= 4
            }
            else if UIScreen.main.bounds.height == 568
            {
                currentCell.titleLabel.frame.size.height -= 12
                currentCell.detailLabel.frame.size.height -= 12
                
                currentCell.titleLabel.font = UIFont.systemFont(ofSize: 12)
                currentCell.detailLabel.font = UIFont.systemFont(ofSize: 12)
            }
            
            return currentCell
        }
        else
        {
            let currentCell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            
            currentCell.textLabel!.text = optionsArray[indexPath.row]
            
            if UIScreen.main.bounds.height == 667
            {
                currentCell.textLabel!.frame.size.height -= 4
            }
            else if UIScreen.main.bounds.height == 568
            {
                currentCell.textLabel!.frame.size.height -= 12
                
                currentCell.textLabel!.font = UIFont.systemFont(ofSize: 12)
            }
            
            return currentCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.tag == aTagFor("optionsTableView")
        {
            if let currentCell = tableView.cellForRow(at: indexPath),
                let labelContent = currentCell.textLabel?.text
            {
                if labelContent == "Edit Factoid Cards"
                {
                    performSegue(withIdentifier: "factoidCardsFromAccountSegue", sender: self)
                }
                else if labelContent == "Edit Personal Questions"
                {
                    performSegue(withIdentifier: "personalQuestionsFromAccountSegue", sender: self)
                }
            }
        }
    }
}
