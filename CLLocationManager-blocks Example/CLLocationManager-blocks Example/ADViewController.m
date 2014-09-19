//
//  ADViewController.m
//  CLLocationManager-blocks Example
//
//  Created by Aksel Dybdal on 04.11.13.
//  Copyright (c) 2013 Aksel Dybdal. All rights reserved.
//

#import "ADViewController.h"
#import "CLLocationManager+blocks.h"

@interface ADViewController ()

@property (nonatomic, strong) CLLocationManager *manager;

@end

@implementation ADViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.manager = [CLLocationManager updateManagerWithAccuracy:50.0 locationAge:15.0 authorizationDesciption:CLLocationUpdateAuthorizationDescriptionAlways];
    
    if ([CLLocationManager isLocationUpdatesAvailable]) {
        [self.manager startUpdatingLocationWithUpdateBlock:^(CLLocationManager *manager, CLLocation *location, NSError *error, BOOL *stopUpdating) {
            NSLog(@"Our new location: %@", location);
            *stopUpdating = YES;
        }];
    }
}

@end
