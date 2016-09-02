//
//  CheckoutItemsTableViewCell.swift
//  Split
//
//  Created by Edmund Tian on 8/21/16.
//  Copyright © 2016 Tarun Khasnavis. All rights reserved.
//

import UIKit

class CheckoutItemsTableViewCell: UITableViewCell {

    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        itemLabel = UILabel(frame: CGRectMake(20, 10, self.bounds.size.width - 40, 25))
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
