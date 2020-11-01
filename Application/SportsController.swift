//
//  SportsController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 20/08/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import MessageUI
import UIKit

class SportsController: UIViewController
{
    //--------------------------------------------------//
    
    /* Interface Builder UI Elements */
    
    @IBOutlet weak var titleLabel: TranslatedLabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //--------------------------------------------------//
    
    /* Class-level Declarations */
    
    var user: User!
    var sports: [String]!
    
    //--------------------------------------------------//
    
    /* Overridden Functions */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //view.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        user = (self.parent as! CardPageController).user!
        
        guard let unwrappedSports = user.factoidData.sports else
        {
            report("No sports!", errorCode: nil, isFatal: true, metadata: [#file, #function, #line]); return
        }
        
        sports = unwrappedSports.1
        
        titleLabel.text = "🏈 \(user.firstName.uppercased()) PLAYS..."
        
        view.alpha = 1
        view.tag += 1
    }
    
    //--------------------------------------------------//
    
    /* Interface Builder Actions */
    
    //--------------------------------------------------//
    
    /* Independent Functions */
}

extension SportsController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return sports.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
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
