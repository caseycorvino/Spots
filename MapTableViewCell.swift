//
//  MapTableViewCell.swift
//  Spots4.9
//
//  Created by Casey Corvino on 7/9/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import UIKit

class MapTableViewCell: UITableViewCell {

    @IBOutlet var spotTitle: UILabel!
    
    @IBOutlet var spotDateCreated: UILabel!
    
    @IBOutlet var owner: UIButton!
    
    
    var spot = Spot()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
