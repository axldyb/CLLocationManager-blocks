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
    
	self.manager = [[CLLocationManager alloc] init];
    
    [self.manager setDidChangeAuthorizationStatusWithBlock:^(CLLocationManager *manager, CLAuthorizationStatus status) {
        NSLog(@"Status: %i", status);
    }];
    
    [self.manager startUpdatingLocationWithUpdateBlock:^(CLLocation *location, NSError *error, BOOL stopUpdating) {
        NSLog(@"Update: %@", location);
    }];
}

@end
