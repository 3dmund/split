//
//  Item.swift
//  Split
//
//  Created by Edmund Tian on 8/1/16.
//  Copyright © 2016 Tarun Khasnavis. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

// Equals function for hashable
func ==(left: Item, right: Item) -> Bool {
    if (left.name != right.name) {
        return false
    }
    if (left.rating != right.rating) {
        return false
    }
    if (left.id != right.id) {
        return false
    }
    if (left.voted != right.voted) {
        return false
    }
    return true
}

func namesInCheckout() -> Array<String> {
    for Item in checkoutItems {
        print("inserting" + Item.name)
        arrayCheckout.append(Item.name)
    }
    return arrayCheckout
}

class Item: Hashable {
    
    // MARK: Properties
    
    var name: String
    var rating: Int
    var id: String
    var voted: Bool
    var snapshot: FIRDataSnapshot?
    
    // Hashvalue
    var hashValue: Int {
        return self.id.hashValue
    }
    
    // MARK: Initialization
    
    init?(name: String, rating: Int, id: String, voted: Bool) {
        self.name = name
        self.rating = rating
        self.id = id
        self.voted = voted
        if (name.isEmpty || rating < 0) {
            return nil
        }
    }
    
    // Init for JSON Firebase Objects
    //    init(snapshot: FIRDataSnapshot) {
    //        name = snapshot.value!["name"] as! NSString
    //        rating = snapshot.value!["rating"] as! NSNumber
    //        voted = snapshot.value!["voted"]
    //    }
    
    // Add item to backend. Called when item added with return key
    func saveItem() {
        var item : [String : AnyObject] = ["name" : name,
                                           "rating" : rating,
                                           "voted" : voted,
                                           "upvoted-by" : ["true" : true]]
        
        let databaseRef = FIRDatabase.database().reference()
        let currentUser = FIRAuth.auth()?.currentUser
        let userId = currentUser?.uid
        let groupRef = databaseRef.child("User").child(userId!).child("group")
        
        groupRef.observeEventType(.Value, withBlock: {
            (snapshot) in
            let group = snapshot.value as! String
            print("group: " + group)
            
            // Create new child with generated id
            let newData = databaseRef.child("Items").child(group).childByAutoId()
            
            // Save id to local item and backend
            let id = newData.key
            self.id = id
            item["id"] = id
            newData.setValue(item)
        })
        
        /*
        let group = databaseRef.child("User").child(userId!).valueForKey("group") as! String
        print("group: " + group)
        
        // Create new child with generated id
        let newData = databaseRef.child("Items").child("test-group").childByAutoId()
        
        // Save id to local item and backend
        let id = newData.key
        self.id = id
        item["id"] = id
        newData.setValue(item)
        */
    }
    
    // Update backend for item
    func update(id: String, updates: Dictionary<String, AnyObject>) {
        let databaseRef = FIRDatabase.database().reference()
        let objectToUpdate = databaseRef.child("Items").child("test-group").child(id)
        objectToUpdate.updateChildValues(updates)
        
    }
    
    // Called when upvote button pressed
    func upvote() {
        let databaseRef = FIRDatabase.database().reference()
        let currentUser = FIRAuth.auth()?.currentUser
        let userId = currentUser?.uid
        let groupRef = databaseRef.child("User").child(userId!).child("group")
        
        groupRef.observeEventType(.Value, withBlock: {
            (snapshot) in
            let group = snapshot.value as! String
            print("group: " + group)
            
            let upvotedByRef = FIRDatabase.database().reference().child("Items").child(group).child(self.id).child("upvoted-by")
            
            upvotedByRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
                print("change")
                if (snapshot.hasChild(userId!)) {
                    print("has child")
                    self.rating -= 1
                    self.voted = false
                    let itemToRemove = upvotedByRef.child(userId!)
                    itemToRemove.removeValue()
                }
                else {
                    print("doesn't")
                    self.rating += 1
                    self.voted = true
                    upvotedByRef.child(userId!).setValue(true)
                }
                let ratingRef = FIRDatabase.database().reference().child("Items").child(group).child(self.id).child("rating")
                ratingRef.setValue(self.rating)
                items.sortInPlace({ $0.rating > $1.rating })
            })
        })
        
        
        print("rating after upvote: " + String(self.rating))
        /*
        if self.voted == false {
            self.rating += 1
        } else {
            self.rating -= 1
        }
         */
        /*
        self.voted = !self.voted
        let updates = ["rating": self.rating] as! Dictionary<String, AnyObject>
        update(self.id, updates: updates)
        */
    }
    /*
    func votedByUser() -> Bool {
        let currentUser = FIRAuth.auth()?.currentUser
        let userId = currentUser?.uid
        let userRef = FIRDatabase.database().reference().child("User").child((currentUser?.uid)!)
        let group = userRef.valueForKey("group") as! String
        let upvotedByRef = FIRDatabase.database().reference().child("Items").child(group).child(id).child("upvoted-by")
        
        print("rating before upvote: " + String(self.rating))
        
        var votedByUser = false
        upvotedByRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
//            print("change")
            if (snapshot.hasChild(userId!)) {
                votedByUser = true
            }
        })
        return votedByUser
    }
    */
    
    // Deleting from backend
    func delete() {
        let databaseRef = FIRDatabase.database().reference()
        let currentUser = FIRAuth.auth()?.currentUser
        let userId = currentUser?.uid
        let groupRef = databaseRef.child("User").child(userId!).child("group")
        
        groupRef.observeEventType(.Value, withBlock: {
            (snapshot) in
            let group = snapshot.value as! String
            print("group: " + group)
            
            let itemToRemove = databaseRef.child("Items").child(group).child(self.id)
            itemToRemove.removeValue()
        })
        
        /*
        let databaseRef = FIRDatabase.database().reference()
        let itemToRemove = databaseRef.child("Items").child("test-group").child(id)
        itemToRemove.removeValue()
        */
    }
    
}