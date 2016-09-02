//
//  ViewController.swift
//  Split
//
//  Created by Tarun Khasnavis on 7/18/16.
//  Copyright © 2016 Tarun Khasnavis. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FirebaseAuth

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    //Login Button
    var loginButton: FBSDKLoginButton = FBSDKLoginButton()
    var curUser: User?
    
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginButton.hidden = true
        
        print(1)
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            print(2)
            if let user = user {
                print(3)
                // User is signed in.
                // Move User to home screen
                /*
                 let mainStoryboard: UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                 let ToBuyViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ToBuy")
                 self.presentViewController(ToBuyViewController, animated: true, completion: nil)
                 */
                // Edmund's testing
                
                //DATABASE USER INFORMATION
                
                let ref = FIRDatabase.database().reference().child("User").child(user.uid)
                let mainStoryboard: UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                let currentUser = FIRAuth.auth()?.currentUser
                let userRef = FIRDatabase.database().reference().child("User").child((currentUser?.uid)!)
                
                userRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
                    print("reading")
                    if (!snapshot.exists() || snapshot.value!["group"] as! String == "") {
                        //No, then go to groupprompt
                        self.performSegueWithIdentifier("toGroupPrompt", sender: nil)
                    }
                        
                        
                    else {
                        
                        //Yes, then go to list
                        
                        //                    print(snapshot.value!["group"])
                        let MainScreenViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("Main")
                        self.presentViewController(MainScreenViewController, animated: true, completion: nil)
                    }
                })
            }
                
                
            else {
                self.loginButton.center = self.view.center
                self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
                self.loginButton.delegate = self;
                self.view!.addSubview(self.loginButton)
                self.loginButton.hidden = false
            }
        }
    }
    
    func check() -> Bool {
        let currentUser = FIRAuth.auth()?.currentUser
        let userRef = FIRDatabase.database().reference().child("User").child((currentUser!.uid))
        var toReturn = false
        var halt = true
        while (halt) {
            userRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
                print("observing userRef")
                if !snapshot.exists()  {
                    toReturn = true
                } else if (snapshot.value!["group"] as! String).isEmpty {
                    toReturn = true
                }
                halt = false
            })
        }
        
        
        return toReturn
        
    }
    
    
    func setUser(uid: String) {
        let ref = FIRDatabase.database().reference().child("User").child(uid)
        ref.observeSingleEventOfType(.Value, withBlock : {(snapshot) -> Void in
            self.curUser = User(name: snapshot.value!["name"] as! String, email: snapshot.value!["email"] as! String, picture: snapshot.value!["picture"] as! String, facebook: snapshot.value!["facebook"] as! Bool, uid: uid)
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Logs user in
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        print("User logged32 in")
        
        // hide login button
        self.loginButton.hidden = true
        
        //start loading spinner animation
        loadingSpinner.startAnimating()
        
        if (error != nil)
        {
            // handle errors logging in here
            self.loginButton.hidden = false
            
            //stop spinner animation
            loadingSpinner.stopAnimating()
        }
        else if(result.isCancelled)
        {
            //handle cancel event
            self.loginButton.hidden = false
            
            //stop spinner animation
            loadingSpinner.stopAnimating()
        } else {
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            
            //User logs in
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                let ref = FIRDatabase.database().reference()
                print(user!.uid)
                ref.child("User").child(user!.uid).observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
                    //If its their first time logging in, snapshot will not exist
                    if !snapshot.exists() {
                        print("snapshot doesn't exist")
                        self.fetchProfile( {(toPass, error) -> Void in
                            let strBase64: String
                            
                            if let url = toPass["url"] {
                                let nsurl: NSURL = NSURL(string: url)!
                                let imageData: NSData = NSData.init(contentsOfURL: nsurl)!
                                strBase64 = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                            } else {
                                strBase64 = ""
                            }
                            
                            //This is pointless right now. Should probably take out.
                            self.curUser = User(name: toPass["name"]!, email: toPass["email"]!, picture: strBase64, facebook: true, uid: user!.uid)!
                            self.curUser!.addUser()
                        })
                    } else {
                        print("THIS SHIT ACTUALLY WORKS")
                    }
                    
                })
                print("User logged into Firebase")
            }
        }
    }
    
    //Logs user out
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("USer logged out")
    }
    
    //Function which fetches information from Facebook SDK
    func fetchProfile(completionHandler: ([String: String], NSError?) -> Void) {
        
        //Requesting email, name, and profile picture
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        var passOn = [String: String]()
        
        //Start information fetching
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler( { (connection, result, error) -> Void in
            //Handle error
            if error != nil {
                return
            }
            //Store the email, picture, and name as static variables
            if let email1 = result["email"] as? String {
                passOn["email"] = String.init(stringInterpolationSegment: email1)
                print(passOn["email"])
            } else {
                passOn["email"] = ""
            }
            if let picture = result["picture"] as? NSDictionary, data = picture["data"] as? NSDictionary,
                url = data["url"] as? String {
                passOn["url"] = url
            } else {
                passOn["url"] = ""
            }
            if let firstName = result["first_name"] as? String, lastName = result["last_name"] as? String {
                passOn["name"] = firstName + " " + lastName
            } else {
                passOn["name"] = ""
            }
            completionHandler(passOn, nil)
            
        })
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("ASS")
        if segue.identifier == "toGroupPrompt" {
            let dest = segue.destinationViewController as! GroupPromptViewController
        }
        
    }
}

