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

CLUpdateAccuracyFilter const kCLUpdateAccuracyFilterNone = 0.0;
CLLocationAgeFilter const kCLLocationAgeFilterNone = 0.0;

@interface CLLocationManagerBlocks ()

@property (nonatomic, assign) CLUpdateAccuracyFilter updateAccuracyFilter;
@property (nonatomic, assign) CLLocationAgeFilter updateLocationAgeFilter;

@property (nonatomic, copy) DidUpdateLocationsBlock didUpdateLocationsBlock;
@property (nonatomic, copy) LocationManagerUpdateBlock updateBlock;
@property (nonatomic, copy) DidChangeAuthorizationStatusBlock didChangeAuthorizationStatusBlock;
@property (nonatomic, copy) DidEnterRegionBlock didEnterRegionBlock;
@property (nonatomic, copy) DidExitRegionBlock didExitRegionBlock;
@property (nonatomic, copy) MonitoringDidFailForRegionWithBlock monitoringDidFailForRegionWithBlock;
@property (nonatomic, copy) DidStartMonitoringForRegionWithBlock didStartMonitoringForRegionWithBlock;

@end

@implementation CLLocationManagerBlocks


#pragma mark - Getters

- (CLUpdateAccuracyFilter)updateAccuracyFilter
{
    if (!_updateAccuracyFilter) {
        _updateAccuracyFilter = kCLUpdateAccuracyFilterNone;
    }
    
    return _updateAccuracyFilter;
}

- (CLLocationAgeFilter)updateLocationAgeFilter
{
    if (!_updateLocationAgeFilter) {
        _updateLocationAgeFilter = kCLLocationAgeFilterNone;
    }
    
    return _updateLocationAgeFilter;
}


#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // Pre iOS 6 is using this method for updates. Passing the update on to the new method.
    [self locationManager:manager didUpdateLocations:@[newLocation]];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSMutableArray *filteredLocationsMutable = [NSMutableArray array];
    for ( CLLocation *loc in locations ) {
        
        // Location accuracy filtering
        if (self.updateAccuracyFilter != kCLUpdateAccuracyFilterNone) {
            if (loc.horizontalAccuracy > self.updateAccuracyFilter) {
                continue;
            }
        }
        
        // Location age filtering
        NSDate *eventDate = loc.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        if (abs(howRecent) > self.updateLocationAgeFilter) {
            continue;
        }
        
        [filteredLocationsMutable addObject:loc];
        
        LocationManagerUpdateBlock updateBlock = self.updateBlock;
        if (updateBlock) {
            __block BOOL stopUpdates = NO;
            updateBlock(manager, loc, nil, &stopUpdates);
            
            if (stopUpdates) {
                [manager stopUpdatingLocation];
                self.updateBlock = nil;
                break;
            }
        }
    }
    
    
    if ([filteredLocationsMutable count]) {
        DidUpdateLocationsBlock didUpdateLocationsBlock = self.didUpdateLocationsBlock;
        if (didUpdateLocationsBlock) {
            NSArray *filteredLocations = [NSArray arrayWithArray:filteredLocationsMutable];
            didUpdateLocationsBlock(manager, filteredLocations);
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    LocationManagerUpdateBlock updateBlock = self.updateBlock;
    
    if (updateBlock) {
        __block BOOL stopUpdates = NO;
        updateBlock(manager, nil, error, &stopUpdates);
        
        if (stopUpdates) {
            [manager stopUpdatingLocation];
            self.updateBlock = nil;
        }
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
	DidExitRegionBlock didExitRegionBlock = self.didExitRegionBlock;
    if (didExitRegionBlock) {
        didExitRegionBlock(manager, region);
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
	MonitoringDidFailForRegionWithBlock monitoringDidFailForRegionWithBlock = self.monitoringDidFailForRegionWithBlock;
    if (monitoringDidFailForRegionWithBlock) {
        monitoringDidFailForRegionWithBlock(manager, region, error);
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
	DidStartMonitoringForRegionWithBlock didStartMonitoringForRegionWithBlock = self.didStartMonitoringForRegionWithBlock;
    if (didStartMonitoringForRegionWithBlock) {
        didStartMonitoringForRegionWithBlock(manager, region);
    }
}


// TODO: (AD) Implement these methods if required.

/*
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
*/

@end


@implementation CLLocationManager (blocks)

#pragma mark - Location Manager Blocks

- (void)didUpdateLocationsWithBlock:(DidUpdateLocationsBlock)block
{
    [self setBlocksDelegateIfNotSet];
    [(CLLocationManagerBlocks *)self.blocksDelegate setDidUpdateLocationsBlock:block];
}

- (void)didChangeAuthorizationStatusWithBlock:(DidChangeAuthorizationStatusBlock)block
{
    [self setBlocksDelegateIfNotSet];
    [(CLLocationManagerBlocks *)self.blocksDelegate setDidChangeAuthorizationStatusBlock:block];
}

- (void)didEnterRegionWithBlock:(DidEnterRegionBlock)block
{
    [self setBlocksDelegateIfNotSet];
    [(CLLocationManagerBlocks *)self.blocksDelegate setDidEnterRegionBlock:block];
}

- (void)didExitRegionWithBlock:(DidExitRegionBlock)block
{
    [self setBlocksDelegateIfNotSet];
    [(CLLocationManagerBlocks *)self.blocksDelegate setDidExitRegionBlock:block];
}

- (void)monitoringDidFailForRegionWithBlock:(MonitoringDidFailForRegionWithBlock)block
{
    [self setBlocksDelegateIfNotSet];
    [(CLLocationManagerBlocks *)self.blocksDelegate setMonitoringDidFailForRegionWithBlock:block];
}

- (void)didStartMonitoringForRegionWithBlock:(DidStartMonitoringForRegionWithBlock)block
{
    [self setBlocksDelegateIfNotSet];
    [(CLLocationManagerBlocks *)self.blocksDelegate setDidStartMonitoringForRegionWithBlock:block];
}

- (void)startUpdatingLocationWithUpdateBlock:(LocationManagerUpdateBlock)updateBlock
{
    [self setBlocksDelegateIfNotSet];
    [(CLLocationManagerBlocks *)self.blocksDelegate setUpdateBlock:updateBlock];
    
    [self startUpdatingLocation];
}


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
    [self setBlocksDelegateIfNotSet];
    [(CLLocationManagerBlocks *)self.blocksDelegate setUpdateAccuracyFilter:updateAccuracyFilter];
}

- (CLLocationAgeFilter)updateLocationAgeFilter
{
    return [(CLLocationManagerBlocks *)self.blocksDelegate updateLocationAgeFilter];
}

- (void)setUpdateLocationAgeFilter:(CLLocationAgeFilter)updateLocationAgeFilter
{
    [self setBlocksDelegateIfNotSet];
    [(CLLocationManagerBlocks *)self.blocksDelegate setUpdateLocationAgeFilter:updateLocationAgeFilter];
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
