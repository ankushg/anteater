//
//  LeaderboardCell.swift
//  Anteater
//
//  Created by Ankush Gupta on 3/1/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

import Foundation
import UIKit

class LeaderboardCell : UITableViewCell {
    
    @IBOutlet var rankField: UILabel!
    @IBOutlet var nameField: UILabel!
    @IBOutlet var pointsField: UILabel!
    
    override func awakeFromNib() {
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        // Configure the view for the selected state

        super.setSelected(selected, animated: animated)
    }
    
}

