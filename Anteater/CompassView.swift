//
//  CompassView.swift
//  Anteater
//
//  Created by Ankush Gupta on 3/1/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

import Foundation

import UIKit
import CoreLocation

class CompassView : UIImageView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
        self.layer.anchorPoint = CGPointMake(0.5, 0.5)
    }
}

