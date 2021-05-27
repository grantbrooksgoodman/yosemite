//
//  GenericSerializer.swift
//  glaid (Code Name Yosemite)
//
//  Created by Grant Brooks Goodman on 17/07/2017.
//  Copyright © 2013-2021 NEOTechnica Corporation. All rights reserved.
//

/* First-party Frameworks */
import UIKit

/* Third-party Frameworks */
import FirebaseDatabase

class GenericSerializer {
    
    //==================================================//
    
    /* MARK: - Functions */
    
    /**
     Gets values on the server for a given path.
     
     - Parameter atPath: The server path at which to retrieve values.
     - Parameter completion: Returns the Firebase snapshot value.
     */
    func getValues(atPath: String, completion: @escaping (Any?) -> Void) {
        Database.database().reference().child(atPath).observeSingleEvent(of: .value, with: { returnedSnapshot in
            completion(returnedSnapshot.value)
        })
    }
    
    func setValue(onKey: String, withData: Any, completion: @escaping (Error?) -> Void) {
        Database.database().reference().child(onKey).setValue(withData) { returnedError, _ in
            if let error = returnedError {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    /**
     Updates a value on the server for a given key and data bundle.
     
     - Parameter onKey: The server path at which to update values.
     - Parameter withData: The data bundle to update the server with.
     
     - Parameter completion: Returns an `Error` if unable to update values.
     */
    func updateValue(onKey: String, withData: [String: Any], completion: @escaping (Error?) -> Void) {
        Database.database().reference().child(onKey).updateChildValues(withData, withCompletionBlock: { returnedError, _ in
            if let error = returnedError {
                completion(error)
            } else {
                completion(nil)
            }
        })
    }
}
