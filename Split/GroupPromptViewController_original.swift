//
//  GroupPrompt.swift
//  Split
//
//  Created by Timothy Chodins on 8/15/16.
//  Copyright © 2016 Tarun Khasnavis. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class GroupPromptViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var invitationPicker: UIPickerView!
    @IBOutlet weak var groupTextField: UITextField!
    var user : User?
    var pickerData : [String] = [String]()

    
    /*
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentUser = FIRAuth.auth()?.currentUser
        let ref = FIRDatabase.database().reference().child("User").child(currentUser!.uid)
        ref.child("groupInvitations").queryOrderedByChild("groupName").observeEventType(.ChildAdded, withBlock: {(snapshot) -> Void in
            
            let name = snapshot.value!["groupName"] as! String
            self.pickerData.append(name)
            
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //CHECK IF USER HAS GROUP INVITATIONS
        
        
        /*observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
         if snapshot.exists() {
         ref.child("groupInvitations").queryOrderedByChild("groupName").
         }
         
         })
         */
        
    }
    
    //MARK: -- Delegates and datasources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        
        return true
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //DO SOMETHING LATER
    }
    
    // Touching outside keyboard
    // Not working on table
    // Disable user interaction on tableview
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

