//
//  ToBuyViewController.swift
//  Split
//
//  Created by Tarun Khasnavis on 7/18/16.
//  Copyright © 2016 Tarun Khasnavis. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseAuth

class ToBuyViewController: UIViewController {

//    @IBAction func didTapLogout(sender: AnyObject) {
//        // sign the user out of the Firebase app
//        try! FIRAuth.auth()!.signOut()
//            
//        //signs the user out of Facebook app
//        FBSDKAccessToken.setCurrentAccessToken(nil)
//            
//        //Move user back to login
//        let mainStoryboard: UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
//        let viewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoginView")
//        self.presentViewController(viewController, animated: true, completion: nil)
//    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
