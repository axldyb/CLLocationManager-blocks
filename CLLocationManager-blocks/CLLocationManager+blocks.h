//
//  CLLocationManager+blocks.h
//  CLLocationManager+blocks
//
//  Created by Aksel Dybdal on 23.10.13.
//  Copyright (c) 2013 Aksel Dybdal. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <objc/runtime.h>

/*
 *  CLUpdateAccuracyFilter
 *
 *  Discussion:
 *    Type used to represent a location accuracy level in meters. The lower the value in meters, the
 *    more physically precise the location is. A negative accuracy value indicates an invalid location.
 */
typedef double CLUpdateAccuracyFilter;

/*
 *  LocationManagerUpdateBlock
 *
 *  Discussion:
 *    Block used to notify about updates to the location manager
 */
typedef void (^LocationManagerUpdateBlock)(CLLocation *location, NSError *error, BOOL stopUpdating);

/*
 *  DidChangeAuthorizationStatusBlock
 *
 *  Discussion:
 *    
 */
typedef void (^DidChangeAuthorizationStatusBlock)(CLLocationManager *manager, CLAuthorizationStatus status);

/*
 *  DidEnterRegionBlock
 *
 *  Discussion:
 *
 */
typedef void (^DidEnterRegionBlock)(CLLocationManager *manager, CLRegion *region);

@interface CLLocationManagerBlocks : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) CLLocationManager *parentManager;

@end


@interface CLLocationManager (blocks)

/*
 *  blocksDelegate
 *
 *  Discussion:
 *      Used internally to enable the location manager blocks to be added as a category
 */
@property (nonatomic, retain, readonly) id blocksDelegate;

/*
 *  updateAccuracyFilter
 *
 *  Discussion:
 *      Specifies the minimum update accuracy when using update block. Client will not be notified of movements of less
 *      than the stated value, unless the accuracy has improved. Pass in kCLUpdateAccuracyFilterNone to be
 *      notified of all movements. By default, kCLUpdateAccuracyFilterNone is used.
 */
@property(assign, nonatomic) CLUpdateAccuracyFilter updateAccuracyFilter;

- (void)startUpdatingLocationWithUpdateBlock:(LocationManagerUpdateBlock)updateBlock;

- (void)setDidChangeAuthorizationStatusWithBlock:(DidChangeAuthorizationStatusBlock)block;

- (void)setDidEnterRegionWithBlock:(DidEnterRegionBlock)block;

- (void)setDidExitRegionWithBlock:(void(^)(CLLocationManager *manager, CLRegion *region))block;

- (void)setMonitoringDidFailForRegionWithBlock:(void(^)(CLLocationManager *manager, CLRegion *region, NSError *error))block;

- (void)setDidStartMonitoringForRegionWithBlock:(void(^)(CLLocationManager *manager, CLRegion *region))block;

- (void)setDidUpdateHeadingWithBlock:(void(^)(CLLocationManager *manager, CLHeading *newHeading))block;

- (void)setLocationManagerShouldDisplayHeadingCalibrationWithBlock:(void(^)(CLLocationManager *manager))block;

@end
