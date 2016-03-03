//
//  AnteaterREST.swift
//  Anteater
//
//  Created by Ankush Gupta on 3/1/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

@objc class AnteaterREST : NSObject {
    static let HTTPStatusOk = 200
    static let HTTPStatusDuplicate = 409
    
    private static let Timeout = 5.0
    
    private static let AnthillsURL = "http://carteldb.csail.mit.edu/rest/get_anthills"
    private static let LeaderboardURL = "http://carteldb.csail.mit.edu/rest/leaderboard"
    private static let SensorReadingsURL = "http://carteldb.csail.mit.edu/rest/post_data"
    private static let RegisterUserURL = "http://carteldb.csail.mit.edu/rest/register_user"
    
    class func getListOfAnthills(callback: ((JSON) -> Void)?) {
        doGetOfURL(AnthillsURL, withCallback: callback)
    }
    
    class func getLeaderboard(callback: ((JSON) -> Void)?) {
        doGetOfURL(LeaderboardURL, withCallback: callback)
    }
    
    class func postListOfSensorReadings(readings: [BLESensorReading]!, andCallCallback callback: ((Int, JSON) -> Void)?) {
//        let readingJson = readings.map({ (reading) -> String in
//            return reading.toJson()
//        }).joinWithSeparator(",\n")
//        
//        let data = "{\"readings\":[\n\(readingJson)\n]}"
        
        let readingList = readings.map { (reading) -> [NSObject : AnyObject] in
            return reading.toDict()
        }
        let d = ["readings": readingList]
        
        doPostOfObject(d, toUrl: SensorReadingsURL, withCallback: callback)
    }
    
    class func registerUser(userid: String, withDeviceId deviceid: String, andCallback callback: ((Int, JSON) -> Void)?) {
        let d = ["user_info": ["name": userid, "deviceid": deviceid]]
        doPostOfObject(d, toUrl: RegisterUserURL, withCallback: callback)

//        let data = "{\"user_info\":{\"name\":\"\(userid)\",\"deviceid\":\"\(deviceid)\"}}"

    }
    
    private class func doPostOfObject(object: [String : AnyObject]?, toUrl: String, withCallback callback: ((Int, JSON) -> Void)?){
        Alamofire.Manager.sharedInstance.session.configuration.timeoutIntervalForRequest = Timeout
        
        Alamofire.request(.POST, toUrl, parameters: object, encoding: .JSON)
            .validate(statusCode: [HTTPStatusOk, HTTPStatusDuplicate])
            .responseJSON { (response) in
                switch response.result {
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    callback?(error.code, JSON([]))
                case .Success(let json):
                    print("Async json: \(json.description)")
                    callback?(json.statusCode, JSON(json))
                }
        }
    }
    
    private class func doGetOfURL(url: String, withCallback callback: ((JSON) -> Void)?) {
        Alamofire.Manager.sharedInstance.session.configuration.timeoutIntervalForRequest = Timeout
        Alamofire.request(.GET, url)
            .responseJSON { (response) in
            switch response.result {
            case .Success(let json):
                print("Async json: \(json.description)")
                callback?(JSON(json))
            case .Failure(let error):
                print("Request failed with error: \(error)")
                callback?(JSON([]))
            }
        }
    }
}