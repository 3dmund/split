//
//  CommunityViewController.swift
//  Split
//
//  Created by Timothy Chodins on 8/19/16.
//  Copyright © 2016 Tarun Khasnavis. All rights reserved.
//

import UIKit
import Firebase


let notificationKey = "USERADDED"

class CommunityViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var imageArray : [UIImage] = [UIImage]()
    var nameArray : [String] = [String]()
    var users: [String] = [String]()
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        if userState.users.isEmpty {
            
            loadUsers()

        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.reload), name: notificationKey, object: nil)
        
    }
    
    func reload() {
        print(userState.users.count)
        self.collectionView.reloadData()
    }
    
    func printName() {
        let ref = FIRDatabase.database().reference().child("User").child(users.last!)
        ref.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
            let url = snapshot.value!["picture"] as! String
            print(url)
            
            let data: NSData = NSData(base64EncodedString: url, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
            
            let name = snapshot.value!["name"] as! String
            self.imageArray.append(UIImage(data: data)!)
            self.nameArray.append(name)
            self.count += 1
            self.collectionView.reloadData()
        })
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userState.users.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCell
        
        let user : CollectionViewUser = userState.users[indexPath.row]
        
        cell.imageView?.image = user.getImage()
        cell.nameLabel.text = user.getName()
        
        
        cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.width)! / 2
        cell.imageView?.clipsToBounds = true
        /*cell.imageView?.layer.masksToBounds = false;
         cell.imageView?.layer.shadowOffset = CGSizeMake(5.0, 5.0);
         cell.imageView?.layer.shadowRadius = 5;
         cell.imageView?.layer.shadowOpacity = 0.5;*/
        return cell
    }
    
    
    
    //sets listener for users in group, assumes valid groupid
    func setListener(groupid: String) {
        
        let ref = FIRDatabase.database().reference().child("Group").child(groupid).child("members")
        ref.observeEventType(.ChildAdded, withBlock: {(snapshot) -> Void in
            self.users.append(snapshot.key)
            //Notifications are cool, this one hits us up that it just got one user
            NSNotificationCenter.defaultCenter().postNotificationName(notificationKey, object: self)
            
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
}
