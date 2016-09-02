//
//  mainScreenViewController.swift
//  Split
//
//  Created by Edmund Tian on 7/22/16.
//  Copyright © 2016 Tarun Khasnavis. All rights reserved.
//

import UIKit

class MainScreenViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Set initial view
        self.selectedIndex = 1;
    }
    
    override func viewDidAppear(animated: Bool) {
        
//        self.selectedIndex = 1;
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
