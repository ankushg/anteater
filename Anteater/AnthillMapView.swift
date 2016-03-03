//
//  AnthillMapView.swift
//  Anteater
//
//  Created by Ankush Gupta on 3/2/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

import Foundation
import MapKit
import SwiftyJSON

@objc class AnthillMapView : MKMapView, MKMapViewDelegate {
    @IBOutlet var cv : CompassView?
    
    var annots : [String : MKAnnotation?] = [:]
    var hills : JSON = [:]
    var oldHills : JSON = [:]

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.doInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.doInit()
    }
    
    func doInit() {
        self.zoomEnabled = true
        self.delegate = self
        self.showsUserLocation = true

        self.refreshAnthills()
        
        self.showsCompass = true
        self.showsScale = true
        self.userTrackingMode = MKUserTrackingMode.FollowWithHeading
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(refreshAnthills), userInfo: nil, repeats: true)
    }
    
    func refreshAnthills() {
        AnteaterREST.getListOfAnthills { (data) -> Void in
            self.oldHills = self.hills
            self.hills = data["anthills"]
            self.updateMapView()
            if (self.oldHills.count != self.hills.count) { // we got new anthills
                // self.resizeMap()
            }
        }
    }
    
    func updateMapView() {
        var toRemove = Set(annots.keys)
        var toAdd : [JSON] = []
        
        for (_, newHill) : (String, JSON) in hills {
            let hid = newHill["id"].stringValue
            let oldHill  = oldHills[hid]
            
            if oldHill == newHill {
                toRemove.remove(hid)
            } else {
                toAdd.append(newHill)
            }
        }

        let dummy: AnthillAnnotation = AnthillAnnotation(anthillData: nil)
        let annotsToRemove = toRemove.map({annots[$0]}).flatMap({$0 ?? dummy})
        
        toRemove.forEach { (key) in
            annots.removeValueForKey(key)
        }
        self.removeAnnotations(annotsToRemove)

        for hill in toAdd {
            let a: AnthillAnnotation = AnthillAnnotation(anthillData: hill)
            
            self.addAnnotation(a)
            if let hid = hill["id"].string {
                annots[hid] = a
            }
        }
    }
    
    func resizeMap() {
        let lats : [Double] = hills.flatMap { (_, hill) -> Double? in
            return hill["lat"].double
        }
        
        let lons : [Double] = hills.flatMap { (_, hill) -> Double? in
            return hill["lat"].double
        }
        
        var minLat = lats.minElement() ?? 500
        var maxLat = lats.maxElement() ?? -500
        var minLon = lons.minElement() ?? 500
        var maxLon = lons.maxElement() ?? -500
        
        if hills.count > 0 {
            maxLat += (maxLat - minLat) * 0.02; minLat -= (maxLat - minLat) * 0.02
            maxLon += (maxLon - minLon) * 0.02; minLon -= (maxLon - minLon) * 0.02
 
            var r = self.region
            r.center = CLLocationCoordinate2DMake(minLat + (maxLat-minLat)/2, minLon + (maxLon-minLon)/2)
            let height = max(maxLat - minLat, 0.01)
            let width = max(maxLon - minLon, 0.01)
            r.span.latitudeDelta = height
            r.span.longitudeDelta = width
            self.setRegion(r, animated: true)
        }
    }
    
    //MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let a = annotation as? AnthillAnnotation {
            let pin: MKPinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pin.pinTintColor = a.colorForAnthill()
            pin.canShowCallout = true
            return pin
        }

        return nil
    }
    
//    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        cv.rotationOffset = mapView.camera.heading
//    }
    
}