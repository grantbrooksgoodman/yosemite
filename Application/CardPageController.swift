//
//  CardPageController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 20/08/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import MessageUI
import UIKit

class CardPageController: UIPageViewController {
    
    //==================================================//
    
    /* MARK: - Class-level Variable Declarations */
    
    weak var cardPageDelegate: CardPageControllerDelegate?
    
    //    private(set) lazy var orderedViewControllers: [UIViewController] = {
    //        return [self.expandedCard("QuickFacts"),
    //                self.expandedCard("Sports")]
    //    }()
    
    var orderedViewControllers: [UIViewController]!
    
    var user: User!
    var pageControl: UIPageControl!
    
    var displaysFactoids = true {
        didSet {
            if displaysFactoids {
                orderedViewControllers = displaysFactoids == true ? [UIStoryboard(name: "ExpandedCard", bundle: nil).instantiateViewController(withIdentifier: "QuickFactsController"), self.genericCard(title: "⚔️ GREEK LIFE ORGANISATION", content: "Pi Kappa Phi"), self.genericCard(title: "🔍 OPEN TO", content: user.factoidData.lookingFor?.joined(separator: ", ") ?? "nothing in particular")] : [self.genericCard(title: "❓ After work I like to...", content: "cook"), self.genericCard(title: "❓ I promise that...", content: "I'll never cheat"), self.genericCard(title: "❓ Never have I ever...", content: "been to DisneyLand")]
                
                if let sportsCard = self.sportsCard(), displaysFactoids {
                    orderedViewControllers.append(sportsCard)
                }
            } else {
                if let questionsAnswered = user.questionsAnswered {
                    orderedViewControllers = []
                    
                    for question in questionsAnswered {
                        orderedViewControllers.append(self.genericCard(title: "❓ \(question.title!)", content: question.text!))
                    }
                } else {
                    orderedViewControllers = [self.genericCard(title: "❓ After work I like to...", content: "cook"), self.genericCard(title: "❓ I promise that...", content: "I'll never cheat"), self.genericCard(title: "❓ Never have I ever...", content: "been to DisneyLand")]
                }
            }
            
            pageControl.numberOfPages = orderedViewControllers.count
            pageControl.currentPage = 0
            
            scrollToViewController(viewController: orderedViewControllers.first!)
        }
    }
    
    //==================================================//
    
    /* MARK: - Overridden Functions */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if displaysFactoids {
            orderedViewControllers = [UIStoryboard(name: "ExpandedCard", bundle: nil).instantiateViewController(withIdentifier: "QuickFactsController")]
            
            orderedViewControllers.append(self.genericCard(title: "🔍 OPEN TO", content: user.factoidData.lookingFor?.joined(separator: ", ") ?? "nothing in particular"))
            
            var orderedCards: [Int : UIViewController] = [:]
            
            if let callsHome = user.factoidData.callsHome, callsHome.0.1 == false {
                let callsHomeCard = self.genericCard(title: "🏠 \(user.firstName.uppercased()) IS FROM", content: callsHome.1)
                
                if let lastValue = Array(orderedCards.keys).last {
                    orderedCards[lastValue + 1] = callsHomeCard
                } else {
                    orderedCards[0] = callsHomeCard
                }
            }
            
            if let sports = user.factoidData.sports,
               sports.0.1 == false,
               let sportsCard = sportsCard() {
                if let lastValue = Array(orderedCards.keys).last {
                    orderedCards[lastValue + 1] = sportsCard
                } else {
                    orderedCards[0] = sportsCard
                }
            }
            
            if let greekLifeOrganisation = user.factoidData.greekLifeOrganisation, greekLifeOrganisation.0.1 == false {
                let greekLifeOrganisationCard = self.genericCard(title: "⚔️ GREEK LIFE ORGANISATION", content: greekLifeOrganisation.1)
                
                if let lastValue = Array(orderedCards.keys).last {
                    orderedCards[lastValue + 1] = greekLifeOrganisationCard
                } else {
                    orderedCards[0] = greekLifeOrganisationCard
                }
            }
            
            for position in Array(orderedCards.keys).sorted() {
                orderedViewControllers.append(orderedCards[position]!)
            }
        } else {
            if let questionsAnswered = user.questionsAnswered {
                for question in questionsAnswered {
                    orderedViewControllers.append(self.genericCard(title: question.title, content: question.text!))
                }
            } else {
                orderedViewControllers = [self.genericCard(title: "❓ After work I like to...", content: "cook"), self.genericCard(title: "❓ I promise that...", content: "I'll never cheat"), self.genericCard(title: "❓ Never have I ever...", content: "been to DisneyLand")]
            }
        }
        
        view.tag = aTagFor("cardPageController")
        
        dataSource = self
        delegate = self
        
        pageControl = UIPageControl(frame: CGRect(x: 0, y: 120, width: view.frame.size.width, height: 40))
        pageControl.numberOfPages = orderedViewControllers.count
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPage = 0
        
        view.addSubview(pageControl)
        view.bringSubviewToFront(pageControl)
        
        pageControl.center.x = view.center.x
        
        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(viewController: initialViewController)
        }
        
        cardPageDelegate?.cardPageController(cardPageController: self, didUpdatePageCount: orderedViewControllers.count)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //==================================================//
    
    /* MARK: - Other Functions */
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
           let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController) {
            scrollToViewController(viewController: nextViewController)
        }
    }
    
    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
           let currentIndex = orderedViewControllers.firstIndex(of: firstViewController) {
            let direction: UIPageViewController.NavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(viewController: nextViewController, direction: direction)
        }
    }
    
    func genericCard(title: String, content: String) -> UIViewController {
        let withController = UIStoryboard(name: "ExpandedCard", bundle: nil).instantiateViewController(withIdentifier: "GenericController")
        
        if let genericController = withController as? GenericController {
            genericController.titleText = title
            genericController.content = content
        }
        
        return withController
    }
    
    func sportsCard() -> UIViewController? {
        if let sports = user.factoidData.sports {
            let withController = UIStoryboard(name: "ExpandedCard", bundle: nil).instantiateViewController(withIdentifier: "SportsController")
            
            if let sportsController = withController as? SportsController {
                sportsController.sports = sports.1
            }
            
            return withController
        }
        
        return nil
    }
    
    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    private func scrollToViewController(viewController: UIViewController, direction: UIPageViewController.NavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (finished) -> Void in
                            // Setting the view controller programmatically does not fire
                            // any delegate methods, so we have to manually notify the
                            // 'cardPageDelegate' of the new index.
                            self.notifyCardPageDelegateOfNewIndex()
                           })
    }
    
    /**
     Notifies '_cardPageDelegate' that the current page index was updated.
     */
    private func notifyCardPageDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
           let index = orderedViewControllers.firstIndex(of: firstViewController) {
            cardPageDelegate?.cardPageController(cardPageController: self, didUpdatePageIndex: index)
        }
    }
}

//==================================================//

/* MARK: - Extensions */

/**/

/* MARK: UIPageViewControllerDataSource */
extension CardPageController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}

/* MARK: UIPageViewControllerDelegate */
extension CardPageController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        //        if pendingViewControllers[0].view.tag < 1
        //        {
        //            if let cardController = lastInitializedController as? CardController,
        //                let kolodaView = cardController.kolodaView
        //            {
        //                if let cardView = kolodaView.viewForCard(at: kolodaView.currentCardIndex) as? CardView
        //                {
        //                    cardView.backgroundColor = .systemBackground
        //                    cardView.setNeedsDisplay()
        //                }
        //            }
        //        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let selectedVC = pageViewController.viewControllers?.first else {
            return
        }
        
        // and its index in the dataSource's controllers (I'm using force unwrap, since in my case pageViewController contains only view controllers from my dataSource)
        let selectedIndex = orderedViewControllers.firstIndex(of: selectedVC)!
        // and we update the current page in pageControl
        pageControl.numberOfPages = orderedViewControllers.count
        pageControl.currentPage = selectedIndex
        
        notifyCardPageDelegateOfNewIndex()
        
        //        if let cardController = lastInitializedController as? CardController,
        //            let kolodaView = cardController.kolodaView
        //        {
        //            if let cardView = kolodaView.viewForCard(at: kolodaView.currentCardIndex) as? CardView
        //            {
        //                cardView.backgroundColor = UIColor(hex: 0xE1E0E1)
        //                cardView.setNeedsDisplay()
        //            }
        //        }
    }
}

//==================================================//

/* MARK: - Protocols */

protocol CardPageControllerDelegate: class {
    /**
     Called when the number of pages is updated.
     
     - parameter cardPageController: the CardPageController instance
     - parameter count: the total number of pages.
     */
    func cardPageController(cardPageController: CardPageController,
                            didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter cardPageController: the CardPageController instance
     - parameter index: the index of the currently visible page.
     */
    func cardPageController(cardPageController: CardPageController,
                            didUpdatePageIndex index: Int)
}
