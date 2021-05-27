//
//  Frame-Calculator.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

class Frame
{
    //--------------------------------------------------//
    
    //Public Functions
    
    //--------------------------------------------------//
    
    //Enumerated Type Declarations
    enum DevelopmentEnvironment {
        case sixInch
        case fiveEightInch
        case fiveFiveInch
        case fourSevenInch
        case fourInch
        case iPad
    }
    
    private var heightValue: CGFloat!
    private var widthValue: CGFloat!
    
    var originalDevelopmentEnvironment: DevelopmentEnvironment! {
        didSet {
            switch originalDevelopmentEnvironment {
            case .sixInch:
                heightValue = 896
                widthValue = 414
            case .fiveEightInch:
                heightValue = 812
                widthValue = 375
            case .fiveFiveInch:
                heightValue = 736
                widthValue = 414
            case .fourSevenInch:
                heightValue = 667
                widthValue = 375
            case .fourInch:
                heightValue = 568
                widthValue = 320
            case .iPad:
                heightValue = 1024
                widthValue = 768
            default:
                heightValue = nil
                widthValue = nil
            }
        }
    }
    
    func screenHeight(_ forDevice: DevelopmentEnvironment) -> CGFloat {
        switch forDevice {
        case .sixInch:
            return 896
        case .fiveEightInch:
            return 812
        case .fiveFiveInch:
            return 736
        case .fourSevenInch:
            return 667
        case .fourInch:
            return 568
        case .iPad:
            return 1024
        }
    }
    
    func screenWidth(_ forDevice: DevelopmentEnvironment) -> CGFloat {
        switch forDevice {
        case .sixInch:
            return 414
        case .fiveEightInch:
            return 375
        case .fiveFiveInch:
            return 414
        case .fourSevenInch:
            return 375
        case .fourInch:
            return 320
        case .iPad:
            return 768
        }
    }
    
    func frame(_ forFrame: CGRect) -> CGRect {
        return CGRect(x: x(forFrame.origin.x), y: y(forFrame.origin.y), width: width(forFrame.size.width), height: height(forFrame.size.height))
    }
    
    func frame(_ forFrame: CGRect, toDevice: DevelopmentEnvironment) -> CGRect {
        return CGRect(x: x(forFrame.origin.x, toDevice: toDevice), y: y(forFrame.origin.y, toDevice: toDevice), width: width(forFrame.size.width, toDevice: toDevice), height: height(forFrame.size.height, toDevice: toDevice))
    }
    
    func height(_ value: CGFloat) -> CGFloat {
        return CGFloat(UIScreen.main.bounds.size.height * value) / heightValue
    }
    
    func height(_ value: CGFloat, toDevice: DevelopmentEnvironment) -> CGFloat {
        return round(CGFloat(screenHeight(toDevice) * value) / heightValue)
    }
    
    func width(_ value: CGFloat) -> CGFloat {
        return CGFloat(UIScreen.main.bounds.size.width * value) / widthValue
    }
    
    func width(_ value: CGFloat, toDevice: DevelopmentEnvironment) -> CGFloat {
        return round(CGFloat(screenWidth(toDevice) * value) / widthValue)
    }
    
    func x(_ value: CGFloat) -> CGFloat {
        return CGFloat(UIScreen.main.bounds.width * value) / widthValue
    }
    
    func x(_ value: CGFloat, toDevice: DevelopmentEnvironment) -> CGFloat {
        return round(CGFloat(screenWidth(toDevice) * value) / widthValue)
    }
    
    func y(_ value: CGFloat) -> CGFloat {
        return CGFloat(UIScreen.main.bounds.height * value) / heightValue
    }
    
    func y(_ value: CGFloat, toDevice: DevelopmentEnvironment) -> CGFloat {
        return round(CGFloat(screenHeight(toDevice) * value) / heightValue)
    }
}

extension UIView {
    func updateFrame() {
        frame = f.frame(frame)
    }
}
