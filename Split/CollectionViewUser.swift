//
//  CollectionViewUser.swift
//  Split
//
//  Created by Timothy Chodins on 8/22/16.
//  Copyright © 2016 Tarun Khasnavis. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


struct userState {
    
    static var users: [CollectionViewUser] = [CollectionViewUser]()

    //Itd be a shame if a user got added twice
    static var noRepeats: [String : Bool] = [String: Bool]()
}

struct curUser {
    
    static var email: String = ""
    static var name: String = ""
    static var image: UIImage = UIImage()
    
}


class CollectionViewUser {
    
    var name: String
    var uid: String
    var image: UIImage
    
    init?(name: String, uid: String, image: UIImage) {
        self.name = name
        self.uid = uid
        self.image = image
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getUid() -> String {
        return self.uid
    }
    
    func getImage() -> UIImage {
        return self.image
    }
}

func loadUsers() {
    let uid = FIRAuth.auth()?.currentUser?.uid
    let ref = FIRDatabase.database().reference()
    userState.noRepeats = [String: Bool]()
    userState.users = [CollectionViewUser]()
    
    ref.child("User").child(uid!).observeSingleEventOfType(.Value, withBlock: {
        (snapshot) -> Void in
        
        curUser.email = snapshot.value!["email"] as! String
        curUser.name = snapshot.value!["name"] as! String
        let url = snapshot.value!["picture"] as! String
        let data: NSData = NSData(base64EncodedString: url, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
        curUser.image = UIImage(data: data)!
        
        
    })
    
    ref.child("User").child(uid!).child("group").observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
            let groupid = snapshot.value as! String
            //add listener for users
        let membersRef = FIRDatabase.database().reference().child("Group").child(groupid).child("members")
        membersRef.observeEventType(.ChildAdded, withBlock: {(memberSnapshot) -> Void in
            let id = memberSnapshot.key
            if (userState.noRepeats.updateValue(true, forKey: id) != nil) {
                let userRef = ref.child("User").child(id)
                userRef.observeSingleEventOfType(.Value, withBlock: {(userSnapshot) -> Void in
                let url = userSnapshot.value!["picture"] as! String
            
                let data: NSData = NSData(base64EncodedString: url, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
            
                let name = userSnapshot.value!["name"] as! String
                let image = UIImage(data: data)!
                
                userState.users.append(CollectionViewUser.init(name: name, uid: id, image: image)!)
                let note = NSNotification.init(name: notificationKey, object: nil)
                NSNotificationCenter.defaultCenter().postNotification(note)
            })

            }
                        
        })

    })
}