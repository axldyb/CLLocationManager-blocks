//
//  CLLocationManager+blocks.m
//  CLLocationManager+blocks
//
//  Created by Aksel Dybdal on 23.10.13.
//  Copyright (c) 2013 Aksel Dybdal. All rights reserved.
//

#import "CLLocationManager+blocks.h"

static const void *CLLocationManagerBlocksDelegateKey = &CLLocationManagerBlocksDelegateKey;
static const void *CLLocationManagerUpdateKey = &CLLocationManagerUpdateKey;
static const void *CLLocationManagerUpdateAccuracyKey = &CLLocationManagerUpdateAccuracyKey;

@interface CLLocationManagerBlocks ()

@property (nonatomic, assign) CLUpdateAccuracyFilter updateAccuracyFilter;

@property (nonatomic, copy) LocationManagerUpdateBlock updateBlock;
@property (nonatomic, copy) DidChangeAuthorizationStatusBlock didChangeAuthorizationStatusBlock;
@property (nonatomic, copy) DidEnterRegionBlock didEnterRegionBlock;

@end

@implementation CLLocationManagerBlocks

#pragma mark - Blocks Implementation

- (void)startUpdatingLocationWithUpdateBlock:(LocationManagerUpdateBlock)updateBlock
{
    self.updateBlock = updateBlock;
}

- (void)setDidChangeAuthorizationStatusWithBlock:(DidChangeAuthorizationStatusBlock)block
{
    self.didChangeAuthorizationStatusBlock = block;
}

- (void)setDidEnterRegionWithBlock:(DidEnterRegionBlock)block
{
    self.didEnterRegionBlock = block;
}


#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // Pre iOS 6 is using this method for updates. Passing the update on to the new method.
    [self locationManager:manager didUpdateLocations:@[newLocation]];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for ( CLLocation *loc in locations ) {
        
        // TODO (AD): Do filtering
        
        LocationManagerUpdateBlock updateBlock = self.updateBlock;
        if (updateBlock) {
            
            BOOL stopUpdates = NO;
            
            updateBlock(loc, nil, stopUpdates);
            
            if (stopUpdates) {
                [manager stopUpdatingLocation];
                self.updateBlock = nil;
                break;
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    LocationManagerUpdateBlock updateBlock = self.updateBlock;
    
    if (updateBlock) {
        updateBlock(nil, error, NO);
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    DidChangeAuthorizationStatusBlock didChangeAuthorizationStatusBlock = self.didChangeAuthorizationStatusBlock;
    
	if (didChangeAuthorizationStatusBlock) {
        didChangeAuthorizationStatusBlock(manager, status);
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
	DidEnterRegionBlock didEnterRegionBlock = self.didEnterRegionBlock;
    
    if (didEnterRegionBlock) {
        didEnterRegionBlock(manager, region);
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
	
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
	
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
	
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
	
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return NO;
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
{
    
}

@end


@implementation CLLocationManager (blocks)

#pragma mark - Location Manager Blocks

- (void)startUpdatingLocationWithUpdateBlock:(LocationManagerUpdateBlock)updateBlock
{
    [self setBlocksDelegateIfNotSet];
    [self.blocksDelegate startUpdatingLocationWithUpdateBlock:updateBlock];
    
    [self startUpdatingLocation];
}

- (void)setDidChangeAuthorizationStatusWithBlock:(DidChangeAuthorizationStatusBlock)block
{
    [self setBlocksDelegateIfNotSet];
    [self.blocksDelegate setDidChangeAuthorizationStatusWithBlock:block];
}

- (void)setDidEnterRegionWithBlock:(DidEnterRegionBlock)block
{
    [self setBlocksDelegateIfNotSet];
    [self.blocksDelegate setDidEnterRegionWithBlock:block];
}

//- (void)setDidExitRegionWithBlock:(void(^)(CLLocationManager *manager, CLRegion *region))block;
//
//- (void)setMonitoringDidFailForRegionWithBlock:(void(^)(CLLocationManager *manager, CLRegion *region, NSError *error))block;
//
//- (void)setDidStartMonitoringForRegionWithBlock:(void(^)(CLLocationManager *manager, CLRegion *region))block;
//
//- (void)setDidUpdateHeadingWithBlock:(void(^)(CLLocationManager *manager, CLHeading *newHeading))block;
//
//- (void)setLocationManagerShouldDisplayHeadingCalibrationWithBlock:(void(^)(CLLocationManager *manager))block;


#pragma mark - Setters / Getters

- (id)blocksDelegate
{
    return objc_getAssociatedObject(self, CLLocationManagerBlocksDelegateKey);
}

- (void)setBlocksDelegate:(id)blocksDelegate
{
    objc_setAssociatedObject(self, CLLocationManagerBlocksDelegateKey, blocksDelegate, OBJC_ASSOCIATION_RETAIN);
}

- (CLUpdateAccuracyFilter)updateAccuracyFilter
{
    return [(CLLocationManagerBlocks *)self.blocksDelegate updateAccuracyFilter];
}

- (void)setUpdateAccuracyFilter:(CLUpdateAccuracyFilter)updateAccuracyFilter
{
    [(CLLocationManagerBlocks *)self.blocksDelegate setUpdateAccuracyFilter:updateAccuracyFilter];
}


#pragma mark - Class Delegate

- (void)setBlocksDelegateIfNotSet
{    
    if (!self.blocksDelegate) {
        self.blocksDelegate = [[CLLocationManagerBlocks alloc] init];
        [self setDelegate:self.blocksDelegate];
    }
}


@end
