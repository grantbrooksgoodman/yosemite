//
//  Translator.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

//Third-party Frameworks
import PKHUD

class Translator
{
    //--------------------------------------------------//
    
    //Class-Level Variable Declarations
    
    //Boolean Declarations
    var requiresHud = false
    var taskRunning = false
    
    //Other Declarations
    var sessionTask: URLSessionTask?
    
    //--------------------------------------------------//
    
    //Public Functions
    
    ///Cancels all translation tasks currently going on.
    func cancelAllTasks()
    {
        if let unwrappedSessionTask = sessionTask
        {
            unwrappedSessionTask.cancel()
        }
    }
    
    ///Uses the other translation method, but does not return any errors, instead simply returning the untranslated string in the event of a failure.
    func dirtyGetTranslation(forString: String, requiresHud: Bool, completionHandler: @escaping (_ translatedString: String) -> Void)
    {
        self.requiresHud = requiresHud
        
        getTranslation(forString: forString, requiresHud: self.requiresHud) { (returnedError, returnedTranslation) in
            if let unwrappedError = returnedError
            {
                report(unwrappedError, errorCode: nil, isFatal: false, metadata: [#file, #function, #line])
                
                completionHandler(forString.replacingOccurrences(of: "*", with: ""))
            }
            else
            {
                if let unwrappedTranslation = returnedTranslation
                {
                    completionHandler(unwrappedTranslation)
                }
                else
                {
                    completionHandler(forString.replacingOccurrences(of: "*", with: ""))
                }
            }
        }
    }
    
    ///Expands the preexisting dirty translation method for use with string arrays.
    func getArrayOfTranslations(fromArray: [String]!, requiresHud: Bool, completionHandler: @escaping ([String]) -> Void)
    {
        self.requiresHud = requiresHud
        
        if fromArray.count == 0
        {
            completionHandler([])
        }
        else
        {
            var translationDictionary: [Int: String]! = [:]
            
            for individualString in fromArray
            {
                translationDictionary[fromArray.firstIndex(of: individualString)!] = individualString
            }
            
            var iterationCount = 0
            
            for individualString in fromArray
            {
                dirtyGetTranslation(forString: individualString, requiresHud: self.requiresHud) { (returnedTranslation) in
                    translationDictionary[translationDictionary.allKeys(forValue: individualString)[0]] = returnedTranslation
                    
                    iterationCount += 1
                    
                    if fromArray.count == iterationCount
                    {
                        var returnArrayInOrderOfReceipt: [String]! = []
                        
                        for individualKey in Array(translationDictionary.keys).sorted()
                        {
                            returnArrayInOrderOfReceipt.append(translationDictionary[individualKey]!)
                            
                            if returnArrayInOrderOfReceipt.count == translationDictionary.count
                            {
                                completionHandler(returnArrayInOrderOfReceipt)
                            }
                        }
                    }
                }
            }
        }
    }
    
    ///Attempts to get a translation of a given string.
    func getTranslation(forString: String, requiresHud: Bool, completionHandler: @escaping (_ errorContent: String?, _ translatedString: String?) -> Void)
    {
        self.requiresHud = requiresHud
        
        if forString.noWhiteSpaceLowerCaseString == ""
        {
            completionHandler(nil, forString)
        }
        else
        {
            let notaryResults = notariseTranslationString(forString: forString)
            
            if !notaryResults.needsTranslation
            {
                completionHandler(nil, notaryResults.resultantString.replacingOccurrences(of: "*", with: ""))
            }
            else
            {
                if let translationString = notaryResults.resultantString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                {
                    if let requestUrl = URL(string: "https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20160625T182042Z.c452dfda3c9ca1af.e418b02a5238a1e97890305d9fcd0b5af9d66d7c&text=\(translationString)&lang=en-\(languageCode)&[format=plain]&[options=1]&[callback=json]")
                    {
                        var originalMatch = ""
                        
                        if let matchingRange = notaryResults.resultantString.range(of: "\\*(.*?)\\*", options: .regularExpression)
                        {
                            originalMatch = notaryResults.resultantString[matchingRange].replacingOccurrences(of: "*", with: "")
                        }
                        
                        retrieveRequestData(forUrl: requestUrl, originalString: forString, rangeEscapedString: originalMatch) { (associatedError, didError, resultantString) in
                            let interpretedData = self.interpretResponseData(withAssociatedError: associatedError, withDidError: didError, withResultantString: resultantString)
                            
                            if let errorContent = interpretedData.errorContent
                            {
                                var errorToSend = errorContent
                                
                                if errorContent == "cancelled"
                                {
                                    errorToSend = "The task was taking too long and has been cancelled."
                                }
                                
                                completionHandler(errorToSend, nil)
                            }
                            else
                            {
                                if let translatedString = interpretedData.translatedString
                                {
                                    completionHandler(nil, translatedString)
                                }
                                else
                                {
                                    completionHandler("No translated string, but no error either.", nil)
                                }
                            }
                        }
                    }
                    else
                    {
                        completionHandler("The request URL was invalid.", nil)
                    }
                }
                else
                {
                    completionHandler("The string could not be encoded.", nil)
                }
            }
        }
    }
    
    ///Attempts to find a string that will fit a given label.
    func suitableString(adjustmentAllowed: Bool, forLabel: UILabel, withBackUpString: String?, withString: String, completionHandler: @escaping (_ shouldAdjust: Bool?, _ returnedString: String) -> Void)
    {
        dirtyGetTranslation(forString: withString, requiresHud: false) { (returnedString) in
            DispatchQueue.main.async {
                
                //If this label will NOT be truncated with the translated string.
                if forLabel.textWillFit(returnedString, minimumSize: forLabel.font.pointSize)
                {
                    //The original string in its translated form didn't need to be adjusted.
                    completionHandler(false, returnedString)
                }
                else //The text won't fit on the label with its current font size.
                {
                    //If we are allowed to adjust it...
                    if adjustmentAllowed
                    {
                        //Let's first test if the text will fit when it's allowed to reduce down to 75% of the size.
                        if forLabel.textWillFit(returnedString, minimumSize: (forLabel.font.pointSize * 0.75))
                        {
                            //So the text WILL fit if we were to adjust it.
                            completionHandler(true, returnedString)
                        }
                        else //Text still won't fit even when the size is down to 75%.
                        {
                            //Is there a backup string?
                            if let backUpString = withBackUpString
                            {
                                //Run the function again, this time with the backup string.
                                self.suitableString(adjustmentAllowed: true, forLabel: forLabel, withBackUpString: nil, withString: backUpString, completionHandler: { (shouldAdjust, recursiveReturnedString) in
                                    
                                    //If the returned string is just the same one we passed in, actually return the original string, because the backup string clearly doesn't work either.
                                    if recursiveReturnedString == backUpString
                                    {
                                        //Backup string didn't fit, can't adjust the label... SOL.
                                        completionHandler(nil, withString)
                                    }
                                    else //It's different, which means it worked.
                                    {
                                        //Backup string fit!
                                        completionHandler(shouldAdjust, recursiveReturnedString)
                                    }
                                })
                            }
                            else //So, no backup string, and it doesn't fit, and adjustment didn't help... SOL.
                            {
                                //Return the original string.
                                completionHandler(nil, withString)
                            }
                        }
                    }
                    else //So the text won't fit, but we're not allowed to adjust the label.
                    {
                        //Is there a backup string?
                        if let backUpString = withBackUpString
                        {
                            //Run the function again, this time with the backup string.
                            self.suitableString(adjustmentAllowed: false, forLabel: forLabel, withBackUpString: nil, withString: backUpString, completionHandler: { (shouldAdjust, recursiveReturnedString) in
                                
                                //If the returned string is just the same one we passed in, actually return the original string, because the backup string clearly doesn't work either.
                                if recursiveReturnedString == backUpString
                                {
                                    //Backup string didn't fit, can't adjust the label... SOL.
                                    completionHandler(nil, withString)
                                }
                                else //It's different, which means it worked.
                                {
                                    //Backup string fit!
                                    completionHandler(shouldAdjust, recursiveReturnedString)
                                }
                            })
                        }
                        else //So, no backup string, and it doesn't fit, and we can't adjust... SOL.
                        {
                            //Return the original string.
                            completionHandler(nil, withString)
                        }
                    }
                }
            }
        }
    }
    
    //--------------------------------------------------//
    
    //Private Functions
    
    ///Checks the status of the current session task.
    private func checkStatus()
    {
        if taskRunning
        {
            if let unwrappedSessionTask = sessionTask
            {
                unwrappedSessionTask.cancel()
            }
            
            taskRunning = false
            
            if requiresHud
            {
                let alertController = UIAlertController(title: unableTitleDictionary[languageCode]!, message: followingUnableDictionary[languageCode]!, preferredStyle: .alert)
                
                hideHud()
                
                findAndResignFirstResponder()
                
                lastInitialisedController.present(alertController, animated: true, completion: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    alertController.dismiss(animated: true, completion: nil)
                })
            }
        }
        
        hideHud()
    }
    
    ///Takes in URL request response data and compresses the data into two optional strings, one for errors and the other for the translation result.
    private func interpretResponseData(withAssociatedError: Error?, withDidError: Bool, withResultantString: String?) -> (errorContent: String?, translatedString: String?)
    {
        if let associatedError = withAssociatedError
        {
            return (associatedError.localizedDescription, nil)
        }
        else
        {
            if withDidError
            {
                if let resultantString = withResultantString
                {
                    return (resultantString, nil)
                }
                else
                {
                    return ("An unknown error occurred.", nil)
                }
            }
            else
            {
                if let resultantString = withResultantString
                {
                    return (nil, resultantString)
                }
                else
                {
                    return ("An unknown error occurred.", nil)
                }
            }
        }
    }
    
    ///Looks at a string and sees if it needs to be translated or not.
    private func notariseTranslationString(forString: String) -> (needsTranslation: Bool, resultantString: String)
    {
        if forString == "languageCode"
        {
            //The translation string was reserved for the system.
            return (false, languageCode)
        }
        else if let archivedLanguageCode = translationArchive["languageCode"]
        {
            if archivedLanguageCode == languageCode
            {
                if let archivedString = translationArchive[forString]
                {
                    //We have translated this string before! Send it out.
                    return (false, archivedString)
                }
                else
                {
                    if languageCode == "en"
                    {
                        //The archive is in English! We don't need to translate anything.
                        translationArchive[forString] = forString.replacingOccurrences(of: "*", with: "") //Should we do this here?
                        
                        return (false, forString)
                    }
                    else
                    {
                        if requiresHud
                        {
                            findAndResignFirstResponder()
                            
                            if hasConnectivity()
                            {
                                showProgressHud()
                            }
                        }
                        
                        //The archive is in the current language, but the string needs translation.
                        return (true, forString)
                    }
                }
            }
            else
            {
                if requiresHud
                {
                    findAndResignFirstResponder()
                    
                    if hasConnectivity()
                    {
                        showProgressHud()
                    }
                }
                
                //The archive isn't in the current language. Nuke the archive and set it up for the current language.
                translationArchive.removeAll()
                translationArchive["languageCode"] = languageCode
                
                return (true, forString)
            }
        }
        else
        {
            if requiresHud
            {
                findAndResignFirstResponder()
                
                if hasConnectivity()
                {
                    showProgressHud()
                }
            }
            
            //The archive doesn't have the language code parameter. Nuke the archive and reinstantiate it properly.
            translationArchive.removeAll()
            translationArchive["languageCode"] = languageCode
            
            return (true, forString)
        }
    }
    
    ///Retrieves data from the results of a session task, parses it, and returns it.
    private func retrieveRequestData(forUrl: URL, originalString: String, rangeEscapedString: String, completionHandler: @escaping (_ associatedError: Error?, _ didError: Bool, _ resultantString: String?) -> Void)
    {
        if hasConnectivity()
        {
            sessionTask = URLSession.shared.dataTask(with: forUrl, completionHandler: { (returnedData, returnedResponse, returnedError) in
                self.sessionTask = nil
                self.taskRunning = false
                
                if let unwrappedError = returnedError
                {
                    completionHandler(unwrappedError, true, nil)
                }
                else
                {
                    if let unwrappedResponse = returnedResponse as? HTTPURLResponse
                    {
                        if let unwrappedData = returnedData
                        {
                            var parsedData: [String: Any]?
                            
                            do
                            {
                                if let unwrappedParsedData = try JSONSerialization.jsonObject(with: unwrappedData, options: .mutableContainers) as? [String: Any]
                                {
                                    parsedData = unwrappedParsedData
                                }
                                else
                                {
                                    completionHandler(nil, true, "The data returned was malformed.")
                                }
                            }
                            catch
                            {
                                completionHandler(error, true, "The data returned was malformed.")
                            }
                            
                            if let unwrappedParsedData = parsedData
                            {
                                if unwrappedResponse.statusCode == 200
                                {
                                    if let translationText = unwrappedParsedData["text"]
                                    {
                                        var translatedString = (translationText as! Array)[0] as String
                                        
                                        if let matchingRange = translatedString.range(of: "\\*(.*?)\\*", options: .regularExpression)
                                        {
                                            translatedString = translatedString.replacingOccurrences(of: translatedString[matchingRange], with: rangeEscapedString)
                                        }
                                        
                                        translationArchive[originalString] = translatedString.replacingOccurrences(of: "*", with: "")
                                        
                                        UserDefaults.standard.set(translationArchive, forKey: "translationArchive")
                                        UserDefaults.standard.synchronize()
                                        
                                        completionHandler(nil, false, translatedString.replacingOccurrences(of: "*", with: ""))
                                    }
                                    else
                                    {
                                        completionHandler(nil, true, "The data returned was malformed. (No \"text\" portion.)")
                                    }
                                }
                                else
                                {
                                    var errorMessage = ""
                                    
                                    if let unwrappedErrorMessage = unwrappedParsedData["message"]
                                    {
                                        errorMessage = "\n\n\(unwrappedErrorMessage)"
                                    }
                                    
                                    completionHandler(nil, true, "The translation server returned an error. (\(unwrappedResponse.statusCode))\(errorMessage)")
                                }
                            }
                            else
                            {
                                completionHandler(nil, true, "The data returned was malformed and the error was not caught.")
                            }
                        }
                        else
                        {
                            completionHandler(nil, true, "The translation server returned no data.")
                        }
                    }
                    else
                    {
                        completionHandler(nil, true, "The translation server returned no response.")
                    }
                }
            })
            
            if let unwrappedSessionTask = sessionTask
            {
                unwrappedSessionTask.resume()
                taskRunning = true
            }
            else
            {
                completionHandler(nil, true, "Failed to unwrap the session task.")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
                self.checkStatus()
            })
        }
        else
        {
            completionHandler(nil, true, "The Internet connection appears to be offline.")
        }
    }
}
