//
//  UserLocationManager.m
//  Mosurv
//
//  Created by Dandong3 Sam on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserLocationManager.h"
#import "SBJsonParser.h"
#import "GeoLocation.h"


NSString *kLocationUpdateManagerNotificationName = @"LocationUpdateManagerNotification";
NSString *kLocationUpdateManagerUserInfoKey = @"LocationUpdateManagerUserInfo";

static NSString *kUserLatitude  = @"userLatitudeKey";
static NSString *kUserLongitude = @"userLongitudeKey";

static UserLocationManager *singletonInstance = nil;

#define FEQUAL(a,b)     (fabs((a) - (b)) < FLT_EPSILON)
#define FEQUALZERO(a)   (fabs(a) < FLT_EPSILON)


@implementation UserLocationManager

@synthesize locManager, currentLocation, latestLocation;

+ (UserLocationManager *)sharedInstance
{
    /*@synchronized(self)*/ {
        if (singletonInstance == nil) {
            singletonInstance = [[self alloc] init];
        }
    }
    
    return singletonInstance;
}

- (id)init
{
    if ((self = [super init])) {
        NSLog(@"isMain : %d", [NSThread isMainThread]);
        NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
        CLLocationDegrees latitude = [[userStore objectForKey:kUserLatitude] doubleValue];
        CLLocationDegrees longitude = [[userStore objectForKey:kUserLongitude] doubleValue];
        self.currentLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        self.latestLocation  = nil; //[[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        
        
        self.locManager = [[CLLocationManager alloc] init];
        [self.locManager setDelegate:self];
        
//        [self.locManager startUpdatingLocation];

//        [self.locManager performSelectorOnMainThread:@selector(startUpdatingLocation) withObject:nil waitUntilDone:YES];
        
        self.locManager.desiredAccuracy = kCLLocationAccuracyBest;       

        [self.locManager startUpdatingLocation];        
        
    }
    
    return self;
}

- (void) postLocationUpdateNotification
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.currentLocation, kLocationUpdateManagerUserInfoKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationUpdateManagerNotificationName object:nil userInfo:userInfo];
}

#pragma mark - CLLocationManagerDelegate Methods
BOOL m_bSet = NO;

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation 
{
    if (!newLocation) {
        return;
    }
    
    CLLocationCoordinate2D oldCoordinate = self.currentLocation.coordinate;
    CLLocationCoordinate2D newCoordinate = newLocation.coordinate;
    
    if (!FEQUAL(oldCoordinate.latitude, newCoordinate.latitude) || !FEQUAL(oldCoordinate.longitude, newCoordinate.longitude)) {
        self.currentLocation = [[CLLocation alloc] initWithLatitude:newCoordinate.latitude longitude:newCoordinate.longitude];

//        if (m_bSet == NO) {
//            self.latestLocation = [[CLLocation alloc] initWithLatitude:newCoordinate.latitude longitude:newCoordinate.longitude];
//            m_bSet = YES;
//        }

        
        // self.latestLocation = [[CLLocation alloc] initWithLatitude:44.522200 longitude:-72.000800]; // for test
//        NSLog(@"Location Updated : %f, %f", self.latestLocation.coordinate.latitude, self.latestLocation.coordinate.longitude);
        
        NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
        [userStore setObject:[NSNumber numberWithDouble:newCoordinate.latitude] forKey:kUserLatitude];
        [userStore setObject:[NSNumber numberWithDouble:newCoordinate.longitude] forKey:kUserLongitude];
        [userStore synchronize];
        
        [self postLocationUpdateNotification];

//        [self.locManager stopUpdatingLocation];
//        self.locManager.delegate = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error 
{
    NSLog(@"location fail : %@", error);
}



- (NSString*) getCustomUserLocationAddress{
    if (self.latestLocation != nil) {
        return [GeoLocation getAddress:self.latestLocation];
    }
    else {
        return [self getStandardUserLocationAddress];
    }
    return @"";
}


- (NSString*) getStandardUserLocationAddress{
    
    return [GeoLocation getAddress:self.currentLocation];
    
}



@end
