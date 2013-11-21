#CLLocationManager-blocks
A category on CLLocationManager adding blocks plus some new functionality.

## Installation
CLLocationManager-block is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

```
pod "CLLocationManager-block"
```

##Usage
This category provides location updates in two ways.

* Custom update block
* Block implementation of the basic CLLocationManagerDelegate methods

##Custom block for recieving updates
Recieving location updates in a block.

```objective-c
self.manager = [[CLLocationManager alloc] init]; 
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

##Additional parameters

In addition to the blocks two new parameters are added

####updateAccuracyFilter

The standard `[CLLocationManager desiredAccuracy]` cannot garantie that the provided accuracy requrements are meet. By setting this parameter all updates with a higher inaccuracy than specified are excluded.

* Unless you are running updates for a long period, set the `[CLLocationManager desiredAccuracy]` to `kCLLocationAccuracyBest` and your desired `updateAccuracyFilter` specified in meters. 
* `updateAccuracyFilter` is used for all blocks. 
* Default is set to `kCLUpdateAccuracyFilterNone`.

####updateLocationAgeFilter
This parameter is set to filter out location updates older than the specified value in seconds. CLLocationManager location updates may provide old updates for different reasons and this is a good way to get a fresh plot.

* Default is set to `kCLLocationAgeFilterNone`

##Blocks

The category contains block implementations of the basic CLLocationManagerDelegate methods

__NOTE:__ Unlike the startUpdatingLocationWithUpdateBlock: you will have to call startUpdatingLocation to recieve updates.

***locationManager:didUpdateLocations:***

```objective-c
[self.manager didUpdateLocationsWithBlock:^(CLLocationManager *manager, NSArray *locations) {
	// Did update locations
}];
```

***locationManager:didChangeAuthorizationStatus:***

```objective-c
[self.manager didChangeAuthorizationStatusWithBlock:^(CLLocationManager *manager, CLAuthorizationStatus status) { 
	// Did change authorization status       
}];
```

***locationManager:didEnterRegion:***

```objective-c
[self.manager didEnterRegionWithBlock:^(CLLocationManager *manager, CLRegion *region) {
	// Did enter region
}]
```

***locationManager:didExitRegion:***

```objective-c
[self.manager didExitRegionWithBlock:^(CLLocationManager *manager, CLRegion *region) {
	// Did exit region       
}]
```

***locationManager:monitoringDidFailForRegion:***

```objective-c
[self.manager monitoringDidFailForRegionWithBlock:^(CLLocationManager *manager, CLRegion *region, NSError *error) {
	// Monitoring did fail for region        
}]
```

***locationManager:didStartMonitoringForRegion:***

```objective-c
[self.manager didStartMonitoringForRegionWithBlock:^(CLLocationManager *manager, CLRegion *region) {
	// Did start monitoring for region        
}]
```

##License

See the LICENSE file

© 2013 Aksel Dybdal
