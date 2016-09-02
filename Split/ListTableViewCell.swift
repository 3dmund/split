//
//  ListTableViewCell.swift
//  Split
//
//  Created by Edmund Tian on 8/1/16.
//  Copyright © 2016 Tarun Khasnavis. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    // MARK: Properties
    var item: Item!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var upvoteButton: UIButton!
    
    
    // Upvote button pressed. Calls Item.upvote()
    @IBAction func upvotePressed(sender: AnyObject) {
        ratingLabel.text = String(item.rating)
        item.upvote()
        items.sortInPlace({ $0.rating > $1.rating })
//        var color = UIColor.blackColor()
//        if item.voted {
//            color = UIColor(red:0.00, green:0.57, blue:1.00, alpha:1.0)
//        }
//        ratingLabel.textColor = color
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        self.backgroundColor = UIColor.blueColor()
//        self.bounds = CGRect(x: 0, y: 0, width: 300, height: 80)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
        

}
