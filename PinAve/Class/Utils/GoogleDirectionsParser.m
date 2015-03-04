//
//  GoogleDirectionsParser.m
//  iTourTheCaribbean
//
//  Created by challenger Pang on 11. 9. 22..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GoogleDirectionsParser.h"
#import "JSON.h"
#import "JsonReader.h"
#import "UserLocationManager.h"


NSString *kRoutes				= @"routes";

NSString *kBounds				= @"bounds";
NSString *kNorthEast			= @"northeast";
NSString *kSouthWest			= @"southwest";
NSString *kLat					= @"lat";
NSString *kLng					= @"lng";

NSString *kLegs					= @"legs";
NSString *kDistance				= @"distance";
NSString *kDuration				= @"duration";
NSString *kText					= @"text";
NSString *kValue				= @"value";
NSString *kEndAddress			= @"end_address";
NSString *kEndLocation			= @"end_location";
NSString *kStartAddress			= @"start_address";
NSString *kStartLocation		= @"start_location";
NSString *kSteps				= @"steps";
NSString *kHtmlInstructions		= @"html_instructions";
NSString *kPolyline				= @"polyline";
NSString *kPoints				= @"points";
NSString *kTravelMode			= @"travel_mode";
NSString *valDrivingMode		= @"DRIVING";
NSString *kViaWaypoint			= @"via_waypoint";

NSString *kOverviewPolyline		= @"overview_polyline";
NSString *kSummary				= @"summary";
NSString *kWarnings				= @"warnings";
NSString *kWaypointOrder		= @"waypoint_order";

NSString *kStatus				= @"status";
NSString *valOKStatus			= @"OK";

@interface GoogleDirectionsParser () {
    BOOL isStopped;
}

@property (strong, nonatomic) NSMutableData *m_responseData;

@end


@implementation GoogleDirectionsParser

@synthesize delegate;
@synthesize m_responseData;
@synthesize m_dicDirections;


- (id)initWithLocations:(NSArray *)locations
{
	if ([locations count] < 2) {
		return nil;
	}
	
	if ((self = [super init])) {
		self.m_responseData = [NSMutableData data];
		
		NSString *strUrl = @"http://maps.googleapis.com/maps/api/directions/json?";
		
		CLLocationCoordinate2D locationValue = [[locations objectAtIndex:0] coordinate];
		strUrl = [strUrl stringByAppendingFormat:@"origin=%f,%f", 
				  locationValue.latitude, locationValue.longitude];
		
		locationValue = [[locations lastObject] coordinate];
		strUrl = [strUrl stringByAppendingFormat:@"&destination=%f,%f", 
				  locationValue.latitude, locationValue.longitude];
		
		if ([locations count] > 2) {
			strUrl = [strUrl stringByAppendingString:@"&waypoints="];
			for (int idx = 1; idx < [locations count] - 1; idx++) {
				locationValue = [[locations objectAtIndex:idx] coordinate];
				strUrl = [strUrl stringByAppendingFormat:@"%f,%f", 
						  locationValue.latitude, locationValue.longitude];
				if (idx < [locations count] - 2) {
					strUrl = [strUrl stringByAppendingString:@"|"];
				}
			}
		}
		
		strUrl = [strUrl stringByAppendingString:@"&sensor=false"];
		// NSLog(@"url : %@", strUrl);
		
		isStopped = NO;
		
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
		NSURLConnection *googleConnect = [NSURLConnection connectionWithRequest:request delegate:self];
        [googleConnect start];
	}
	
	return self;
}

- (id)initWithDestination:(NSString *)destination : (int) mode
{
    if ((self = [super init])) {
		self.m_responseData = [NSMutableData data];
		
		NSMutableString *strUrl = [NSMutableString stringWithString:@"http://maps.googleapis.com/maps/api/directions/json?"];
		
		CLLocationCoordinate2D locationValue = [UserLocationManager sharedInstance].currentLocation.coordinate;
		[strUrl appendFormat:@"origin=%f,%f", locationValue.latitude, locationValue.longitude];
		[strUrl appendFormat:@"&destination=%@", destination];
		
        if (mode == 2) {
            [strUrl appendString:@"&mode=walking"];
        } else if (mode == 1) {
            [strUrl appendString:@"&mode=bicycling"];
        }
		
		[strUrl appendString:@"&sensor=false"];
		NSLog(@"route url : %@", strUrl);
		
		isStopped = NO;
		
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
		NSURLConnection *googleConnect = [NSURLConnection connectionWithRequest:request delegate:self];
        [googleConnect start];
    }
    
    return self;
}

- (id)initWithOriginAndDestination:(NSString*) original : (NSString *)destination : (int) mode
{
    if ((self = [super init])) {
        
		self.m_responseData = [NSMutableData data];

        
        CLLocationCoordinate2D originalLocation = [GeoLocation getCoordinateByAddress:original];
        
        
		NSMutableString *strUrl = [NSMutableString stringWithString:@"http://maps.googleapis.com/maps/api/directions/json?"];
		
		[strUrl appendFormat:@"origin=%f,%f", originalLocation.latitude, originalLocation.longitude];
		[strUrl appendFormat:@"&destination=%@", destination];
        if (mode == 2) {
            [strUrl appendString:@"&mode=walking"];
        } else if (mode == 1) {
            [strUrl appendString:@"&mode=bicycling"];
        }
		[strUrl appendString:@"&sensor=false"];
		NSLog(@"route url : %@", strUrl);
		
		isStopped = NO;
		
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
		NSURLConnection *googleConnect = [NSURLConnection connectionWithRequest:request delegate:self];
        [googleConnect start];
 
    }
    
    return self;
}

- (id)initWithOriginAndDestination:(CLLocationDegrees) originX : (CLLocationDegrees) originY : (CLLocationDegrees)desX : (CLLocationDegrees) desY : (int) mode
{
    if ((self = [super init])) {
        
		self.m_responseData = [NSMutableData data];
        
		NSMutableString *strUrl = [NSMutableString stringWithString:@"http://maps.googleapis.com/maps/api/directions/json?"];
		
		[strUrl appendFormat:@"origin=%f,%f", originX, originY];
		[strUrl appendFormat:@"&destination=%f,%f", desX, desY];
        
        if (mode == 2) {
            [strUrl appendString:@"&mode=walking"];
        } else if (mode == 1) {
            [strUrl appendString:@"&mode=bicycling"];
        }
		[strUrl appendString:@"&sensor=false"];
        
		NSLog(@"route url : %@", strUrl);
		
		isStopped = NO;
		
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
		NSURLConnection *googleConnect = [NSURLConnection connectionWithRequest:request delegate:self];
        [googleConnect start];
        
    }
    
    return self;
}


/*
-(void) geocodeAddress:(NSString*) address {
    
    NSLog(@"Geocoding address: %@", address);
    
    // don't make requests faster than 0.5 seconds
    // Google may block/ban your requests if you abuse the service
    double pause = 0.1;
    NSDate *now = [NSDate date];
    NSTimeInterval elapsed = [now timeIntervalSinceDate:self.lastPetition];
    self.lastPetition = now;
    if (elapsed>0.0 && elapsed<pause){
        NSLog(@"    Elapsed < pause = %f < %f, sleeping for %f seconds", elapsed, pause, pause-elapsed);
        [NSThread sleepForTimeInterval:pause-elapsed];
    }
    

    
    // url encode
    NSString *encodedAddress = (NSString *) CFURLCreateStringByAddingPercentEscapes(
                                                                                    NULL, (CFStringRef) address,
                                                                                    NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                                    kCFStringEncodingUTF8 );

    NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", encodedAddress];
    //NSLog(@"    url is %@", url);
    
    // try twice to geocode the address
    NSDictionary *dic;
    for (int i=0; i<2; i++) { // two tries
        
        HttpDownload *http = [HttpDownload new];
        NSString *page = [http pageAsStringFromUrl:url];

        dic = [JsonParser parseJson:page];
        NSString *status = (NSString*)[dic objectForKey:@"status"];
        BOOL success = [status isEqualToString:@"OK"];
        if (success) break;
        
        // Query failed
        // See http://code.google.com/apis/maps/documentation/geocoding/#StatusCodes
        if ([status isEqualToString:@"OVER_QUERY_LIMIT"]){
            NSLog(@"try #%d", i);
            [NSThread sleepForTimeInterval:1];
        } else if ([status isEqualToString:@"ZERO_RESULTS"]){
            NSLog(@"    Address unknown: %@", address);
            break;
        } else {
            // REQUEST_DENIED: no sensor parameter. Shouldn't happen.
            // INVALID_REQUEST: no address parameter or empty address. Doesn't matter.
        }
        
    }

    
    JsonReader *jsonReader = [[JsonReader alloc] initWithUrl:url delegate:self];
    [jsonReader read];
    
}

- (void)didJsonRead:(id)result
{
    
    NSDictionary *dic = result;
    if (!dic) {
        NSLog(@"");
        return;
    }

    
    // if we fail after two tries, just leave
    NSString *status = (NSString*)[dic objectForKey:@"status"];
    BOOL success = [status isEqualToString:@"OK"];
    if (!success) return nil;
    
    // extract the data
    {
        int results = [[dic objectForKey:@"results"] count];
        if (results>1){
            NSLog(@"    There are %d possible results for this adress.", results);
        }
    }
    
    NSDictionary *locationDic = [[[[dic objectForKey:@"results"] objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"];
    NSNumber *latitude = [locationDic objectForKey:@"lat"];
    NSNumber *longitude = [locationDic objectForKey:@"lng"];    
    NSLog(@"    Google returned coordinate = { %f, %f }", [latitude floatValue], [longitude floatValue]);
    
    // return as location
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
    
}
*/

/*
+(NSDictionary*) parseJson:(NSString*) jsonString {
    
    NSDictionary *rootDict = nil;
    NSError *error = nil;
    @try {
        JKParseOptionFlags options = JKParseOptionComments | JKParseOptionUnicodeNewlines;
        rootDict = [jsonString objectFromJSONStringWithParseOptions:options error:&error];
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }
        NSLog(@"    JSONKit: %d characters resulted in %d root node", [jsonString length], [rootDict count]);
        
    } @catch (NSException * e) {
        // If data is 0 bytes, here we get: "NSInvalidArgumentException The string argument is NULL"
        NSLog(@"%@ %@", [e name], [e reason]);
        
        // abort
        rootDict = nil;
    }
    return rootDict;
}
*/


- (void)stopParse
{
	isStopped = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[self.m_responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.m_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Connection failed: %@", [error localizedDescription]);
	
	if (isStopped) {
		return;
	}
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(directionsParser:didFinished:)]) {
		[self.delegate directionsParser:self didFinished:NO];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (isStopped) {
		self.m_responseData = nil;
		return;
	}
	
	NSString *responseString = [[NSString alloc] initWithData:self.m_responseData encoding:NSUTF8StringEncoding];
	self.m_responseData = nil;
	
	SBJsonParser *JSonParser = [SBJsonParser new];
	self.m_dicDirections = [JSonParser objectWithString:responseString];
	
	if (self.m_dicDirections == nil) {
		NSLog(@"JSON parsing failed");
		if (self.delegate && [self.delegate respondsToSelector:@selector(directionsParser:didFinished:)]) {
			[self.delegate directionsParser:self didFinished:NO];
		}
	} else {
		if (self.delegate && [self.delegate respondsToSelector:@selector(directionsParser:didFinished:)]) {
			[self.delegate directionsParser:self didFinished:YES];
		}
	}
}


-(NSMutableArray *)decodePolyLine:(NSMutableString *)encoded {
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\" 
								options:NSLiteralSearch 
								  range:NSMakeRange(0, [encoded length])];
	
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *polyLines = [NSMutableArray array];
	NSInteger lat = 0;
	NSInteger lng = 0;
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		
		NSNumber *latitude = [NSNumber numberWithFloat:lat * 1e-5];
		NSNumber *longitude = [NSNumber numberWithFloat:lng * 1e-5];
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] 
													 longitude:[longitude floatValue]];
		[polyLines addObject:loc];
		NSLog(@"%f,%f", [latitude floatValue], [longitude floatValue]);
	}
	
	return polyLines;
}


#define IsEqualString(string1,string2)	([(string1) caseInsensitiveCompare:(string2)] == NSOrderedSame)

- (NSArray *)getDirectionSteps {
	if ([[self.m_dicDirections objectForKey:kStatus] caseInsensitiveCompare:valOKStatus] != NSOrderedSame) {
		return nil;
	}
	
	NSDictionary *dicPrimaryRoute = [[self.m_dicDirections objectForKey:kRoutes] objectAtIndex:0];
    
	NSMutableString *strEncodedPoints = [NSMutableString stringWithString:
										 [[dicPrimaryRoute objectForKey:kOverviewPolyline] objectForKey:kPoints]];
	
	return [self decodePolyLine:strEncodedPoints];
}

- (NSString*) getDistance {
	NSDictionary *dicPrimaryRoute = [[self.m_dicDirections objectForKey:kRoutes] objectAtIndex:0];
    NSDictionary *mainLeg = [[dicPrimaryRoute objectForKey:kLegs] objectAtIndex:0];
    
    return [[mainLeg objectForKey:kDistance] objectForKey:kText];
}

- (NSString*) getDuration{
	NSDictionary *dicPrimaryRoute = [[self.m_dicDirections objectForKey:kRoutes] objectAtIndex:0];
    NSDictionary *mainLeg = [[dicPrimaryRoute objectForKey:kLegs] objectAtIndex:0];
    
    return [[mainLeg objectForKey:kDuration] objectForKey:kText];
}

- (MKPointAnnotation *)getStartPoint
{
    MKPointAnnotation *result = [MKPointAnnotation new];
    
	NSDictionary *dicPrimaryRoute = [[self.m_dicDirections objectForKey:kRoutes] objectAtIndex:0];
    NSDictionary *mainLeg = [[dicPrimaryRoute objectForKey:kLegs] objectAtIndex:0];
    NSDictionary *location = [mainLeg objectForKey:kStartLocation];
    result.coordinate = CLLocationCoordinate2DMake([[location objectForKey:kLat] doubleValue], [[location objectForKey:kLng] doubleValue]);
    result.title = [mainLeg objectForKey:kStartAddress];
    
    return result;
}

- (MKPointAnnotation *)getEndPoint
{
    MKPointAnnotation *result = [MKPointAnnotation new];
    
	NSDictionary *dicPrimaryRoute = [[self.m_dicDirections objectForKey:kRoutes] objectAtIndex:0];
    NSDictionary *mainLeg = [[dicPrimaryRoute objectForKey:kLegs] objectAtIndex:0];
    NSDictionary *location = [mainLeg objectForKey:kEndLocation];
    result.coordinate = CLLocationCoordinate2DMake([[location objectForKey:kLat] doubleValue], [[location objectForKey:kLng] doubleValue]);
    result.title = [mainLeg objectForKey:kEndAddress];
    
    return result;
}

@end
