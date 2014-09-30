#CLLocationManager-blocks
A category on CLLocationManager adding blocks plus some new functionality. 

__NOTE:__ Supporting iOS 8 from version 1.3.0.

## Installation
CLLocationManager-block is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

```
pod 'CLLocationManager-blocks'
```

##Usage
This category provides location updates in two ways.

* Custom update blocks for location and heading
* Block implementation of the CLLocationManagerDelegate methods

##Block for recieving updates
Recieving location updates in a block.

```objective-c
self.manager = [CLLocationManager updateManagerWithAccuracy:50.0 locationAge:15.0 authorizationDesciption:CLLocationUpdateAuthorizationDescriptionAlways];
[self.manager startUpdatingLocationWithUpdateBlock:^(CLLocationManager *manager, CLLocation *location, NSError *error, BOOL *stopUpdating) {
    NSLog(@"Our new location: %@", location);
}]; 
```
__NOTE:__ Location updates will start automatically by calling this method. No need to call startUpdatingLocation.

By using this block you will get the location updates without using the delegate methods. The underlying method `locationManager:didUpdateLocations:`does provide updates in an array, but we spilt them up into single updates in the block.

If the update is unsuccessful an error will be provided and `location` will be `nil`. If success the `error` will be `nil` and location will be an CLLocation object.

You can set the `stopUpdating` boolean to `YES` stop location updates at any successful or unsuccessful update. 

```objective-c
*stopUpdating = YES; 
```

A similar method exist for recieving heading updates:

```objective-c
[self.manager startUpdatingHeadingWithUpdateBlock:^(CLLocationManager *manager, CLHeading *heading, NSError *error, BOOL *stopUpdating) {
    NSLog(@"Our new heading: %@", heading);
    *stopUpdating = YES;
}];
```

##Authorization Description

New to iOS 8 is the need for the key `NSLocationAlwaysUsageDescription` to be set in the info.plist. Make sure you add this. 

##Filters

In addition to the blocks two new filters is included. Normally when you are listening for location updates you will recieve location updates with undesired age og accuracy. One would then have to write code to avoid the usage of these updates. Thanks to the new filters we just have to specify the an age and/or accuracy to get a location update we can work with.

####updateAccuracyFilter

The standard `[CLLocationManager desiredAccuracy]` provided in Core Location cannot garantie that specific accuracy requrements are meet. By setting this parameter all updates with a higher inaccuracy than specified are excluded.

* Unless you are running updates for a long period, set the `[CLLocationManager desiredAccuracy]` to `kCLLocationAccuracyBest` and your desired `updateAccuracyFilter` specified in meters. 
* `updateAccuracyFilter` is used for all blocks. 
* Default is set to `kCLUpdateAccuracyFilterNone`.

####updateLocationAgeFilter
This parameter is set to filter out location updates older than the specified value in seconds. CLLocationManager location updates may provide old updates for different reasons and this is a good way to get a fresh update.

* Default is set to `kCLLocationAgeFilterNone`

####Example
```objective-c
self.manager.updateAccuracyFilter = 50.0;
self.manager.updateLocationAgeFilter = 15.0;
//or
self.manager.updateAccuracyFilter = kCLUpdateAccuracyFilterNone;
self.manager.updateLocationAgeFilter = kCLLocationAgeFilterNone;
```
##Blocks

The category contains block implementations of all CLLocationManagerDelegate methods. These blocks can be used together with CLLocationManager just as you normally would have used the delegate. 

__NOTE:__ Unlike the startUpdatingLocationWithUpdateBlock: you will have to call startUpdatingLocation to recieve updates.

####Example

***locationManager:didUpdateLocations:***

```objective-c
self.manager = [CLLocationManager updateManager];
[self.manager didUpdateLocationsWithBlock:^(CLLocationManager *manager, NSArray *locations) {
	// Did update locations
}];
[self.manager startUpdatingLocation];
```

##Convenience methods
Method to ease the steps to state if location updates is authorized by the user.

***isLocationUpdatesAvailable***

```objective-c
if ([CLLocationManager isLocationUpdatesAvailable]) {
	// Location updates authorized
}
```

##License

See the LICENSE file

© 2013 Aksel Dybdal
