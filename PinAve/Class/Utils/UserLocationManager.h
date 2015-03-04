//
//  UserLocationManager.h
//  Mosurv
//
//  Created by Dandong3 Sam on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString *kLocationUpdateManagerNotificationName;
extern NSString *kLocationUpdateManagerUserInfoKey;

@interface UserLocationManager : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLLocation *latestLocation;

+ (UserLocationManager *)sharedInstance;

- (NSString*) getCustomUserLocationAddress;
- (NSString*) getStandardUserLocationAddress;


@end
