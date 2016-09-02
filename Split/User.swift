//
//  User.swift
//  Split
//
//  Created by Timothy Chodins on 8/6/16.
//  Copyright © 2016 Tarun Khasnavis. All rights reserved.
//

import UIKit
import Firebase


class User {
    //MARK: Properties
    var name: String
    var picture: String
    var snapshot: FIRDataSnapshot?
    var facebook: Bool = false
    var email: String
    var uid: String = ""
    
    init?(name: String, email: String, picture: String, facebook: Bool, uid: String) {
        self.name = name
        self.picture = picture
        self.email = email
        self.facebook = facebook
        if facebook {
            self.uid = uid
        }
    }
    
    func addUser() {
        var user : [String : AnyObject] = ["name" : name, "picture" : picture, "email" : email, "facebook": facebook]
        
        let databaseRef = FIRDatabase.database().reference()
        let newData : FIRDatabaseReference
        
        if user["facebook"] as! Bool {
            newData = databaseRef.child("User").child(self.uid)
            
        } else {
            newData = databaseRef.child("User").childByAutoId()
            let id = newData.key
            self.uid = id
        }
        user["group"] = ""
        
        
        newData.setValue(user)
    }
    
}

