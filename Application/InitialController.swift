//
//  InitialController.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 04/08/2020.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import AVFoundation
import MessageUI
import UIKit

class InitialController: UIViewController {
    
    //==================================================//
    
    /* MARK: - Interface Builder UI Elements */
    
    @IBOutlet weak var titleLabel: UILabel!
    
    //==================================================//
    
    /* MARK: - Class-level Variable Declarations */
    
    //Other Declarations
    let applicationDelegate = UIApplication.shared.delegate! as! AppDelegate
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //==================================================//
    
    /* MARK: - Overridden Functions */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        
        playSound("tap")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        vibrate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
            self.applicationDelegate.currentlyAnimating = true
            
            self.playSound("tap")
            
            UIView.transition(with: self.titleLabel, duration: 0.15, options: .transitionCrossDissolve, animations: {
                [weak self] in
                self?.vibrate()
                self?.titleLabel.text = "gl"
            }) { (_) in
                self.playSound("tap")
                
                UIView.transition(with: self.titleLabel, duration: 0.15, options: .transitionCrossDissolve, animations: {
                    [weak self] in
                    self?.vibrate()
                    self?.titleLabel.text = "gla"
                }) { (_) in
                    self.playSound("tap")
                    
                    UIView.transition(with: self.titleLabel, duration: 0.15, options: .transitionCrossDissolve, animations: {
                        [weak self] in
                        self?.vibrate()
                        self?.titleLabel.text = "glai"
                    }) { (_) in
                        self.playSound("tap")
                        
                        UIView.transition(with: self.titleLabel, duration: 0.15, options: .transitionCrossDissolve, animations: {
                            [weak self] in
                            self?.vibrate()
                            self?.titleLabel.text = "glaid"
                        }) { (_) in
                            self.playSound("send")
                            
                            self.applicationDelegate.currentlyAnimating = false
                            self.performSegue(withIdentifier: "initialSegue", sender: self)
                        }
                    }
                }
            }
        }
    }
    
    //==================================================//
    
    /* MARK: - Other Functions */
    
    func playSound(_ named: String) {
        if let soundURL = Bundle.main.url(forResource: named, withExtension: "m4a") {
            var playableSound: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &playableSound)
            AudioServicesPlaySystemSound(playableSound)
        }
    }
    
    func vibrate() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }
}
