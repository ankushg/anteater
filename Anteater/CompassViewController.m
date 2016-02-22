//
//  CompassViewController.m
//  Anteater
//
//  Created by Sam Madden on 1/29/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

#import "CompassViewController.h"
#import "AnteaterREST.h"

#define DEGREES_TO_RADIANS(degrees) ((degrees / 180.0) * M_PI)
#define RADIANS_TO_DEGREES(radians) (radians * (180.0 / M_PI))

@interface CompassViewController ()

@end

@implementation CompassViewController {
    NSArray *_anthills;
    CLLocationManager *_mgr;
    UIImage *_image;
    BOOL gotLoc, gotHeading;
    CLLocation *_lastLoc, *_userLoc, *_targetLoc;
    CGFloat _curHeading, _lastHeading, _scale, _lastMagHeading;
    // TODO: determine use of _lastLoc, _lastHeading, _scale, and _lastMagHeading
}

- (void)viewDidLoad {
    _mgr = [[CLLocationManager alloc] init];
    _mgr.delegate = self;
    _mgr.desiredAccuracy = kCLLocationAccuracyBest;
    _mgr.distanceFilter = 0;
    _mgr.headingOrientation = CLDeviceOrientationPortrait;
    [_mgr startUpdatingHeading];
    [_mgr startUpdatingLocation];
    _anthills = @[];
    _picker.dataSource = self;
    _picker.delegate = self;
    [AnteaterREST getListOfAnthills:^(NSDictionary *hills) {
        if (hills)
            _anthills = [hills objectForKey:@"anthills"];
        [_picker reloadAllComponents];
        _targetLoc = [self curSelectedLocation];
    }];
    
    self.distanceLabel.text = @"";
    self.headingLabel.text = @"";

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (double) computeDegreesFromLocation:(CLLocation *) src toLocation:(CLLocation *) dst
{
    double lon1 = DEGREES_TO_RADIANS(src.coordinate.longitude);
    double lat1 = DEGREES_TO_RADIANS(src.coordinate.latitude);
    double lon2 = DEGREES_TO_RADIANS(dst.coordinate.longitude);
    double lat2 = DEGREES_TO_RADIANS(dst.coordinate.latitude);
    
    double angleRadians = atan2(sin(lon2-lon1)*cos(lat2), cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(lon2-lon1));
    
    return RADIANS_TO_DEGREES(angleRadians);
}

- (void) updateInterface
{
    if (gotLoc && gotHeading) {
        // both are in degrees
        double thetaOne = [self computeDegreesFromLocation:_userLoc toLocation:_targetLoc];
        double thetaTwo = _curHeading;

        double heading =  thetaOne - thetaTwo;
        double distance = [_userLoc distanceFromLocation:_targetLoc];
        
        self.distanceLabel.text = [NSString stringWithFormat: @"%4fkm", distance/1000];
        self.headingLabel.text = [NSString stringWithFormat:@"%3f%@", heading, @"\u00B0"];
        _needle.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(heading));
    }
}

#pragma mark - CLLocationManagerDelegate Methods -

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    _lastHeading = _curHeading;
    _curHeading = newHeading.trueHeading;
    
    gotHeading = TRUE;
   
    [self updateInterface];
}


-(void)locationManager:(CLLocationManager*)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    _lastLoc = _userLoc;
    _userLoc = [locations lastObject];
    gotLoc = TRUE;

    [self updateInterface];
}


#pragma  mark - Picker View -

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_anthills count];
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component __TVOS_PROHIBITED {
    return [[_anthills objectAtIndex:row] objectForKey:@"id"];
}

-(CLLocation *) curSelectedLocation {
    NSDictionary *d = [_anthills objectAtIndex:[_picker selectedRowInComponent:0]];
    CLLocation *hill = [[CLLocation alloc] initWithLatitude:[[d objectForKey:@"lat"] floatValue] longitude:[[d objectForKey:@"lon"] floatValue]];
    return hill;

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component __TVOS_PROHIBITED
{
    _targetLoc = [self curSelectedLocation];
    
    [self updateInterface];
}


@end
