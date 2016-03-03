//
//  CompassViewController.swift
//  Anteater
//
//  Created by Ankush Gupta on 3/2/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

import Foundation
import SwiftyJSON

@objc class CompassViewController : UIViewController, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var needle : CompassView!;
    @IBOutlet var picker : UIPickerView!;
    @IBOutlet var headingLabel, distanceLabel : UILabel!
    
    var anthills: JSON = []
    var mgr: CLLocationManager?
    var image: UIImage?
    var gotLoc = false
    var gotHeading = false
    var userLoc, lastLoc, targetLoc: CLLocation?
    var curHeading = 0.0, lastHeading = 0.0
    
//    var _scale, _lastMagHeading: CGFloat?
    
    static func degToRad(x : Double) -> Double {
        return (M_PI * (x) / 180.0)
    }
    
    static func radToDeg(x :Double) -> Double{
        return ((x) * 180.0 / M_PI)
    }

	static func computeDegreesFromLocation(src: CLLocation, toLocation dst: CLLocation) -> Double {
		let lon1 = degToRad(src.coordinate.longitude)
		let lat1 = degToRad(src.coordinate.latitude)
		let lon2 = degToRad(dst.coordinate.longitude)
		let lat2 = degToRad(dst.coordinate.latitude)
        
		let angleRadians = atan2(sin(lon2-lon1)*cos(lat2), cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(lon2-lon1))
        
		return radToDeg(angleRadians)
	}
    
    override func viewDidLoad() {
        mgr = CLLocationManager()
        mgr?.delegate = self
        mgr?.desiredAccuracy = kCLLocationAccuracyBest
        mgr?.distanceFilter = 0
        mgr?.headingOrientation = CLDeviceOrientation.Portrait
        mgr?.startUpdatingHeading()
        mgr?.startUpdatingLocation()
        
        picker?.dataSource = self
        picker?.delegate = self
        
        AnteaterREST.getListOfAnthills { (data) in
            self.anthills = data["anthills"]
            self.picker?.reloadAllComponents()
            self.targetLoc = self.curSelectedLocation()
        }
        
        self.distanceLabel?.text = "Loading..."
        self.headingLabel?.text = ""
        super.viewDidLoad()
    }

    func updateInterface() {
        if (gotLoc && gotHeading) {
            if let target = targetLoc, user = userLoc{
                // both are in degrees
                let thetaOne = CompassViewController.computeDegreesFromLocation(user, toLocation: target)
                let thetaTwo = curHeading
                let heading = thetaOne - thetaTwo
                let distance = user.distanceFromLocation(target)
                
                self.distanceLabel?.text = String(format: "%4fkm", distance/1000)
                self.headingLabel?.text = String(format: "%3f°", heading)
                needle?.transform = CGAffineTransformMakeRotation(CGFloat(CompassViewController.degToRad(heading)))
            }

        }
    }
    
	func curSelectedLocation() -> CLLocation? {
		var d = anthills[picker.selectedRowInComponent(0)]
        if let lat = d["lat"].double, let lon = d["lon"].double {
            return CLLocation(latitude: lat, longitude: lon)
        } else {
            return nil
        }
	}
    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        lastHeading = curHeading
        curHeading = newHeading.trueHeading
        gotHeading = true
        self.updateInterface()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLoc = userLoc
        userLoc = locations.last
        gotLoc = true
        self.updateInterface()
    }

    // MARK: UIPickerView methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return anthills.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let id = anthills[row]["id"].string{
            if let description = anthills[row]["description"].string {
                return "\(id) - \(description)"
            } else {
                return id
            }
        }
        return nil
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        targetLoc = self.curSelectedLocation()
        self.updateInterface()
    }
}