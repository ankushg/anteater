//
//  LoginViewcontroller.swift
//  Anteater
//
//  Created by Ankush Gupta on 3/2/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

import Foundation

@objc protocol LoginViewDelegate {
    func loginComplete()
}

@objc class LoginViewController : UIViewController, UITextFieldDelegate {
    var delegate : LoginViewDelegate?
    @IBOutlet var okButton : UIButton?
    @IBOutlet var userName : UITextField?
    
    override func viewDidAppear(animated: Bool) {
        okButton?.layer.cornerRadius = 5.0;
        okButton?.backgroundColor = UIColor.blueColor()
        userName?.delegate = self;
    }
    
    @IBAction func hitOK(sender : UIButton) {
        if userName?.text?.characters.count >= 3 {
            AnteaterREST.registerUser(userName?.text, withDeviceId: UIDevice.currentDevice().identifierForVendor?.UUIDString, andCallback: { (statusCode, result) in
                if statusCode == HTTP_STATUS_OK {
                    SettingsModel.instance.username = self.userName?.text
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.delegate?.loginComplete()
                } else {
                    let alert = UIAlertController(title: "Request Failed", message: "Network request failed with error \(statusCode), please try again", preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler:nil)
                    
                    alert.addAction(defaultAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        } else {
            let alert = UIAlertController(title: "Invalid username", message:"Please enter a username that is at least 3 characters.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler:nil)
            
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}