//
//  SportsController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 20/08/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import MessageUI
import UIKit

class SportsController: UIViewController {
    
    //==================================================//
    
    /* MARK: - Interface Builder UI Elements */
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //==================================================//
    
    /* MARK: - Class-level Variable Declarations */
    
    var user: User!
    var sports: [String]!
    
    //==================================================//
    
    /* MARK: - Overridden Functions */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        user = (self.parent as! CardPageController).user!
        
        guard let unwrappedSports = user.factoidData.sports else {
            report("No sports!", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
            return
        }
        
        sports = unwrappedSports.1
        
        titleLabel.text = "🏈 \(user.firstName.uppercased()) PLAYS..."
        
        view.alpha = 1
        view.tag += 1
    }
}

//==================================================//

/* MARK: - Extensions */

/**/

/* MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout */
extension SportsController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //collectionView.contentInset.top = max((collectionView.frame.height - collectionView.contentSize.height) / 2, 0)
        
        //Where elements_count is the count of all your items in that
        //Collection view...
        let cellCount = CGFloat(sports.count)
        
        //If the cell count is zero, there is no point in calculating anything.
        if cellCount > 0 {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let cellWidth = flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing
            
            //20.00 was just extra spacing I wanted to add to my cell.
            let totalCellWidth = cellWidth*cellCount + 20.00 * (cellCount-1)
            let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right
            
            if (totalCellWidth < contentWidth) {
                //If the number of cells that exists take up less room than the
                //collection view width... then there is an actual point to centering them.
                
                //Calculate the right amount of padding to center the cells.
                let padding = (contentWidth - totalCellWidth) / 2.0
                return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
            } else {
                //Pretty much if the number of cells that exist take up
                //more room than the actual collectionView width, there is no
                // point in trying to center them. So we leave the default behavior.
                return UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
            }
        }
        
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sports.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SportCell", for: indexPath) as! SportCell
        
        currentCell.label.text = sports[indexPath.row].lowercased()
        
        let fittingSize = currentCell.label.fontSizeThatFits(nil)
        currentCell.label.font = UIFont(name: "SFUIText-Bold", size: fittingSize)
        
        currentCell.label.adjustsFontSizeToFitWidth = true
        
        //        let intrinsicSize = currentCell.label.intrinsicContentSize
        //        currentCell.frame.size.width = intrinsicSize.width + 10
        
        currentCell.backgroundColor = .lightGray
        roundBorders(currentCell)
        
        return currentCell
    }
}
