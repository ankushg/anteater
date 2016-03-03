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
            // TODO: fix this by making AnthillAnnotation take in a JSON
            var dict = [String: AnyObject]()
            hill.forEach({ (key, value) in
                dict[key] = value.object
            })
            let a: AnthillAnnotation = AnthillAnnotation(anthillData: dict)
            
            self.addAnnotation(a)
            if let hid = hill["id"].string {
                annots[hid] = a
            }
        }
    }
    
    func resizeMap() {
        // TODO
        /*
        float maxLat=-500,maxLon=-500,minLat=500,minLon=500;
        
        for (NSDictionary *hill in [_hills allValues]) {
        float lat = [[hill objectForKey:@"lat"] floatValue];
        float lon = [[hill objectForKey:@"lon"] floatValue];
        
        if (lat > maxLat) {
        maxLat =lat;
        }
        if (lat < minLat) {
        minLat = lat;
        }
        if (lon > maxLon) {
        maxLon = lon;
        }
        if (lon < minLon) {
        minLon = lon;
        }
        }
        if (maxLat != -500) { // at least one point
        maxLat += (maxLat - minLat) * .02; minLat -= (maxLat - minLat) * .02;
        maxLon += (maxLon - minLon) * .02; minLon -= (maxLon - minLon) * .02;
        
        MKCoordinateRegion region = self.region;
        region.center = CLLocationCoordinate2DMake(minLat + (maxLat-minLat)/2, minLon + (maxLon-minLon)/2);
        float height = maxLat - minLat;
        float width = maxLon - minLon;
        
        if (height < .01) height = .01;
        if (width < .01) width = .01;
        
        region.span.latitudeDelta = height;
        region.span.longitudeDelta = width;
        
        [self setRegion:region animated:YES];
        }
        */
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