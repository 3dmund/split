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

class GroupPromptViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    
    var text = String()
    var uid = String()
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
        self.uid = (FIRAuth.auth()?.currentUser?.uid)!
        
    }
    
    
    /*
     //IF text fields aren't valid, disable the buttons
     func validateTextFields() {
     
     var text = joinTextField.text ?? ""
     joinButton.enabled = (!text.isEmpty && text.characters.count == 6)
     text = createTextField.text ?? ""
     createButton.enabled = (!text.isEmpty)
     
     
     }*/
    
    //MARK: -- Actions
    @IBAction func joinPressed(sender: UIButton) {
        
        //CREATE ALEART TO MAKE SURE THEY WANNA CREATE
        let alertController = UIAlertController(title: "Passcode", message: "Enter group's 6-digit passcode." , preferredStyle: .Alert)
        
        var code = String()
        
        
        //IF THEY REALLLLLY WANT TO CREATE A GROUP
        let joinAction = UIAlertAction(title: "Join", style: .Default, handler: {(action: UIAlertAction) in
            let codeRef = FIRDatabase.database().reference().child("Passcode").child(code)
            codeRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
                if !snapshot.exists() {
                    alertController.textFields![0].text = "Passcode doesn't exist"
                } else {
                    let groupid = snapshot.value as! String
                    let ref = FIRDatabase.database().reference()
                    ref.child("User").child(self.uid).child("group").setValue(groupid)
                    ref.child("Group").child(groupid).child("members").child(self.uid).setValue(true)
                    self.transToList()
                }
                
            })
        })
        
        joinAction.enabled = false
        
        //CONFIGURE PASSCODE TEXTFIELD
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "6-Digit Passcode"
            textField.keyboardType = UIKeyboardType.NumberPad
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                joinAction.enabled = (textField.text!.characters.count == 6)
                code = textField.text!
            }
        }
        
        //IF THEY DON't WANT TO I UNDERSTAND, BUT..they are no longer invited to my bday pt
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(joinAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //PRESENTS LIST VIEW CONTROLLER
    func transToList() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let MainScreenViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("Main")
        self.presentViewController(MainScreenViewController, animated: true, completion: nil)
    }
    
    
    
    func getPassCode() -> String{
        var passCode = ""
        passCode = String(arc4random_uniform(999999) + 1)
        while passCode.characters.count < 6 {
            passCode.insert("0", atIndex: passCode.startIndex)
        }
        print(passCode)
        
        return passCode
    }
    
    
    
    @IBAction func createPressed(sender: UIButton) {
        
        
        var groupname = String()
        
        //CREATE ALEART TO MAKE SURE THEY WANNA CREATE
        let alertController = UIAlertController(title: "Groupname", message: "Enter your group name." , preferredStyle: .Alert)
        
        //IF THEY REALLLLLY WANT TO CREATE A GROUP
        let createAction = UIAlertAction(title: "Create", style: .Default, handler: {(action: UIAlertAction) in
            let codeRef = FIRDatabase.database().reference().child("Passcode")
            codeRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
                var passcode = String()
                var newNumber = true
                while(newNumber) {
                    passcode = self.getPassCode()
                    if snapshot.hasChild(passcode) {
                        passcode = self.getPassCode()
                    } else {
                        newNumber = false
                    }
                }
                
                
                //Informaiton to save to backend
                let toSave = ["name": groupname, "passcode" : passcode, "members": [self.uid: true]]
                
                let ref = FIRDatabase.database().reference().child("Group").childByAutoId()
                let groupID = ref.key
                ref.setValue(toSave)
                
                FIRDatabase.database().reference().child("User").child(self.uid).child("group").setValue(groupID)
                codeRef.child(passcode).setValue(groupID)
                
                self.transToList()
            })
            
        })
        
        createAction.enabled = false
        
        //CONFIGURE PASSCODE TEXTFIELD
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Group Name"
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                createAction.enabled = (textField.text!.characters.count > 0)
                groupname = textField.text!
            }
        }
        
        //IF THEY DON't WANT TO I UNDERSTAND, BUT..they are no longer invited to my bday pt
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: -- Delegates and datasources
    /*func textFieldShouldReturn(textField: UITextField) -> Bool {
     textField.resignFirstResponder();
     
     return true
     }
     
     func textFieldDidBeginEditing(textField: UITextField) {
     
     joinButton.enabled = false
     createButton.enabled = false
     
     }
     func textFieldDidEndEditing(textField: UITextField) {
     validateTextFields()
     }
     */
    // Touching outside keyboard
    // Not working on table
    // Disable user interaction on tableview
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
