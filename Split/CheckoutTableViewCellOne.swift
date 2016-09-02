//
//  CheckoutTableViewCellOne.swift
//  Split
//
//  Created by Tarun Khasnavis on 8/15/16.
//  Copyright © 2016 Tarun Khasnavis. All rights reserved.
//

import UIKit

class CheckoutTableViewCellOne: UITableViewCell {
    
    var itemLabel: UILabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(itemLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
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
