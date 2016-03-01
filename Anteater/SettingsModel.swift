//
//  SettingsModel.swift
//  Anteater
//
//  Created by Ankush Gupta on 3/1/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

import Foundation

@objc class SettingsModel : NSObject {
    static let instance = SettingsModel()
    static let kUsernameKey = "username"
    static let kLastConnectedKey = "lastConnected"
    
    var username : String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(SettingsModel.kUsernameKey)
        }
        set(newName) {
            NSUserDefaults.standardUserDefaults().setValue(newName, forKey: SettingsModel.kUsernameKey)
        }
    }
    
    var lastConnectedTimes : Dictionary<String, AnyObject>? {
        get {
            return NSUserDefaults.standardUserDefaults().dictionaryForKey(SettingsModel.kLastConnectedKey)
        }
        set(newLastConnectedTimes) {
            NSUserDefaults.standardUserDefaults().setObject(newLastConnectedTimes, forKey: SettingsModel.kLastConnectedKey)
        }
    }
    
    
}