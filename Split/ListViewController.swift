//
//  ListViewController.swift
//  Split
//
//  Created by Edmund Tian on 7/22/16.
//  Copyright © 2016 Tarun Khasnavis. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

var items : [Item] = []
var checkoutItems = Set<Item>()
var arrayCheckout = [String]()

class ListViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    //    // MARK: Variables
    //    var items = [Item]()
    var newItemTextField: UITextField!
//    var addTextField: UITextField
    @IBOutlet var itemsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let screen = self.view.frame
        let navigationBar = self.navigationController?.navigationBar.frame.size
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        // Add text field
        addTextField()
        
        // itemsTable appearance
        itemsTable.separatorStyle = .None
        self.view.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        itemsTable.backgroundColor = UIColor.clearColor()
        
        // itemsTable contraints
        
        let itemsTableVerticalContraint = NSLayoutConstraint(item: itemsTable, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: (navigationBar?.height)! + screen.height * 0.09)
        view.addConstraint(itemsTableVerticalContraint)
        
        let itemsTableLeading = NSLayoutConstraint(item: itemsTable, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .LeadingMargin, multiplier: 1.0, constant: -20)
        view.addConstraint(itemsTableLeading)
        
        let itemsTableTrailing = NSLayoutConstraint(item: itemsTable, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .TrailingMargin, multiplier: 1.0, constant: -20)
        view.addConstraint(itemsTableTrailing)
        
        /*
        let databaseRef = FIRDatabase.database().reference()
        let itemsRef = databaseRef.child("Items").child("test-group")
        
        let currentUser = FIRAuth.auth()?.currentUser
        let userId = currentUser?.uid
        
        let userRef = FIRDatabase.database().reference().child("User").child(userId!)
        var name = ""
        userRef.child("name").observeEventType(.Value, withBlock: {snapshot in
            print("in name")
            name = snapshot.value as! String
        })
        print("name: " + name)
        var group = ""
        userRef.child("group").observeEventType(.Value, withBlock: {snapshot in
            print("in group")
            group = snapshot.value as! String
        })
        */
        
        
        let databaseRef = FIRDatabase.database().reference()
        let currentUser = FIRAuth.auth()?.currentUser
        let userId = currentUser?.uid
        let groupRef = databaseRef.child("User").child(userId!).child("group")
        
        groupRef.observeEventType(.Value, withBlock: {
            (snapshot) in
            let group = snapshot.value as! String
            print("group: " + group)
            items = [Item]()
            let itemsRef = databaseRef.child("Items").child(group)
            
            itemsRef.queryOrderedByChild("rating").observeEventType(.ChildAdded, withBlock: {
                snapshot in
                print("observe child added")
                let name = snapshot.value!["name"] as! NSString
                let rating = snapshot.value!["rating"] as! NSNumber
                let id = snapshot.value!["id"] as! NSString
                let voted = snapshot.value!["voted"] as! Bool
                
                let item = Item(name: String(name), rating: Int(rating), id: String(id), voted: voted)
                
                print("Inserting item: " + item!.name)
                items.insert(item!, atIndex: 0)
                
                // Sort newly added data if not loading initial data
                
                items.sortInPlace({ $0.rating > $1.rating })
                
                
                self.itemsTable.reloadData()
                
            })
            print("Initial data loaded")
//            initialDataLoaded = true
            
            
            // Update items when an item is changed (like upvoted)
            
            itemsRef.queryOrderedByChild("rating").observeEventType(.ChildChanged, withBlock: {
                snapshot in
                print("observe child changed")
                let name = snapshot.value!["name"] as! NSString
                let rating = snapshot.value!["rating"] as! NSNumber
                let id = snapshot.value!["id"] as! NSString
                let voted = snapshot.value!["voted"] as! Bool
                
                let item = Item(name: String(name), rating: Int(rating), id: String(id), voted: voted)
                
                print("updating item: " + item!.name)
                //            items.insert(item!, atIndex: 0)
                
                
                self.itemsTable.reloadData()
                
            })
            
        })
        
        
        
        var initialDataLoaded = false
        print(initialDataLoaded)
        
        // Load initial data
        /*
        itemsRef.queryOrderedByChild("rating").observeEventType(.ChildAdded, withBlock: {
            snapshot in
            print("observe child added")
            let name = snapshot.value!["name"] as! NSString
            let rating = snapshot.value!["rating"] as! NSNumber
            let id = snapshot.value!["id"] as! NSString
            let voted = snapshot.value!["voted"] as! Bool
            
            let item = Item(name: String(name), rating: Int(rating), id: String(id), voted: voted)
            
            print("Inserting item: " + item!.name)
            items.insert(item!, atIndex: 0)
            
            // Sort newly added data if not loading initial data
            if initialDataLoaded {
                items.sortInPlace({ $0.rating > $1.rating })
            }
    
            self.itemsTable.reloadData()
            
        })
        print("Initial data loaded")
        initialDataLoaded = true
        
        
        // Update items when an item is changed (like upvoted)
        
        itemsRef.queryOrderedByChild("rating").observeEventType(.ChildChanged, withBlock: {
            snapshot in
            print("observe child changed")
            let name = snapshot.value!["name"] as! NSString
            let rating = snapshot.value!["rating"] as! NSNumber
            let id = snapshot.value!["id"] as! NSString
            let voted = snapshot.value!["voted"] as! Bool
            
            let item = Item(name: String(name), rating: Int(rating), id: String(id), voted: voted)
            
            print("updating item: " + item!.name)
            //            items.insert(item!, atIndex: 0)
        
            
            self.itemsTable.reloadData()
            
        })
        */
        
        // Gesture recognizer to respond to clicks on tableview
//        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard"))
//        tapGesture.cancelsTouchesInView = true
//        itemsTable.addGestureRecognizer(tapGesture)
    }
    // HideKeyboard fucntion
//    func hideKeyboard() {
//        itemsTable.endEditing(true)
//    }
    
    override func viewWillAppear(animated: Bool) {
        print("did appear")
        if itemsTable.indexPathsForSelectedRows != nil {
            print("deselcting")
            for selectedRow in itemsTable.indexPathsForSelectedRows! {
                itemsTable.deselectRowAtIndexPath(selectedRow, animated: false)
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Items
    func addItem(item: Item) {
        items.append(item)
    }
    
    // Load sample data. Not really necessary anymore
    func loadSampleItems() {
        
        let name = "Toilet paper"
        let rating = 0
        let voted = false
        
        let item : [String : AnyObject] = ["name" : name,
                                           "rating" : rating,
                                           "voted" : voted]
        
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Items").childByAutoId().setValue(item)
    }
    
    
    // MARK: Text Field
    // Adding the item (Return key)
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        // Move code below to item.swift (second init command)
        let newItem = Item(name: newItemTextField.text!, rating: 0, id: "", voted: false)
        newItem?.saveItem()
        
        //        addItem(newItem!)
        
        self.view.endEditing(true)
        newItemTextField.text = ""
        itemsTable.reloadData()
        return true
    }
    
    // Touching outside keyboard
    // Not working on table
    // Disable user interaction on tableview
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // ends editing when scrolling
//    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        self.view.endEditing(true)
//        print("Ended decelerating")
//    }
    
    
    // MARK: Table View
    /*
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Number of Rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // Cell for row. Change labels for name and rating
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ListTableViewCell";
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ListTableViewCell
        
        let item = items[indexPath.row]
        cell.nameLabel.text = item.name
        cell.ratingLabel.text = String(item.rating)
        cell.item = item
        
        
        return cell
        
    }
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return items.count
    }
    
    
    
    // Number of Rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Cell for row. Change labels for name and rating
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ListTableViewCell";
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ListTableViewCell
        
        let item = items[indexPath.section]
        cell.nameLabel.text = item.name
        cell.ratingLabel.text = String(item.rating)
        cell.item = item
        
        let databaseRef = FIRDatabase.database().reference()
        let currentUser = FIRAuth.auth()?.currentUser
        let userId = currentUser?.uid
        let groupRef = databaseRef.child("User").child(userId!).child("group")
        
        var color = UIColor.blackColor()
        
        groupRef.observeEventType(.Value, withBlock: {
            (snapshot) in
            let group = snapshot.value as! String
            print("group: " + group)
            
            let upvotedByRef = FIRDatabase.database().reference().child("Items").child(group).child(item.id).child("upvoted-by")
            
            upvotedByRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
                print("change")
                if (snapshot.hasChild(userId!)) {
                    color = UIColor(red:0.00, green:0.57, blue:1.00, alpha:1.0)
                    cell.upvoteButton.setImage(UIImage(named: "upvoteIconSelected.png"), forState: UIControlState.Normal)
                } else {
                    cell.upvoteButton.setImage(UIImage(named: "upvoteIcon.png"), forState: UIControlState.Normal)
                }
                
                cell.ratingLabel.textColor = color

            })
        })
        
        return cell
        
        
        
//        var color = UIColor.blackColor()
//        if item.votedByUser() {
//
//        }
//        cell.ratingLabel.textColor = color
        
        
        
        
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2.0
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.layer.cornerRadius = 3.5
        cell.layer.shadowColor = UIColor.blackColor().CGColor
        cell.layer.shadowOpacity = 1
//        cell.layer.shadowOffset = CGSizeMake(-1, 1)
        cell.layer.shadowRadius = 5.0
        
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = .None
        return footer
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40.0
    }
    
    // Appearance
    /*
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 140.0
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        let whiteRoundedView : UIView = UIView(frame: CGRectMake(0, 10, self.view.frame.size.width, 120))
        
        whiteRoundedView.layer.backgroundColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [1.0, 1.0, 1.0, 1.0])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 2.0
        whiteRoundedView.layer.shadowOffset = CGSizeMake(-1, 1)
        whiteRoundedView.layer.shadowOpacity = 0.2
        
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubviewToBack(whiteRoundedView)
    }
    */
    
    // Deleting item
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let itemToDelete = items[indexPath.section]
            itemToDelete.delete()
            
            items.removeAtIndex(indexPath.section);
            itemsTable.reloadData();
        }
    }
    
    // Selecting cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = items[indexPath.section]
        checkoutItems.insert(selectedItem)
        print(selectedItem.name)
        
    }
    
    // Deleselecting cell
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedItem = items[indexPath.section]
        checkoutItems.remove(selectedItem)
        print(selectedItem.name)
        print(checkoutItems)
        
    }
    
    func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        print("deselecting")
        return indexPath
    }
    
    // MARK: Helper functions
    func addTextField() {
        let screen = self.view.frame
        let navigationBar = self.navigationController?.navigationBar.frame.size
        newItemTextField = UITextField(frame: CGRectMake(0, 0, screen.width * 0.915, screen.height * 0.08))
        newItemTextField.center.x = self.view.center.x
        newItemTextField.center.y = (navigationBar?.height)! + screen.height * 0.09
        //        usernameTextField.placeholder = "Enter text here"
        newItemTextField.attributedPlaceholder = NSAttributedString(string:"Add...", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        newItemTextField.font = UIFont.systemFontOfSize(20)
        newItemTextField.textColor = UIColor.whiteColor()
        //        usernameTextField.borderStyle = UITextBorderStyle.RoundedRect
        //        usernameTextField.autocorrectionType = UITextAutocorrectionType.No
        //        usernameTextField.keyboardType = UIKeyboardType.Default
        //        usernameTextField.returnKeyType = UIReturnKeyType.Done
        //        usernameTextField.clearButtonMode = UITextFieldViewMode.WhileEditing;
        newItemTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        newItemTextField.delegate = self
        newItemTextField.backgroundColor = UIColor(red:0.18, green:0.60, blue:0.86, alpha:0.7)
        newItemTextField.layer.cornerRadius = 3.5
//        newItemTextField.background.opac
        
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.whiteColor().CGColor
        
//        border.frame = CGRect(x: 0, y: newItemTextField.frame.size.height - width, width:  newItemTextField.frame.size.width, height: newItemTextField.frame.size.height)
        
        // Add username icon
        
        let imageView = UIImageView()
        let image = UIImage(named: "plus")
        imageView.image = image
        imageView.frame = CGRect(x: 0, y: 0, width: screen.height * 0.04, height: screen.height * 0.04)
        let leftView = UIView.init(frame: CGRectMake(0, 0, screen.height * 0.08, screen.height * 0.07))
        leftView.addSubview(imageView)
        imageView.center.x = leftView.center.x
        imageView.center.y = leftView.center.y
        newItemTextField.leftViewMode = UITextFieldViewMode.Always
        newItemTextField.leftView = leftView
        
        
        border.borderWidth = width
        newItemTextField.layer.addSublayer(border)
        newItemTextField.layer.masksToBounds = true
        
        self.view.addSubview(newItemTextField)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "toProfileSegue") {
            var this = segue.destinationViewController as! ProfileViewController
            //this.fetchProfile( { (result, error) -> Void in
            //    this.setVariables(result)
                
            //})
            
        }
    }
}
