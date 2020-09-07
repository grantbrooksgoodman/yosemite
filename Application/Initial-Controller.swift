//
//  Initial-Controller.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 04/08/2020.
//  Copyright © 2013-2020 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import AVFoundation
import MessageUI
import UIKit

class IC: UIViewController
{
    //--------------------------------------------------//
    
    //Interface Builder User Interface Elements
    
    //Other Elements
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    //--------------------------------------------------//
    
    //Class-level Declarations
    
    //Other Declarations
    let applicationDelegate = UIApplication.shared.delegate! as! AppDelegate
    
    //Override Declarations
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    //--------------------------------------------------//
    
    //Override Functions
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        
        imageView.alpha = 0
        
        if let soundURL = Bundle.main.url(forResource: "tap", withExtension: "m4a")
        {
            var playableSound: SystemSoundID = 0
            
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &playableSound)
            AudioServicesPlaySystemSound(playableSound)
        }
        
        //        UIView.animate(withDuration: 3, delay: 0.3, options: UIView.AnimationOptions(), animations: { () -> Void in
        //            self.applicationDelegate.currentlyAnimating = true
        //
        //            if !preReleaseApplication
        //            {
        //                if let soundURL = Bundle.main.url(forResource: "Chime", withExtension: "mp3")
        //                {
        //                    var playableSound: SystemSoundID = 0
        //
        //                    AudioServicesCreateSystemSoundID(soundURL as CFURL, &playableSound)
        //                    AudioServicesPlaySystemSound(playableSound)
        //                }
        //            }
        //
        //            self.imageView.alpha = 1
        //        }, completion: { (finishedAnimating: Bool) -> Void in
        //            if finishedAnimating
        //            {
        //                self.applicationDelegate.currentlyAnimating = false
        //
        //                self.performSegue(withIdentifier: "initialSegue", sender: self)
        //            }
        //        })
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        let style: UIImpactFeedbackGenerator.FeedbackStyle = .rigid
        
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
            self.applicationDelegate.currentlyAnimating = true
            if let soundURL = Bundle.main.url(forResource: "tap", withExtension: "m4a")
            {
                var playableSound: SystemSoundID = 0
                AudioServicesCreateSystemSoundID(soundURL as CFURL, &playableSound)
                AudioServicesPlaySystemSound(playableSound)
            }
            UIView.transition(with: self.titleLabel, duration: 0.15, options: .transitionCrossDissolve, animations: {
                [weak self] in
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.impactOccurred()
                
                self?.titleLabel.text = "gl"
            }) { (_) in
                if let soundURL = Bundle.main.url(forResource: "tap", withExtension: "m4a")
                {
                    var playableSound: SystemSoundID = 0
                    
                    AudioServicesCreateSystemSoundID(soundURL as CFURL, &playableSound)
                    AudioServicesPlaySystemSound(playableSound)
                }
                UIView.transition(with: self.titleLabel, duration: 0.15, options: .transitionCrossDissolve, animations: {
                    [weak self] in
                    let generator = UIImpactFeedbackGenerator(style: style)
                    generator.impactOccurred()
                    self?.titleLabel.text = "gla"
                }) { (_) in
                    if let soundURL = Bundle.main.url(forResource: "tap", withExtension: "m4a")
                    {
                        var playableSound: SystemSoundID = 0
                        
                        AudioServicesCreateSystemSoundID(soundURL as CFURL, &playableSound)
                        AudioServicesPlaySystemSound(playableSound)
                    }
                    UIView.transition(with: self.titleLabel, duration: 0.15, options: .transitionCrossDissolve, animations: {
                        [weak self] in
                        let generator = UIImpactFeedbackGenerator(style: style)
                        generator.impactOccurred()
                        self?.titleLabel.text = "glai"
                    }) { (_) in
                        if let soundURL = Bundle.main.url(forResource: "tap", withExtension: "m4a")
                        {
                            var playableSound: SystemSoundID = 0
                            
                            AudioServicesCreateSystemSoundID(soundURL as CFURL, &playableSound)
                            AudioServicesPlaySystemSound(playableSound)
                        }
                        UIView.transition(with: self.titleLabel, duration: 0.15, options: .transitionCrossDissolve, animations: {
                            [weak self] in
                            let generator = UIImpactFeedbackGenerator(style: style)
                            generator.impactOccurred()
                            self?.titleLabel.text = "glaid"
                        }) { (_) in
                            if let soundURL = Bundle.main.url(forResource: "send", withExtension: "m4a")
                            {
                                var playableSound: SystemSoundID = 0
                                
                                AudioServicesCreateSystemSoundID(soundURL as CFURL, &playableSound)
                                AudioServicesPlaySystemSound(playableSound)
                            }
                            self.applicationDelegate.currentlyAnimating = false
                            
                            self.performSegue(withIdentifier: "initialSegue", sender: self)
                        }
                    }
                }
            }
        }
    }
    
    //--------------------------------------------------//
    
    //Interface Builder Actions
    
    @IBAction func skipButton(_ sender: Any)
    {
        applicationDelegate.currentlyAnimating = false
        
        self.performSegue(withIdentifier: "initialSegue", sender: self)
    }
}
