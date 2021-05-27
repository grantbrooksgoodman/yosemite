//
//  FactoidCardsController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 04/08/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import MessageUI
import UIKit

class FactoidCardsController: UIViewController, MFMailComposeViewControllerDelegate {
    
    //==================================================//
    
    /* MARK: - Interface Builder UI Elements */
    
    @IBOutlet weak var tableView: UITableView!
    
    //==================================================//
    
    /* MARK: - Class-level Variable Declarations */
    
    //Arrays
    var factoidCards: [FactoidCard]!
    var originallyOrderedCards: [FactoidCard]!
    
    //Other Declarations
    var buildInstance: Build!
    var currentIndexPath: IndexPath?
    var originalContentOffset: CGPoint?
    
    //==================================================//
    
    /* MARK: - Initializer Function */
    
    func initializeController() {
        lastInitializedController = self
        buildInstance = Build(self)
    }
    
    //==================================================//
    
    /* MARK: - Overridden Functions */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.transition(with: self.navigationController!.navigationBar, duration: 0.1, options: [.transitionCrossDissolve], animations: {
            self.title = "Factoid Cards"
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeController()
        
        let quickFactsCard = FactoidCard(title: "Quick Facts Card",
                                         subtitle: "Displays basic information about your profile",
                                         isEditable: false,
                                         isHidden: false,
                                         isRequired: true,
                                         viewController: UIStoryboard(name: "ExpandedCard", bundle: nil).instantiateViewController(withIdentifier: "QuickFactsController"))
        
        let sportsCard = FactoidCard(title: "Sports Card",
                                     subtitle: "Show off any sports you play",
                                     isEditable: true,
                                     isHidden: currentUser!.factoidData.sports?.0.1 ?? true,
                                     isRequired: false,
                                     viewController: genericCard(title: "🏈 \(currentUser!.firstName.uppercased()) PLAYS", content: "\(currentUser!.factoidData.sports?.1.joined(separator: ", ") ?? "none")"))
        
        let glo = currentUser!.factoidData.greekLifeOrganisation?.1 ?? "none"
        
        let gloCard = FactoidCard(title: "Greek Life Card",
                                  subtitle: "Let people know that you're in a Greek life organisation",
                                  isEditable: true,
                                  isHidden: currentUser!.factoidData.greekLifeOrganisation?.0.1 ?? true,
                                  isRequired: false,
                                  viewController: genericCard(title: "⚔️ GREEK LIFE ORGANISATION", content:
                                                                "\(glo == "!" ? "none" : glo)"))
        
        let openToCard = FactoidCard(title: "Open To Card",
                                     subtitle: "What are you looking for in a match?",
                                     isEditable: true,
                                     isHidden: false,
                                     isRequired: true,
                                     viewController: genericCard(title: "🔍 OPEN TO", content: currentUser!.factoidData.lookingFor?.joined(separator: ", ") ?? "nothing in particular"))
        
        factoidCards = [quickFactsCard, openToCard, sportsCard, gloCard]
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentFile = #file
        buildInfoController?.view.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        title = ""
    }
    
    //==================================================//
    
    /* MARK: - Other Functions */
    
    func genericCard(title: String, content: String) -> UIViewController {
        let withController = UIStoryboard(name: "ExpandedCard", bundle: nil).instantiateViewController(withIdentifier: "GenericController")
        
        if let genericController = withController as? GenericController
        {
            genericController.titleText = title
            genericController.content = content
        }
        
        return withController
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        buildInstance.handleMailComposition(withController: controller, withResult: result, withError: error)
    }
}

//==================================================//

/* MARK: - Extensions */

/**/

/* MARK: UITableViewDataSource, UITableViewDelegate */
extension FactoidCardsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return factoidCards.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //If the currently selected card is editable and a cell is not currently being edited already.
        if factoidCards[indexPath.row].isEditable && originalContentOffset == nil {
            //Get the currently selected «FactoidCardCell» and its associated view controller.
            if let currentCell = tableView.cellForRow(at: indexPath) as? FactoidCardCell,
               let cardView = factoidCards[indexPath.row].viewController.view {
                //Instantiate the text view to be added to the current cell.
                let textView = UITextView(frame: cardView.frame)
                textView.backgroundColor = cardView.backgroundColor
                textView.delegate = self
                textView.font = UIFont(name: "SFUIText-Regular", size: 20)
                textView.returnKeyType = .done
                
                if let genericController = factoidCards[indexPath.row].viewController as? GenericController {
                    if genericController.content != "none" && genericController.content != "" {
                        textView.text = genericController.content
                    }
                }
                
                roundBorders(textView)
                
                //Save the table view's original scroll position to be referenced later.
                self.originalContentOffset = tableView.contentOffset
                
                //If the index path (stored in the tag) is greater than can be displayed on a 5.8 inch screen.
                //i.e. The selected cell wouldn't be seen if the table view was scrolled to the top.
                #warning("The comparison value must be tailored to screen size.")
                if tableView.visibleCells.last!.tag > 2 {
                    //Animate the hiding of the table view and then scroll it to the top.
                    UIView.animate(withDuration: 0.15, animations: {
                        tableView.alpha = 0
                    }) { (_) in
                        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    }
                } else /* If the selected cell would be visible if the table view was scrolled to the top. */ {
                    //Scroll the table view to the top.
                    tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
                
                //After the table view has scrolled to the top (250 milliseconds).
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                    //If the last visible cell's index path is greater than or equal to that of the currently selected cell.
                    //i.e. The selected cell can be seen from the top of the table view.
                    if tableView.visibleCells.last!.tag >= indexPath.row {
                        //Set the global «currentIndexPath» variable to be referenced later.
                        self.currentIndexPath = indexPath
                        
                        //Move the currently selected cell to the top of the table view with an animation.
                        tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
                        
                        //Add a blur overlay to each of the cells besides the first.
                        for individualCell in tableView.visibleCells[1...tableView.visibleCells.count - 1] {
                            individualCell.addBlur(withActivityIndicator: false, withStyle: .regular, withTag: aTagFor("blur"), alpha: 0.95)
                        }
                        
                        currentCell.addSubview(textView)
                        currentCell.editLabel.alpha = 0
                    } else /* The selected cell can't be seen from the top of the table view. */ {
                        //Set the global «originallyOrderedCards» variable to the value of the factoid card array pre-modification.
                        self.originallyOrderedCards = self.factoidCards
                        
                        //Create a backup reference to the currently selected factoid card.
                        let currentCard = self.factoidCards[indexPath.row]
                        
                        //Remove the current card from the factoid card array.
                        self.factoidCards.remove(at: self.factoidCards.firstIndex(where: {$0.viewController.view == cardView})!)
                        
                        //Create a new factoid card array with the current card at the front and the rest appended behind.
                        //Then set the global «factoidCards» array to this new array.
                        var newCards = [currentCard]
                        newCards.append(contentsOf: self.factoidCards)
                        self.factoidCards = newCards
                        
                        //Reload the table view with the new factoid cards array and scroll it to the top.
                        tableView.reloadData()
                        
                        //Add a blur overlay to each of the cells besides the first.
                        for individualCell in tableView.visibleCells[1...tableView.visibleCells.count - 1] {
                            individualCell.addBlur(withActivityIndicator: false, withStyle: .regular, withTag: aTagFor("blur"), alpha: 0.95)
                        }
                        
                        //Get the first cell in the table view.
                        if let firstCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? FactoidCardCell {
                            //Add the text view to the first cell.
                            firstCell.addSubview(textView)
                            firstCell.editLabel.alpha = 0
                        }
                    }
                    
                    //Animate the reappearance of the table view.
                    UIView.animate(withDuration: 0.15, animations: {
                        tableView.alpha = 1
                    }) { (_) in
                        //After the animation has finished, show the keyboard associated with the new text view and disable scrolling on the table view.
                        textView.becomeFirstResponder()
                        
                        tableView.isScrollEnabled = false
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentCell = tableView.dequeueReusableCell(withIdentifier: "FactoidCardCell") as! FactoidCardCell
        let currentFactoidCard = factoidCards[indexPath.row]
        
        currentCell.titleLabel.text = currentFactoidCard.title!.uppercased()
        currentCell.subtitleLabel.text = currentFactoidCard.subtitle!
        
        currentCell.editLabel.alpha = currentFactoidCard.isEditable ? 1 : 0
        currentCell.requiredLabel.alpha = currentFactoidCard.isRequired ? 1 : 0
        currentCell.showRadioButton.alpha = currentFactoidCard.isRequired ? 0 : 1
        
        currentCell.showRadioButton.isSelected = !currentFactoidCard.isHidden
        
        currentCell.editLabel.attributedText = NSAttributedString(string: "Tap card to edit info", attributes:  [.underlineStyle: NSUnderlineStyle.single.rawValue])
        
        if currentFactoidCard.isEditable && currentFactoidCard.isRequired && originalContentOffset == nil {
            currentCell.requiredLabel.frame.origin.y += 8
        }
        
        let cardView = factoidCards[indexPath.row].viewController.view!
        cardView.frame = currentCell.cardView.frame
        cardView.tag = aTagFor("cardView")
        
        if indexPath.row % 2 == 0 {
            currentCell.backgroundColor = .white
            cardView.backgroundColor = UIColor(hex: 0xF4F5F5)
        } else {
            currentCell.backgroundColor = UIColor(hex: 0xF4F5F5)
            cardView.backgroundColor = .white
        }
        
        currentCell.addSubview(cardView)
        roundBorders(cardView)
        
        currentCell.tag = indexPath.row
        
        return currentCell
    }
}

/* MARK: UITextViewDelegate */
extension FactoidCardsController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        //UserSerializer().updateCurrentUserData(type: self.factoidCards[indexPath.row].dataType, with: returnedString.removingLeadingWhitespace().removingTrailingWhitespace())
        
        //Remove the blur overlay applied to cells besides the first.
        for individualCell in tableView.visibleCells[1...tableView.visibleCells.count - 1] {
            individualCell.removeBlur(withTag: aTagFor("blur"))
        }
        
        //If the text field was on a card that could not be seen from the top of the table view.
        if let orderedCards = originallyOrderedCards {
            //Animate the hiding of the table view.
            UIView.animate(withDuration: 0.15, animations: {
                self.tableView.alpha = 0
            }) { (_) in
                //Remove the text view from the cell.
                textView.removeFromSuperview()
                
                //Restore the original state of the table view before editing began.
                self.factoidCards = orderedCards
                
                self.tableView.reloadData()
                self.tableView.setContentOffset(self.originalContentOffset!, animated: false)
                self.tableView.isScrollEnabled = true
                
                //Animate the reappearance of the table view.
                UIView.animate(withDuration: 0.15, animations: {
                    self.tableView.alpha = 1
                }) { (_) in
                    //After the table view has reappeared, reset the value of «originallyOrderedCards» and «originalContentOffset» to nil.
                    self.originallyOrderedCards = nil
                    self.originalContentOffset = nil
                }
            }
        } else /* If the text field was on a card that COULD be seen from the top of the table view. */ {
            //Unwrap the gloabl «currentIndexPath» variable and get the card view associated with it.
            if let indexPath = currentIndexPath,
               let firstCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? FactoidCardCell {
                //Remove the text view from the cell.
                textView.removeFromSuperview()
                firstCell.editLabel.alpha = 1
                
                //Restore the original state of the table view before editing began.
                tableView.moveRow(at: IndexPath(row: 0, section: 0), to: indexPath)
                tableView.setContentOffset(originalContentOffset!, animated: false)
                tableView.isScrollEnabled = true
                
                //Reset the value of «currentIndexPath» and «originalContentOffset» to nil.
                currentIndexPath = nil
                originalContentOffset = nil
            }
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
    }
}
