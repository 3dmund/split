//
//  ProfileViewController.swift
//  Split
//
//  Created by Tarun Khasnavis on 7/19/16.
//  Copyright © 2016 Tarun Khasnavis. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseAuth

//ADD BLUR IMAGE METHOD TO UIIMAGEVIEW
extension UIImageView {
    
    func blurImage() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(blurEffectView)
    }
    
}

//Went a little overkill I think
//Copied all the code doe
//but use this to be able to add whatever border you want to a uiview
extension UIView {
    func addBorder(edges edges: UIRectEdge, colour: UIColor = UIColor.whiteColor(), thickness: CGFloat = 1) -> [UIView] {
        
        var borders = [UIView]()
        
        func border() -> UIView {
            let border = UIView(frame: CGRectZero)
            border.backgroundColor = colour
            border.translatesAutoresizingMaskIntoConstraints = false
            return border
        }
        
        if edges.contains(.Top) || edges.contains(.All) {
            let top = border()
            addSubview(top)
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[top(==thickness)]",
                    options: [],
                    metrics: ["thickness": thickness],
                    views: ["top": top]))
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[top]-(0)-|",
                    options: [],
                    metrics: nil,
                    views: ["top": top]))
            borders.append(top)
        }
        
        if edges.contains(.Left) || edges.contains(.All) {
            let left = border()
            addSubview(left)
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[left(==thickness)]",
                    options: [],
                    metrics: ["thickness": thickness],
                    views: ["left": left]))
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[left]-(0)-|",
                    options: [],
                    metrics: nil,
                    views: ["left": left]))
            borders.append(left)
        }
        
        if edges.contains(.Right) || edges.contains(.All) {
            let right = border()
            addSubview(right)
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("H:[right(==thickness)]-(0)-|",
                    options: [],
                    metrics: ["thickness": thickness],
                    views: ["right": right]))
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[right]-(0)-|",
                    options: [],
                    metrics: nil,
                    views: ["right": right]))
            borders.append(right)
        }
        
        if edges.contains(.Bottom) || edges.contains(.All) {
            let bottom = border()
            addSubview(bottom)
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("V:[bottom(==thickness)]-(0)-|",
                    options: [],
                    metrics: ["thickness": thickness],
                    views: ["bottom": bottom]))
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[bottom]-(0)-|",
                    options: [],
                    metrics: nil,
                    views: ["bottom": bottom]))
            borders.append(bottom)
        }
        
        return borders
    }
}



class ProfileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerView2: UIView!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var toBlur: UIImageView!
    
  //  var email: String = ""
  //  var profilePicture: UIImage? = nil
  //  var name: String = ""
    
    @IBAction func didTapLogout(sender: AnyObject) {
        // sign the user out of the Firebase app
        try! FIRAuth.auth()!.signOut()
        
        //signs the user out of Facebook app
        FBSDKAccessToken.setCurrentAccessToken(nil)
        
        //Move user back to login
        let mainStoryboard: UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let viewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoginView")
        self.presentViewController(viewController, animated: true, completion: nil)
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.  
        
        // Navigation bar text color
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        let colors = Colors()
        
        
        let email = curUser.email
        let name = curUser.name
        let image = curUser.image
        self.view.backgroundColor = UIColor.lightGrayColor()
        self.nameTextField.text = name
        self.emailLabel.text = email
        self.toBlur.image = image
        self.toBlur.blurImage()
        self.profilePictureView.image = image
        self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.width / 2
        self.profilePictureView.clipsToBounds = true
        self.view.bringSubviewToFront(profilePictureView)
        self.view.sendSubviewToBack(toBlur)
        self.containerView.addBorder(edges: [UIRectEdge.Bottom], colour: UIColor.grayColor())
        
        self.containerView2.backgroundColor = UIColor.clearColor()
        let backgroundLayer = colors.gl
        backgroundLayer.frame = self.containerView2.frame
        self.containerView2.layer.insertSublayer(backgroundLayer, atIndex: 0)
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
