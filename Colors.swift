//
//  Colors.swift
//  Split
//
//  Created by Timothy Chodins on 8/23/16.
//  Copyright © 2016 Tarun Khasnavis. All rights reserved.
//

import UIKit

//Use this to make gradients. Right now it just works for this particular gradient
//But will change that if we need to make another gradient...should probs just do it now...
//...yolo
class Colors {
    let colorTop = UIColor(red: 219.0/255.0, green: 221.0/255.0, blue: 222.0/255.0, alpha: 1.0)
    let colorBottom = UIColor(red: 137.0/255.0, green: 140.0/255.0, blue: 144.0/255.0, alpha: 1.0)
    
    let gl: CAGradientLayer
    
    init() {
        gl = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [ 0.0, 1.0]
    }
}
