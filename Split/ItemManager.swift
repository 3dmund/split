//
//  ItemManager.swift
//  Split
//
//  Created by Edmund Tian on 7/30/16.
//  Copyright © 2016 Tarun Khasnavis. All rights reserved.
//

import UIKit

var itemMgr: ItemManager = ItemManager()

class ItemManager: NSObject {

    var items = [String]()
    
    func addItem(name: String) {
        items.append(name)
    }
    
}
