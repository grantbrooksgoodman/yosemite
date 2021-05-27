//
//  Extensions.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import Foundation
import UIKit

//==================================================//

/* MARK: - Array Extensions */

extension Array {
    var randomElement: Element {
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
    
    var shuffledValue: [Element] {
        var arrayElements = self
        
        for individualIndex in 0 ..< arrayElements.count {
            arrayElements.swapAt(individualIndex, Int(arc4random_uniform(UInt32(arrayElements.count - individualIndex))) + individualIndex)
        }
        
        return arrayElements
    }
}

extension Array where Element == String {
    func containsAny(in: [String]) -> Bool {
        for value in `in` {
            if contains(value) {
                return true
            }
        }
        
        return false
    }
}

//==================================================//

/* MARK: - Date Extensions */

extension Date {
    /* MARK: - Functions */
    
    func elapsedInterval() -> String {
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: Date())
        
        if let yearsPassed = interval.year,
           yearsPassed > 0 {
            return "\(yearsPassed)y"
        } else if let monthsPassed = interval.month,
                  monthsPassed > 0 {
            return "\(monthsPassed)mo"
        } else if let daysPassed = interval.day,
                  daysPassed > 0 {
            return "\(daysPassed)d"
        } else if let hoursPassed = interval.hour,
                  hoursPassed > 0 {
            return "\(hoursPassed)h"
        } else if let minutesPassed = interval.minute,
                  minutesPassed > 0 {
            return "\(minutesPassed)m"
        }
        
        return "now"
    }
    
    ///Function that gets a nicely formatted date string from a provided Date.
    func formattedString() -> String {
        let differenceBetweenDates = Calendar.current.startOfDay(for: Date()).distance(to: Calendar.current.startOfDay(for: self))
        
        let stylizedDateFormatter = DateFormatter()
        stylizedDateFormatter.dateStyle = .short
        
        if differenceBetweenDates == 0 {
            return DateFormatter.localizedString(from: self, dateStyle: .none, timeStyle: .short)
        } else if differenceBetweenDates == -86400 {
            return "Yesterday"
        } else if differenceBetweenDates >= -604_800 {
            if masterDateFormatter.string(from: self).dayOfWeek() != masterDateFormatter.string(from: Date()).dayOfWeek() {
                return masterDateFormatter.string(from: self).dayOfWeek()
            } else {
                return stylizedDateFormatter.string(from: self)
            }
        }
        
        return stylizedDateFormatter.string(from: self)
    }
    
    //--------------------------------------------------//
    
    /* MARK: - Variables */
    
    var comparator: Date {
        return currentCalendar.date(bySettingHour: 12, minute: 00, second: 00, of: currentCalendar.startOfDay(for: self))!
    }
}

//==================================================//

/* MARK: - Dictionary Extensions */

extension Dictionary {
    mutating func switchKey(fromKey: Key, toKey: Key) {
        if let dictionaryEntry = removeValue(forKey: fromKey) {
            self[toKey] = dictionaryEntry
        }
    }
}

extension Dictionary where Value: Equatable {
    func allKeys(forValue: Value) -> [Key] {
        return filter { $1 == forValue }.map { $0.0 }
    }
}

//==================================================//

/* MARK: - Int Extensions */

extension Int {
    /* MARK: - Functions */
    
    ///Returns a random integer value.
    func random(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    //--------------------------------------------------//
    
    /* MARK: - Variables */
    
    var ordinalValue: String {
        var determinedSuffix = "th"
        
        switch self % 10 {
        case 1:
            determinedSuffix = "st"
        case 2:
            determinedSuffix = "nd"
        case 3:
            determinedSuffix = "rd"
        default: ()
        }
        
        if (self % 100) > 10 && (self % 100) < 20 {
            determinedSuffix = "th"
        }
        
        return String(self) + determinedSuffix
    }
}

//==================================================//

/* MARK: - Sequence Extensions */

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen = Set<Iterator.Element>()
        
        return filter { seen.insert($0).inserted }
    }
}

//==================================================//

/* MARK: - String Extensions */

extension String {
    /* MARK: - Functions */
    
    func containsAny(in: String) -> Bool {
        var count = 0
        
        for find in `in`.map({ String($0) }) {
            count += map { String($0) }.filter { $0 == find }.count
        }
        
        return count != 0
    }
    
    ///Function that returns a day of the week for a given date string.
    func dayOfWeek() -> String {
        guard let fromDate = masterDateFormatter.date(from: self) else {
            report("String is not a valid date.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
            return "NULL"
        }
        
        switch Calendar.current.component(.weekday, from: fromDate) {
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return "NULL"
        }
    }
    
    func dropPrefix(_ dropping: Int = 1) -> String {
        return String(suffix(from: index(startIndex, offsetBy: dropping)))
    }
    
    func dropSuffix(_ dropping: Int = 1) -> String {
        return String(prefix(count - dropping))
    }
    
    func isAny(in: [String]) -> Bool {
        for value in `in` {
            if self == value {
                return true
            }
        }
        
        return false
    }
    
    func removingOccurrences(of: [String]) -> String {
        var mutable = self
        
        for remove in of {
            mutable = mutable.replacingOccurrences(of: remove, with: "")
        }
        
        return mutable
    }
    
    //--------------------------------------------------//
    
    /* MARK: - Variables */
    
    var alphabeticalPosition: Int {
        guard count == 1 else {
            report("String length is greater than 1.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
            return -1
        }
        
        let alphabetArray = Array("abcdefghijklmnopqrstuvwxyz")
        
        guard alphabetArray.contains(Character(lowercased())) else {
            report("The character is non-alphabetical.", errorCode: nil, isFatal: true, metadata: [#file, #function, #line])
            return -1
        }
        
        return ((alphabetArray.firstIndex(of: Character(lowercased())))! + 1)
    }
    
    var characters: [String] {
        return map { String($0) }
    }
    
    var isValidEmail: Bool {
        return NSPredicate(format: "SELF MATCHES[c] %@", "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$").evaluate(with: self)
    }
    
    var lowercasedTrimmingWhitespace: String {
        return trimmingCharacters(in: .whitespacesAndNewlines).lowercased().trimmingWhitespace
    }
    
    var trimmingBorderedWhitespace: String {
        return trimmingLeadingWhitespace.trimmingTrailingWhitespace
    }
    
    var trimmingLeadingWhitespace: String {
        var mutableSelf = self
        
        while mutableSelf.hasPrefix(" ") || mutableSelf.hasPrefix("\u{00A0}") {
            mutableSelf = mutableSelf.dropPrefix(1)
        }
        
        return mutableSelf
    }
    
    var trimmingTrailingWhitespace: String {
        var mutableSelf = self
        
        while mutableSelf.hasSuffix(" ") || mutableSelf.hasSuffix("\u{00A0}") {
            mutableSelf = mutableSelf.dropSuffix(1)
        }
        
        return mutableSelf
    }
    
    var trimmingWhitespace: String {
        return replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\u{00A0}", with: "")
    }
}

//==================================================//

/* MARK: - UIColor Extensions */

extension UIColor {
    private convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    /**
     Creates a color object using the specified RGB/hexadecimal code.
     
     - Parameter rgb: A hexadecimal integer.
     - Parameter alpha: The opacity of the color, from 0.0 to 1.0.
     */
    convenience init(rgb: Int, alpha: CGFloat = 1.0) {
        self.init(red: (rgb >> 16) & 0xFF, green: (rgb >> 8) & 0xFF, blue: rgb & 0xFF, alpha: alpha)
    }
    
    /**
     Creates a color object using the specified hexadecimal code.
     
     - Parameter hex: A hexadecimal integer.
     */
    convenience init(hex: Int) {
        self.init(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: hex & 0xFF, alpha: 1.0)
    }
}

//==================================================//

/* MARK: - UIImageView Extensions */

extension UIImageView {
    func downloadedFrom(_ link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else {
            return
        }
        
        downloadedFrom(url: url, contentMode: mode)
    }
    
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        contentMode = mode
        
        URLSession.shared.dataTask(with: url) { privateRetrievedData, privateUrlResponse, privateOccurredError in
            
            guard let urlResponse = privateUrlResponse as? HTTPURLResponse, urlResponse.statusCode == 200,
                  let mimeType = privateUrlResponse?.mimeType, mimeType.hasPrefix("image"),
                  let retrievedData = privateRetrievedData, privateOccurredError == nil,
                  let retrievedImage = UIImage(data: retrievedData) else {
                DispatchQueue.main.async {
                    self.image = UIImage(named: "Not Found")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.image = retrievedImage
            }
            
        }.resume()
    }
}

//==================================================//

/* MARK: - UILabel Extensions */

extension UILabel {
    /* MARK: - Functions */
    
    func fontSizeThatFits(_ alternateText: String?) -> CGFloat {
        if let labelText = alternateText ?? text {
            let frameToUse = (superview as? UIButton != nil ? superview!.frame : frame)
            
            let mutableCopy = UILabel(frame: frameToUse)
            mutableCopy.font = font
            mutableCopy.lineBreakMode = lineBreakMode
            mutableCopy.numberOfLines = numberOfLines
            mutableCopy.text = labelText
            
            var initialSize = mutableCopy.text!.size(withAttributes: [NSAttributedString.Key.font: mutableCopy.font!])
            
            while initialSize.width > mutableCopy.frame.size.width {
                let newSize = mutableCopy.font.pointSize - 0.5
                
                if newSize > 0.0 {
                    mutableCopy.font = mutableCopy.font.withSize(newSize)
                    
                    initialSize = mutableCopy.text!.size(withAttributes: [NSAttributedString.Key.font: mutableCopy.font!])
                } else {
                    return 0.0
                }
            }
            
            return mutableCopy.font.pointSize
        } else {
            return font.pointSize
        }
    }
    
    func scaleToMinimum(alternateText: String?, originalText: String?, minimumSize: CGFloat) {
        if let labelText = originalText ?? text {
            if textWillFit(alternate: labelText, minimumSize: minimumSize) {
                font = font.withSize(fontSizeThatFits(labelText))
            } else {
                if let labelText = alternateText {
                    if textWillFit(alternate: labelText, minimumSize: minimumSize) {
                        font = font.withSize(fontSizeThatFits(labelText))
                    } else {
                        report("Neither the original nor alternate strings fit.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                    }
                } else {
                    report("Original string didn't fit, no alternate provided.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                }
            }
        }
    }
    
    func textWillFit(alternate: String?, minimumSize: CGFloat) -> Bool {
        return fontSizeThatFits(alternate) >= minimumSize
    }
    
    //--------------------------------------------------//
    
    /* MARK: - Variables */
    
    var isTruncated: Bool {
        guard let labelText = text as NSString? else {
            return false
        }
        
        let contentSize = labelText.size(withAttributes: [.font: font!])
        
        return contentSize.width > bounds.width
    }
}

//==================================================//

/* MARK: - UITextView Extensions */

extension UITextView {
    func fontSizeThatFits(_ alternateText: String?) -> CGFloat {
        if let labelText = alternateText ?? text {
            let frameToUse = (superview as? UIButton != nil ? superview!.frame : frame)
            
            let mutableCopy = UILabel(frame: frameToUse)
            mutableCopy.font = font
            mutableCopy.text = labelText
            
            var initialSize = mutableCopy.text!.size(withAttributes: [NSAttributedString.Key.font: mutableCopy.font!])
            
            while initialSize.width > mutableCopy.frame.size.width {
                let newSize = mutableCopy.font.pointSize - 0.5
                
                if newSize > 0.0 {
                    mutableCopy.font = mutableCopy.font.withSize(newSize)
                    
                    initialSize = mutableCopy.text!.size(withAttributes: [NSAttributedString.Key.font: mutableCopy.font!])
                } else {
                    return 0.0
                }
            }
            
            return mutableCopy.font.pointSize
        } else {
            return font!.pointSize
        }
    }
    
    func scaleToMinimum(alternateText: String?, originalText: String?, minimumSize: CGFloat) {
        if let labelText = originalText ?? text {
            if textWillFit(alternate: labelText, minimumSize: minimumSize) {
                font = font!.withSize(fontSizeThatFits(labelText))
            } else {
                if let labelText = alternateText {
                    if textWillFit(alternate: labelText, minimumSize: minimumSize) {
                        font = font!.withSize(fontSizeThatFits(labelText))
                    } else {
                        report("Neither the original nor alternate strings fit.", errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                    }
                }
            }
        }
    }
    
    func textWillFit(alternate: String?, minimumSize: CGFloat) -> Bool {
        return fontSizeThatFits(alternate) >= minimumSize
    }
}

//==================================================//

/* MARK: - UIView Extensions */

extension UIView {
    /* MARK: - Functions */
    
    func addBlur(withActivityIndicator: Bool, withStyle: UIBlurEffect.Style, withTag: Int, alpha: CGFloat) {
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: withStyle))
        
        blurEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        blurEffectView.frame = bounds
        blurEffectView.tag = withTag
        blurEffectView.alpha = alpha
        
        addSubview(blurEffectView)
        
        if withActivityIndicator {
            let activityIndicatorView = UIActivityIndicatorView(style: .large)
            activityIndicatorView.center = center
            activityIndicatorView.startAnimating()
            activityIndicatorView.tag = aTagFor("BLUR_INDICATOR")
            addSubview(activityIndicatorView)
        }
    }
    
    /**
     Adds a shadow border around the view.
     
     - Parameter backgroundColor: The shadow border's desired background color.
     - Parameter borderColor: The shadow border's desired border color.
     - Parameter withFrame: An optional specifying an alternate frame to add the shadow to.
     - Parameter withTag: The tag to associate with the shadow border.
     */
    func addShadowBorder(backgroundColor: UIColor, borderColor: CGColor, withFrame: CGRect?, withTag: Int) {
        let borderFrame = UIView(frame: withFrame ?? frame)
        
        borderFrame.backgroundColor = backgroundColor
        
        borderFrame.layer.borderColor = borderColor
        borderFrame.layer.borderWidth = 2
        
        borderFrame.layer.cornerRadius = 10
        borderFrame.layer.masksToBounds = false
        
        borderFrame.layer.shadowColor = borderColor
        borderFrame.layer.shadowOffset = CGSize(width: 0, height: 4)
        borderFrame.layer.shadowOpacity = 1
        
        borderFrame.tag = withTag
        
        addSubview(borderFrame)
        sendSubviewToBack(borderFrame)
    }
    
    func removeBlur(withTag: Int) {
        for indivdualSubview in subviews {
            if indivdualSubview.tag == withTag || indivdualSubview.tag == aTagFor("BLUR_INDICATOR") {
                UIView.animate(withDuration: 0.2, animations: {
                    indivdualSubview.alpha = 0
                }) { _ in
                    indivdualSubview.removeFromSuperview()
                }
            }
        }
    }
    
    /**
     Removes a subview for a given tag, if it exists.
     
     - Parameter withTag: The tag of the view to remove.
     */
    func removeSubview(_ withTag: Int, animated: Bool) {
        for individualSubview in subviews {
            if individualSubview.tag == withTag {
                DispatchQueue.main.async {
                    if animated {
                        UIView.animate(withDuration: 0.2, animations: {
                            individualSubview.alpha = 0
                        }) { _ in
                            individualSubview.removeFromSuperview()
                        }
                    } else {
                        individualSubview.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    ///Sets the background image on a UIView.
    func setBackground(withImageNamed: String!) {
        UIGraphicsBeginImageContext(frame.size)
        
        UIImage(named: withImageNamed)?.draw(in: bounds)
        
        let imageToSet: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        backgroundColor = UIColor(patternImage: imageToSet)
    }
    
    /**
     Attempts to find a subview for a given tag.
     
     - Parameter forTag: The tag by which to search for the view.
     */
    func subview(_ forTag: Int) -> UIView? {
        for individualSubview in subviews {
            if individualSubview.tag == forTag {
                return individualSubview
            }
        }
        
        return nil
    }
    
    /**
     Attempts to find a subview for a given tag.
     
     - Parameter forTag: The tag by which to search for the view.
     */
    func subviews(_ forTag: Int) -> [UIView]? {
        var matchingSubviews = [UIView]()
        
        for individualSubview in subviews {
            if individualSubview.tag == forTag {
                matchingSubviews.append(individualSubview)
            }
        }
        
        return !matchingSubviews.isEmpty ? matchingSubviews : nil
    }
    
    //--------------------------------------------------//
    
    /* MARK: - Variables */
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        
        return nil
    }
}
