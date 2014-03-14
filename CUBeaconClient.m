//
//  CUBeaconClient.m
//  IBeacon
//
//  Created by curer on 3/10/14.
//  Copyright (c) 2014 Baidu. All rights reserved.
//

#import "CUBeaconClient.h"

@interface CUBeaconClient ()<CLLocationManagerDelegate>


@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSUUID *uuid;

@property (nonatomic, assign) CLProximity oldProximity;
@property (nonatomic, strong) CLBeaconRegion *beaconRegin;
@property (nonatomic, strong) iBeaconRegionChanged regionChangedcallback;
@property (nonatomic, strong) iBeaconLocationChanged locationChangedcallback;

@property (nonatomic, strong) NSString *identify;

@end

@implementation CUBeaconClient

+ (instancetype)sharedInstance {
    static CUBeaconClient *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [CUBeaconClient new];
        [_sharedInstance setup];
    });
    
    return _sharedInstance;
}

- (void)setup
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
}

- (void)registeriBeaconWithProximityUUID:(NSUUID *)proximityUUID
                              identifier:(NSString *)identifier
                                   state:(iBeaconRegionChanged)stateChanged
                                location:(iBeaconLocationChanged)locationChanged
{
    self.uuid = proximityUUID;
    self.identify = identifier;
    
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:self.uuid identifier:identifier];
    
    region.notifyEntryStateOnDisplay = YES;
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    
    self.beaconRegin = region;
    
    self.regionChangedcallback = stateChanged;
    self.locationChangedcallback = locationChanged;
    
    [self.locationManager startMonitoringForRegion:region];
}

- (void)startMonitoringForStores
{
    if ([CLLocationManager isRangingAvailable]) {
        [self.locationManager startMonitoringForRegion:self.beaconRegin];
    }
}

#pragma mark - delegate

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.locationManager requestStateForRegion:self.beaconRegin];
}

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (state == CLRegionStateInside)
    {
        //Start Ranging
        [manager startRangingBeaconsInRegion:self.beaconRegin];
    }
    else
    {
        //Stop Ranging here
        [manager stopRangingBeaconsInRegion:self.beaconRegin];
    }
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    if (![region.identifier isEqualToString:self.beaconRegin.identifier])
    {
        // present notification to user
        return;
    }
    
    self.regionChangedcallback(CUiBeaconRegion_ENTER, self.beaconRegin);
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    if (![self.beaconRegin.identifier isEqualToString:region.identifier]) {
        return;
    }
    
    self.regionChangedcallback(CUiBeaconRegion_LEAVE, self.beaconRegin);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
    if (beacons.count == 0) {
        return;
    }
    
    //Check if we have moved closer or farther away from the iBeacon…
    CLBeacon *beacon = [beacons objectAtIndex:0];
  
    if ([beacon.major intValue] != [self.beaconRegin.major intValue] || [beacon.minor intValue] != [self.beaconRegin.minor intValue]) {
        [self.locationManager stopMonitoringForRegion:self.beaconRegin];
        
        self.beaconRegin = [[CLBeaconRegion alloc] initWithProximityUUID:beacon.proximityUUID
                                                                   major:[beacon.major intValue]
                                                                   minor:[beacon.minor intValue]
                                                              identifier:self.identify];
        region.notifyEntryStateOnDisplay = YES;
        region.notifyOnEntry = YES;
        region.notifyOnExit = YES;
        
        [self.locationManager startMonitoringForRegion:self.beaconRegin];
    }
    
    if (self.oldProximity != beacon.proximity) {
        self.locationChangedcallback(beacon.proximity, beacon);
        self.oldProximity = beacon.proximity;
    }
}

@end
