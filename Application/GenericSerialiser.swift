//
//  GenericSerialiser.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 17/07/2017.
//  Copyright © 2013-2017 NEOTechnica Corporation. All rights reserved.
//

//First-party Frameworks
import UIKit

//Third-party Frameworks
import FirebaseDatabase

class GenericSerialiser
{
    //--------------------------------------------------//
    
    //Public Functions
    
    /**
     Determines whether a given identifier is underlyingly an **Animal** or not.
     
     - Parameter withIdentifier: The identifier whose underlying status to determine.
     
     - Parameter completionHandler: Returns a Boolean upon completion.
     */
    func isAnimal(withIdentifier: String, completionHandler: @escaping (Bool) -> Void)
    {
        Database.database().reference().child("/allAnimals/\(withIdentifier)").observeSingleEvent(of: .value, with: { (returnedSnapshot) in
            if returnedSnapshot.exists()
            {
                completionHandler(true)
            }
            else
            {
                completionHandler(false)
            }
        })
    }
    
    /**
     Determines whether a given identifier is underlyingly a **Shelter** or not.
     
     - Parameter withIdentifier: The identifier whose underlying status to determine.
     
     - Parameter completionHandler: Returns a Boolean upon completion.
     */
    func isShelter(withIdentifier: String, completionHandler: @escaping (Bool) -> Void)
    {
        Database.database().reference().child("/allShelters/\(withIdentifier)").observeSingleEvent(of: .value, with: { (returnedSnapshot) in
            if returnedSnapshot.exists()
            {
                completionHandler(true)
            }
            else
            {
                completionHandler(false)
            }
        })
    }
    
    /**
     Gets values on the server for a given path.
     
     - Parameter atPath: The server path at which to retrieve values.
     
     - Parameter completionHandler: Returns the Firebase snapshot value.
     */
    func getValues(atPath: String, completionHandler: @escaping (Any?) -> Void)
    {
        Database.database().reference().child(atPath).observeSingleEvent(of: .value, with: { (returnedSnapshot) in
            completionHandler(returnedSnapshot.value)
        })
    }
    
    func setValue(onKey: String, withData: Any, completionHandler: @escaping (Error?) -> Void)
    {
        Database.database().reference().child(onKey).setValue(withData) { (returnedError, returnedDatabase) in
            if returnedError != nil
            {
                completionHandler(returnedError!)
            }
            else
            {
                completionHandler(nil)
            }
        }
    }
    
    /**
     Updates a value on the server for a given key and data bundle.
     
     - Parameter atPath: The server path at which to retrieve values.
     - Parameter withData: The data bundle to update the server with.
     
     - Parameter completionHandler: Returns an Error if unable to update values.
     */
    func updateValue(onKey: String, withData: [String:Any], completionHandler: @escaping (Error?) -> Void)
    {
        Database.database().reference().child(onKey).updateChildValues(withData, withCompletionBlock: { (returnedError, returnedDatabase) in
            if returnedError != nil
            {
                completionHandler(returnedError!)
            }
            else
            {
                completionHandler(nil)
            }
        })
    }
}
