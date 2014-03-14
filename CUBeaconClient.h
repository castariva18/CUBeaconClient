//
//  CUBeaconClient.h
//  IBeacon
//
//  Created by curer on 3/10/14.
//  Copyright (c) 2014 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;
@import CoreLocation;


typedef enum : NSUInteger
{
    CUiBeaconRegion_ENTER,
    CUiBeaconRegion_LEAVE
} CUiBeaconRegionState;

typedef void (^iBeaconRegionChanged)(CUiBeaconRegionState state, CLBeaconRegion *region);
typedef void (^iBeaconLocationChanged)(CLProximity state, CLBeacon *region);

@interface CUBeaconClient : NSObject

+ (instancetype)sharedInstance;

- (void)startMonitoringForStores;

- (void)registeriBeaconWithProximityUUID:(NSUUID *)proximityUUID
                              identifier:(NSString *)identifier
                                   state:(iBeaconRegionChanged)stateChanged
                                location:(iBeaconLocationChanged)locationChanged;

@end
