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
    var delegate : LoginViewDelegate!
    @IBOutlet var okButton : UIButton!
    @IBOutlet var userName : UITextField!
    
    override func viewDidAppear(animated: Bool) {
        okButton?.layer.cornerRadius = 5.0;
        okButton?.backgroundColor = UIColor.blueColor()
        userName?.delegate = self;
    }
    
    @IBAction func hitOK(sender : UIButton) {
        if let user = userName.text, uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString {

            
            if user.characters.count >= 3 {
                AnteaterREST.registerUser(user, withDeviceId: uuid, andCallback: { (statusCode, result) in
                    if statusCode == AnteaterREST.HTTPStatusOk {
                        SettingsModel.instance.username = user
                        self.dismissViewControllerAnimated(true, completion: nil)
                        self.delegate?.loginComplete()
                    } else {
                        let title = "Request Failed"
                        let message = "Network request failed with error \(statusCode), please try again"
                        self.showAlert(title, message: message)
                    }
                })
            } else {
                let title = "Invalid username"
                let message = "Please enter a username that is at least 3 characters."
                self.showAlert(title, message: message)
            }
        } else {
            let title = "Error"
            let message = "Error reading username or device id"
            self.showAlert(title, message: message)
        }
    }
    
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler:nil)
        
        alert.addAction(defaultAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}