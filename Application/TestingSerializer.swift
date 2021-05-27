//
//  TestingSerializer.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 24/05/2021.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import UIKit

/* Third-party Frameworks */
import FirebaseAuth
import SwiftRandom

class Testing {
    
    //==================================================//
    
    /* MARK: - Functions */
    
    func createAccount(email: String, password: String, orderedUserMetaData: [Any], completionHandler: @escaping(_ returnedUser: User?, _ errorDescriptor: String?) -> Void) {
        
        guard let factoidData = orderedUserMetaData[0] as? FactoidData else {
            completionHandler(nil, "Improperly formatted metadata.")
            return
        }
        
        guard let userData = orderedUserMetaData[1] as? UserData else {
            completionHandler(nil, "Improperly formatted metadata.")
            return
        }
        
        guard let firstName = orderedUserMetaData[2] as? String else {
            completionHandler(nil, "Improperly formatted metadata.")
            return
        }
        
        guard let lastName = orderedUserMetaData[3] as? String else {
            completionHandler(nil, "Improperly formatted metadata.")
            return
        }
        
        guard let phoneNumber = orderedUserMetaData[4] as? String else {
            completionHandler(nil, "Improperly formatted metadata.")
            return
        }
        
        var questionsAnswered: [String:(Int, String)]?
        
        if let unwrappedQuestionsAnswered = orderedUserMetaData[5] as? [String:(Int, String)],
           unwrappedQuestionsAnswered.count != 0 {
            questionsAnswered = unwrappedQuestionsAnswered
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (wrappedReturnedUser, wrappedReturnedError) in
            if let returnedError = wrappedReturnedError {
                completionHandler(nil, errorInfo((returnedError as NSError)))
            } else {
                if let returnedUser = wrappedReturnedUser {
                    UserSerializer().createUser(associatedIdentifier: returnedUser.user.uid,
                                                emailAddress: email,
                                                factoidData: factoidData,
                                                userData: userData,
                                                firstName: firstName,
                                                lastName: lastName,
                                                phoneNumber: phoneNumber,
                                                questionsAnswered: questionsAnswered) { (wrappedUser, createUserErrorDescriptor) in
                        if let returnedUser = wrappedUser {
                            completionHandler(returnedUser, nil)
                        } else {
                            completionHandler(nil, createUserErrorDescriptor ?? "An unknown error occurred.")
                        }
                    }
                } else {
                    completionHandler(nil, "No error, but no returned user either.")
                }
            }
        })
    }
    
    func createRandomUser() {
        var imageArray: [UIImage] = [UIImage(named: "download.jpg")!]
        
        var iterator = 0;
        
        while iterator < 29 {
            iterator += 1;
            imageArray.append(UIImage(named: "download-\(iterator).jpg")!)
        }
        
        var lookingForArray = ["relationship", "something casual", "study buddy", "workout partner", "roommate", "friend", "nothing in particular"]
        lookingForArray = lookingForArray.shuffledValue
        
        lookingForArray = Array(lookingForArray[0...Int().random(min: 0, max: lookingForArray.count - 1)])
        
        if lookingForArray.count > 1 && lookingForArray.contains("nothing in particular") {
            lookingForArray.remove(at: lookingForArray.firstIndex(of: "nothing in particular")!)
        }
        
        let majorArray = ["MET", "Computer science", "Applied math", "Media studies", "Gender & women studies", "Nicotine studies", "Linguistics", "Bioengineering", "Haas", "Environmental econ.", "Polisci"]
        
        var sportsArray = ["Baseball", "Basketball", "Football", "Fencing", "Tennis", "Golf", "Volleyball", "Soccer", "Skiiing", "Surfing"]
        sportsArray = sportsArray.shuffledValue
        sportsArray = Array(sportsArray[0...Int().random(min: 0, max: 3)])
        
        let randomDate = masterDateFormatter.date(from: "\(Int().random(min: 1995, max: 2002))-01-\(Int().random(min: 1, max: 27))")
        
        //gender, major, year code, year ex.
        
        let quickFacts: [String:Any] = ["gender": Int().random(min: 0, max: 2), "major": majorArray.randomElement, "yearCode": Int().random(min: 0, max: 5), "yearExplanation": "!"]
        
        let homeShown = Randoms.randomBool()
        let gloShown = Randoms.randomBool()
        let sportsShown = Randoms.randomBool()
        
        let willBeShown = [homeShown, gloShown, sportsShown]
        
        var shuffled = [0, 1, 2]
        
        for item in willBeShown {
            if item == false {
                shuffled.removeLast()
            }
        }
        
        shuffled = shuffled.shuffled()
        
        let homePosition = homeShown ? shuffled.randomElement() ?? 0 : 9
        
        shuffled = shuffled.filter({$0 != homePosition})
        
        let gloPosition = gloShown ? shuffled.randomElement() ?? 0 : 9
        
        shuffled = shuffled.filter({$0 != homePosition && $0 != gloPosition})
        
        let sportsPosition = sportsShown ? shuffled.randomElement() ?? 0 : 9
        
        let callsHome = homeShown ? ((homePosition, false), Randoms.randomFakeCity()) : nil
        let glo = gloShown ? ((gloPosition, false), "ΑΒΞΔΕΦΓΗΚΛΜΝΠΘΡΣΤΥΩΧΨΖ".map({String($0)}).shuffled()[0...2].joined()) : nil
        let sports = sportsShown ? ((sportsPosition, false), sportsArray) : nil
        
        let factoidData = FactoidData(callsHome: callsHome,
                                      greekLifeOrganisation: glo,
                                      lookingFor: lookingForArray[0] == "nothing in particular" ? nil : lookingForArray,
                                      quickFacts: quickFacts,
                                      sports: sports)
        
        let userData = UserData(bioText: Randoms.randomFakeConversation(),
                                birthDate: randomDate!,
                                lastActiveDate: Date(),
                                profileImageData: ([imageArray.randomElement.jpegData(compressionQuality: 0.5)?.base64EncodedString(), imageArray.randomElement.jpegData(compressionQuality: 0.5)?.base64EncodedString()] as! [String]),
                                sexualPreference: 2,
                                studentType: Int().random(min: 0, max: 2))
        
        let randomName = Randoms.randomFakeName()
        
        let randomFirstNamecharacters = randomName.components(separatedBy: " ")[0].characters
        let randomLastNamecharacters = randomName.components(separatedBy: " ")[1].characters
        
        let randomFirstName = "\(randomFirstNamecharacters[0...Int().random(min: 1, max: randomFirstNamecharacters.count - 1)].joined())\(randomLastNamecharacters.shuffledValue.joined().lowercased())"
        
        let consonants = "bcdfghjklmnpqrstvwxyz".characters
        let vowels = "aeiou".characters
        
        let thing = randomFirstName.characters[0...Int().random(min: 1, max: randomFirstName.count - 1)]
        var random: String!
        
        if consonants.contains(thing.last!.lowercased()) {
            random = randomFirstName.characters[0...Int().random(min: 1, max: randomFirstName.count - 1)].joined() + vowels.randomElement
        } else {
            random = randomFirstName.characters[0...Int().random(min: 1, max: randomFirstName.count - 1)].joined() + consonants.randomElement + vowels.randomElement
        }
        
        let questionTitles = ["After work I like to...",
                              "Berkeley bucket list...",
                              "I love it when...",
                              "I promise that...",
                              "I would love to meet...",
                              "It's a perfect match if...",
                              "My dealbreakers are...",
                              "My death row meal would be...",
                              "My favourite Cal memory was when...",
                              "My favourite quality in a person is...",
                              "My favourite website is...",
                              "My friends describe me as...",
                              "My secret superpower is...",
                              "Never have I ever...",
                              "Nothing's better than...",
                              "When nobody's looking, I..."].shuffled()[0...2]
        var questionsAnswered: [String:(Int, String)] = [:]
        
        for (index, question) in questionTitles.enumerated() {
            let answer = Int().random(min: 0, max: 1) == 0 ? Randoms.randomFakeName() : Randoms.randomFakeConversation()
            
            questionsAnswered[question] = (index, answer)
        }
        
        let metadata: [Any] = [factoidData, userData, "\(randomName.components(separatedBy: " ")[0])\(vowels.randomElement)\(consonants.randomElement)\(vowels.randomElement)", random!, "818-555-5555", questionsAnswered]
        
        self.createAccount(email: "\(random.lowercased())@yosemite.app", password: "123456", orderedUserMetaData: metadata) { (wrappedUser, createAccountError) in
            if let returnedUser = wrappedUser {
                print(returnedUser.associatedIdentifier!)
            } else {
                AlertKit().errorAlertController(title: "Create User Failed",
                                                message: createAccountError,
                                                dismissButtonTitle: nil,
                                                additionalSelectors: nil,
                                                preferredAdditionalSelector: 0,
                                                canFileReport: true,
                                                extraInfo: createAccountError,
                                                metadata: [#file, #function, #line],
                                                networkDependent: true)
            }
        }
    }
}
