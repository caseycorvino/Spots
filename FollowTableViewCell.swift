//
//  FollowTableViewCell.swift
//  Spots4.9
//
//  Created by Casey Corvino on 6/28/17.
//  Copyright © 2017 Spots. All rights reserved.
//

import UIKit

class FollowTableViewCell: UITableViewCell {

    @IBOutlet var followName: UILabel!
    
    @IBOutlet var followImageView: UIView!
    
    @IBOutlet var followButton: UIButton!
    
    @IBOutlet var followButtonBackground: UIView!
    
    @IBOutlet var followImg: UIImageView!
    
    //TODO: comment out
    var cellUser: BackendlessUser = BackendlessUser()
    
    // var followId = ""
    
    @IBAction func followAction(_ sender: Any) {
      
        
    }
    
    func  followButtonPressed(sender: Any?) {
        print("Okay")
    }
    
  
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
