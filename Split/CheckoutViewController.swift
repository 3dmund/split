//
//  CheckoutViewController.swift
//  Split
//
//  Created by Edmund Tian on 7/26/16.
//  Copyright © 2016 Tarun Khasnavis. All rights reserved.
//

import UIKit
import Firebase

class CheckoutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    

//    @IBOutlet var checkoutView: UITableView!
    

    @IBOutlet weak var checkoutItemsTable: UITableView!
    @IBOutlet weak var checkoutPriceTextField: UITextField!
    @IBOutlet weak var checkoutMembersCollection: UICollectionView!
    
    
    
//    ArrayList<Item.name> arr = new ArrayList<Item.name>(checkoutItems.Item.name());
    var allObjects = ["Items": arrayCheckout,"Price": ["Textfield"], "Members":["memeber"]]
    
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
//        checkedItems.removeAll()
//        print(checkedItems.count)
        print(arrayCheckout)
        checkoutItems.removeAll()
        arrayCheckout.removeAll()
        
        
//      remove all values in "Items:"
    }
    
    struct Objects {
        
        var sectionName : String!
        var sectionObjects : [String]!
    }
    
    var objectArray = [Objects]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Appearance
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        checkoutItemsTable.dataSource = self
        checkoutItemsTable.delegate = self
        checkoutMembersCollection.dataSource = self
        checkoutMembersCollection.delegate = self
        checkoutMembersCollection.layer.borderWidth = 1
        checkoutMembersCollection.allowsMultipleSelection = true
        
        checkoutMembersCollection.layer.borderColor = UIColor.blackColor().CGColor
        namesInCheckout()
//        for (key, value) in allObjects {
//            print("\(key) -> \(value)")
//            objectArray.append(Objects(sectionName: key, sectionObjects: value))
//        }
        
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.reload), name: notificationKey, object: nil)
        
    }
    
    func reload() {
        print("DICKS")
        
        self.checkoutMembersCollection.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userState.users.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
        //cell.backgroundColor = UIColor.grayColor()
        cell.layer.masksToBounds = false;
         cell.layer.shadowOffset = CGSizeMake(5.0, 5.0);
         cell.layer.shadowRadius = 5;
         cell.layer.shadowOpacity = 0.75;
        
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
        cell.layer.shadowOpacity = 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCell
        let user : CollectionViewUser = userState.users[indexPath.row]

        cell.imageView?.image = user.getImage()
        cell.nameLabel.text = user.getName().characters.split{$0 == " "}.map(String.init)[0]        
        return cell
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCheckout.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "checkoutItemsCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CheckoutItemsTableViewCell
        let item = arrayCheckout[indexPath.row]
        print(item)
        cell.itemLabel.text = item
        return cell
        
        /*
        if (indexPath.section == 0) {
            self.checkoutView.registerClass(CheckoutTableViewCellOne.self, forCellReuseIdentifier: "cellOne")
            let cellIdentifier = "cellOne"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CheckoutTableViewCellOne
            let item = arrayCheckout[indexPath.row]
            print(item)
            cell.itemLabel.text = item
            return cell
        }
        else if (indexPath.section == 1) {
            self.checkoutView.registerClass(CheckoutTwoTableViewCell.self, forCellReuseIdentifier: "cellTwo")
            let cell = tableView.dequeueReusableCellWithIdentifier("cellTwo", forIndexPath: indexPath) as! CheckoutTwoTableViewCell
            return cell
        }
        else {
            self.checkoutView.registerClass(CheckoutThreeTableViewCell.self, forCellReuseIdentifier: "cellThree")
            let cell = tableView.dequeueReusableCellWithIdentifier("cellThree", forIndexPath: indexPath) as! CheckoutThreeTableViewCell
            return cell
        }
        */
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        
    }
    

}
