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

class ViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    //Login Button
    var curUser: User?
    var logoLabel: UILabel = UILabel()
    var usernameTextField: UITextField = UITextField()
    var passwordTextField: UITextField = UITextField()
    var loginButton: UIButton = UIButton()
    var loginFacebookButton: FBSDKLoginButton = FBSDKLoginButton()
    var signUpButton: UIButton = UIButton()
    
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginFacebookButton.hidden = true
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let user = user {
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
                    if (!snapshot.exists() || snapshot.value!["group"] as! String == "") {
                        //No, then go to groupprompt
                        self.performSegueWithIdentifier("toGroupPrompt", sender: nil)
                    }
                        
                        
                    else {
                        
                        //Yes, then go to list
                        
                        //                    print(snapshot.value!["group"])
                        loadUsers()
                        let MainScreenViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("Main")
                        self.presentViewController(MainScreenViewController, animated: true, completion: nil)
                    }
                })
            }
                
                
            else {
                self.addBackground()
                self.addLogoLabel()
                self.addUsernameTextField()
                self.addPasswordTextField()
                self.addLoginButton()
                self.addFacebookLoginButton()
                self.addSignUpButton()
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
        self.loginFacebookButton.hidden = true
        self.logoLabel.hidden = true
        self.usernameTextField.hidden = true
        self.passwordTextField.hidden = true
        self.loginButton.hidden = true
        self.signUpButton.hidden = true
        self.logoLabel.hidden = true
        
        
        //start loading spinner animation
        loadingSpinner.startAnimating()
        
        if (error != nil)
        {
            // handle errors logging in here
            self.loginFacebookButton.hidden = false
            
            //stop spinner animation
            loadingSpinner.stopAnimating()
        }
        else if(result.isCancelled)
        {
            //handle cancel event
            self.loginFacebookButton.hidden = false
            
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
    
    // MARK: Appearance
    func addBackground() {
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.image = UIImage(named: "loginBackground")
        self.view.addSubview(imageView)
        
    }
    
    func addLogoLabel() {
        let screen = self.view.frame
        logoLabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        
        logoLabel.textColor = UIColor.whiteColor()
        logoLabel.text = "Split"
        //        logoLabel.font = UIFont.systemFontOfSize(30)
        logoLabel.font = UIFont(name: "PoetsenOne-Regular", size: 70)
        
        logoLabel.sizeToFit()
        logoLabel.center.x = self.view.center.x
        logoLabel.center.y = screen.height * 0.2
        self.view.addSubview(logoLabel)
    }
    
    
    
    func addUsernameTextField() {
        let screen = self.view.frame
        usernameTextField = UITextField(frame: CGRectMake(0, 0, screen.width * 0.8, screen.height * 0.06))
        usernameTextField.center.x = self.view.center.x
        usernameTextField.center.y = self.view.center.y
        //        usernameTextField.placeholder = "Enter text here"
        usernameTextField.attributedPlaceholder = NSAttributedString(string:"Email", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        usernameTextField.font = UIFont.systemFontOfSize(15)
        usernameTextField.textColor = UIColor.whiteColor()
        //        usernameTextField.borderStyle = UITextBorderStyle.RoundedRect
        //        usernameTextField.autocorrectionType = UITextAutocorrectionType.No
        //        usernameTextField.keyboardType = UIKeyboardType.Default
        //        usernameTextField.returnKeyType = UIReturnKeyType.Done
        //        usernameTextField.clearButtonMode = UITextFieldViewMode.WhileEditing;
        usernameTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        usernameTextField.delegate = self
        //        usernameTextField.backgroundColor = UIColor.clearColor()
        
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.whiteColor().CGColor
        border.frame = CGRect(x: 0, y: usernameTextField.frame.size.height - width, width:  usernameTextField.frame.size.width, height: usernameTextField.frame.size.height)
        
        // Add username icon
        let imageView = UIImageView()
        let image = UIImage(named: "usernameIcon")
        imageView.image = image
        imageView.frame = CGRect(x: 0, y: 0, width: screen.height * 0.03, height: screen.height * 0.03)
        let leftView = UIView.init(frame: CGRectMake(0, 0, screen.height * 0.05, screen.height * 0.04))
        leftView.addSubview(imageView)
        usernameTextField.leftViewMode = UITextFieldViewMode.Always
        usernameTextField.leftView = leftView
        
        border.borderWidth = width
        usernameTextField.layer.addSublayer(border)
        usernameTextField.layer.masksToBounds = true
        
        self.view.addSubview(usernameTextField)
    }
    
    func addPasswordTextField() {
        let screen = self.view.frame
        passwordTextField = UITextField(frame: CGRectMake(0, 0, 300, 40))
        passwordTextField.center.x = self.view.center.x
        passwordTextField.center.y = screen.height * 0.6
        //        usernameTextField.placeholder = "Enter text here"
        passwordTextField.attributedPlaceholder = NSAttributedString(string:"Password", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordTextField.font = UIFont.systemFontOfSize(15)
        passwordTextField.textColor = UIColor.whiteColor()
        //        usernameTextField.borderStyle = UITextBorderStyle.RoundedRect
        //        usernameTextField.autocorrectionType = UITextAutocorrectionType.No
        //        usernameTextField.keyboardType = UIKeyboardType.Default
        //        usernameTextField.returnKeyType = UIReturnKeyType.Done
        //        usernameTextField.clearButtonMode = UITextFieldViewMode.WhileEditing;
        passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        passwordTextField.delegate = self
        //        usernameTextField.backgroundColor = UIColor.clearColor()
        
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.whiteColor().CGColor
        border.frame = CGRect(x: 0, y: passwordTextField.frame.size.height - width, width:  passwordTextField.frame.size.width, height: passwordTextField.frame.size.height)
        
        // Add password icon
        let imageView = UIImageView()
        let image = UIImage(named: "passwordIcon")
        imageView.image = image
        imageView.frame = CGRect(x: 0, y: 0, width: screen.height * 0.03, height: screen.height * 0.03)
        let leftView = UIView.init(frame: CGRectMake(0, 0, screen.height * 0.05, screen.height * 0.04))
        leftView.addSubview(imageView)
        passwordTextField.leftViewMode = UITextFieldViewMode.Always
        passwordTextField.leftView = leftView
        
        border.borderWidth = width
        passwordTextField.layer.addSublayer(border)
        passwordTextField.layer.masksToBounds = true
        
        passwordTextField.secureTextEntry = true
        
        self.view.addSubview(passwordTextField)
    }
    
    func addLoginButton() {
        let screen = self.view.frame
        loginButton = UIButton(frame: CGRectMake(0, 0, screen.width * 0.8, screen.height * 0.06))
        loginButton.center.x = self.view.center.x
        loginButton.center.y = screen.height * 0.7
        loginButton.setTitle("Log in", forState: .Normal)
        loginButton.backgroundColor = UIColor(red:0.25, green:0.66, blue:0.96, alpha:1.0)
        loginButton.layer.cornerRadius = 3
        
        self.view.addSubview(loginButton)
        
    }
    
    func addFacebookLoginButton() {
        let screen = self.view.frame
        loginFacebookButton.frame = CGRectMake(0, 0, screen.width * 0.8, screen.height * 0.06)
        
        self.loginFacebookButton.center.x = self.view.center.x
        self.loginFacebookButton.center.y = screen.height * 0.77
        
        
        self.loginFacebookButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.loginFacebookButton.delegate = self;
        self.view!.addSubview(self.loginFacebookButton)
        self.loginFacebookButton.hidden = false
    }
    
    func addSignUpButton() {
        let screen = self.view.frame
        signUpButton = UIButton(frame: CGRectMake(0, 0, screen.width * 0.8, screen.height * 0.06))
        signUpButton.center.x = self.view.center.x
        signUpButton.center.y = screen.height * 0.84
        signUpButton.setTitle("Sign up", forState: .Normal)
        signUpButton.setTitleColor(UIColor(red:0.25, green:0.66, blue:0.96, alpha:1.0), forState: .Normal)
        signUpButton.backgroundColor = UIColor.whiteColor()
        signUpButton.layer.cornerRadius = 3
        
        signUpButton.addTarget(self, action: "signUp:", forControlEvents: UIControlEvents.TouchUpInside)
        signUpButton.tag = 1
        
        self.view.addSubview(signUpButton)
        
    }
    
    func signUp(sender: UIButton!) {
        var btnsendtag: UIButton = sender
        if btnsendtag.tag == 1 {
            print("signup button pressed")
        }
    }
    
    // MARK:- ---> Textfield Delegates
    func textFieldDidBeginEditing(textField: UITextField) {
        print("TextField did begin editing method called")
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        print("TextField did end editing method called")
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        print("TextField should begin editing method called")
        return true;
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        print("TextField should clear method called")
        return true;
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        print("TextField should snd editing method called")
        return true;
    }
    
    //    var password: String = ""
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        print("While entering the characters this method gets called")
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("TextField should return method called")
        textField.resignFirstResponder();
        return true;
    }
    // MARK: Textfield Delegates <---
    
}
