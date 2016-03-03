//
//  AnthillAnnotation.swift
//  Anteater
//
//  Created by Ankush Gupta on 3/2/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

import Foundation
import MapKit

import SwiftyJSON

class AnthillAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(data["lat"].doubleValue, data["lon"].doubleValue)
        }
    }
    
    var title: String? {
        get {
            let id = data["id"].stringValue
            if let description = data["description"].string {
                return "\(id) - \(description)"
            } else {
                return id
            }
        }
    }
    
    var subtitle: String? {
        get {            
            if !data["last_heard"].isExists() {
                return "No connections (5 points)"
            }
            
            let d: NSDate = NSDate(timeIntervalSince1970: data["last_heard"].doubleValue)
            
            return "Last heard:\(NSDateFormatter.localizedStringFromDate(d, dateStyle: .ShortStyle, timeStyle: .ShortStyle)). (\(getPointsForVisitingAnthill(d)) points)"
        }
    }
    
    var data : JSON = [:]
    
    init(anthillData: JSON) {
        data = anthillData
        super.init()
    }
    
    func colorForAnthill() -> UIColor {
        if !data["last_heard"].isExists() {
            return UIColor.redColor()
        }
        
        let d: NSDate = NSDate(timeIntervalSince1970: data["last_heard"].doubleValue)
        
        if d.timeIntervalSinceNow * -1 > 30 * 60 { //30 minutes
            return UIColor.yellowColor()
        } else {
            return UIColor.greenColor()
            
        }
    }
    
    func getPointsForVisitingAnthill(date: NSDate) -> Int{
        let diff = date.timeIntervalSinceNow * -1
        
        if diff > 360 * 30 {
            return 5
        } else if diff > 360 * 10 {
            return 2
        } else if diff > 360 * 5 {
            return 1
        } else {
            return 0
        }
    }
}