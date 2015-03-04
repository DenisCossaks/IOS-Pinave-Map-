//
//  GeoLocation.h
//  PinAve
//
//  Created by Yuan Luo on 5/6/13.
//
//

#import <Foundation/Foundation.h>
#import "MJGeocodingServices.h"


@interface GeoLocation : NSObject


NSString * FilterAddress(NSString *address);
NSString * FilterPostcode(NSString *postcode);
NSString * GetRealAddress(NSString* A2, NSString* TN, NSString* PC);
float DistanceBetweenCoords(float lat1, float lon1, float lat2, float lon2);
float Radians(float degs);


+ (CLLocationCoordinate2D) getCoordinateByAddress:(NSString *)address;
+ (NSMutableArray*) getCoordinateListByAddress:(NSString *)address;

+ (NSString*) getAddress :(CLLocation*) location;
+ (NSString*) getAddress :(CLLocationDegrees) latitude longitude:(CLLocationDegrees) longitude;

+ (NSMutableDictionary*) getAddressDetail :(CLLocationDegrees) latitude longitude:(CLLocationDegrees) longitude;

+ (NSString*) getUserCountry;

@end
