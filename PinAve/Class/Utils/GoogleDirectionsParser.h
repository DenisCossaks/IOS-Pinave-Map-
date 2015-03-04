//
//  GoogleDirectionsParser.h
//  iTourTheCaribbean
//
//  Created by challenger Pang on 11. 9. 22..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


extern NSString *kRoutes;

extern NSString *kBounds;
extern NSString *kNorthEast;
extern NSString *kSouthWest;
extern NSString *kLat;
extern NSString *kLng;

extern NSString *kLegs;
extern NSString *kDistance;
extern NSString *kDuration;
extern NSString *kText;
extern NSString *kValue;
extern NSString *kEndAddress;
extern NSString *kEndLocation;
extern NSString *kStartAddress;
extern NSString *kStartLocation;
extern NSString *kSteps;
extern NSString *kHtmlInstructions;
extern NSString *kPolyline;
extern NSString *kPoints;
extern NSString *kTravelMode;
extern NSString *valDrivingMode;
extern NSString *kViaWaypoint;

extern NSString *kOverviewPolyline;
extern NSString *kSummary;
extern NSString *kWarnings;
extern NSString *kWaypointOrder;

extern NSString *kStatus;
extern NSString *valOKStatus;


@protocol DirectionsParserDelegate;

@interface GoogleDirectionsParser : NSObject

@property (nonatomic, unsafe_unretained) NSObject <DirectionsParserDelegate> *delegate;
@property (strong, nonatomic) NSDictionary *m_dicDirections;

- (id)initWithLocations:(NSArray *)locations;
- (id)initWithDestination:(NSString *)destination : (int) mode;
- (id)initWithOriginAndDestination:(NSString*) original : (NSString *)destination : (int) mode;
- (id)initWithOriginAndDestination:(CLLocationDegrees) originX : (CLLocationDegrees) originY : (CLLocationDegrees)desX : (CLLocationDegrees) desY : (int) mode;    

- (NSArray *)getDirectionSteps;
- (void)stopParse;
- (MKPointAnnotation *)getStartPoint;
- (MKPointAnnotation *)getEndPoint;

- (NSString*) getDistance;
- (NSString*) getDuration;

@end


@protocol DirectionsParserDelegate

- (void)directionsParser:(GoogleDirectionsParser *)directionsParser didFinished:(BOOL)isSuccess;

@end
