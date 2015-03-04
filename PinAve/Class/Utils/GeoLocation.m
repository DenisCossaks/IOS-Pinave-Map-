//
//  GeoLocation.m
//  PinAve
//
//  Created by Yuan Luo on 5/6/13.
//
//

#import "GeoLocation.h"
#import "SBJsonParser.h"


@implementation GeoLocation

#pragma mark --- Location --------
float Radians(float degs)
{
	return (degs * M_PI / 180.0);
}


float DistanceBetweenCoords(float lat1, float lon1, float lat2, float lon2)
{
	float radiusEarth = 6371.0 / 1.609344; // in miles
	
	float dlat = Radians(lat2 - lat1);
	float dlon = Radians(lon2 - lon1);
	
	float a = sin(dlat/2.0) * sin(dlat/2.0) + cos(Radians(lat1)) * cos(Radians(lat2)) * sin(dlon/2.0) * sin(dlon/2.0);
	float c = 2 * atan2(sqrt(a), sqrt(1.0 - a));
	
	return radiusEarth * c;
}

NSString * FilterAddress(NSString *address)
{
	NSRange spacePos = [address rangeOfString:@" "];
	
	if (spacePos.location != NSNotFound)
	{
		NSString *firstWord = [address substringToIndex:spacePos.location];
		
		if ([firstWord intValue] != 0)
		{
			return [address substringFromIndex:spacePos.location + 1];
		}
	}
	
	return address;
}

NSString * FilterPostcode(NSString *postcode)
{
	NSRange spaceAtBack = [postcode rangeOfString:@" " options:NSBackwardsSearch];
	
	if (spaceAtBack.location != NSNotFound)
	{
		return [postcode substringToIndex:spaceAtBack.location];
	}
	
	return postcode;
}


NSString* GetRealAddress(NSString* A2, NSString* TN, NSString* PC)
{
	NSString* addr = nil;
	NSRange rng;
	if ( ![TN isEqualToString: @""] )
	{
		rng = [A2 rangeOfString: TN];
		if ( rng.location != NSNotFound )
		{
			addr = [NSString stringWithFormat: @"%@%@, %@", [A2 substringToIndex: rng.location], TN, FilterPostcode(PC)];
			return addr;
		}
	}
	rng = [A2 rangeOfString: FilterPostcode(PC)];
	if ( rng.location != NSNotFound )
	{
		addr = [NSString stringWithFormat: @"%@%@", [A2 substringToIndex: rng.location], FilterPostcode(PC)];
		return addr;
	}
	
	if ( ![TN isEqualToString: @""] )
		addr = [NSString stringWithFormat: @"%@, %@, %@", FilterAddress(A2), TN, FilterPostcode(PC)];
	else
		addr = [NSString stringWithFormat: @"%@, %@", FilterAddress(A2), FilterPostcode(PC)];
	return addr;
}

+ (CLLocationCoordinate2D) getCoordinateByAddress:(NSString *)address
{
    
    NSString * urlString = [Utils getSearchURLFromText:address];
    
    NSString *pinResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    id resultDict = [JSonParser objectWithString:pinResult];

    
    NSString * status = [resultDict objectForKey:@"status"];
    
    if ([status isEqualToString:@"OK"]) {

        NSMutableArray *results;

        NSArray *foundLocations = [resultDict objectForKey:@"results"];
		results = [NSMutableArray arrayWithCapacity:[foundLocations count]];
		
		for (NSDictionary *location in foundLocations) {
//			NSArray *firstResultAddress = [location objectForKey:@"address_components"];
			
            double lat = [[[[location objectForKey:@"geometry"] objectForKey:@"location"] valueForKey:@"lat"] doubleValue];
            double lng = [[[[location objectForKey:@"geometry"] objectForKey:@"location"] valueForKey:@"lng"] doubleValue];
            
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lng);
            return coord;
            
//			Address *resultAddress = [[Address alloc] initWithCoordinate:coord];
//            
//			resultAddress.fullAddress = [location valueForKey:@"formatted_address"];
//			resultAddress.streetNumber = [Address addressComponent:@"street_number" inAddressArray:firstResultAddress ofType:@"long_name"];
//			resultAddress.route = [Address addressComponent:@"route" inAddressArray:firstResultAddress ofType:@"long_name"];
//			resultAddress.city = [Address addressComponent:@"locality" inAddressArray:firstResultAddress ofType:@"long_name"];
//			resultAddress.stateCode = [Address addressComponent:@"administrative_area_level_1" inAddressArray:firstResultAddress ofType:@"short_name"];
//			resultAddress.postalCode = [Address addressComponent:@"postal_code" inAddressArray:firstResultAddress ofType:@"short_name"];
//			resultAddress.countryName = [Address addressComponent:@"country" inAddressArray:firstResultAddress ofType:@"long_name"];
//			
//			[results addObject:resultAddress];
		}
		
		
    }
    
    return CLLocationCoordinate2DMake(0, 0);
}

+ (NSMutableArray*) getCoordinateListByAddress:(NSString *)address
{
    NSString * urlString = [Utils getSearchURLFromText:address];
    
    NSString *pinResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    id resultDict = [JSonParser objectWithString:pinResult];
    
    
    NSString * status = [resultDict objectForKey:@"status"];
    
    if ([status isEqualToString:@"OK"]) {
        
        NSMutableArray *results;
        
        NSArray *foundLocations = [resultDict objectForKey:@"results"];
		results = [NSMutableArray arrayWithCapacity:[foundLocations count]];
		
		for (NSDictionary *location in foundLocations) {
			NSArray *firstResultAddress = [location objectForKey:@"address_components"];
			
            double lat = [[[[location objectForKey:@"geometry"] objectForKey:@"location"] valueForKey:@"lat"] doubleValue];
            double lng = [[[[location objectForKey:@"geometry"] objectForKey:@"location"] valueForKey:@"lng"] doubleValue];
            
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lng);
            
			Address *resultAddress = [[Address alloc] initWithCoordinate:coord];
            
			resultAddress.fullAddress = [location valueForKey:@"formatted_address"];
			resultAddress.streetNumber = [Address addressComponent:@"street_number" inAddressArray:firstResultAddress ofType:@"long_name"];
			resultAddress.route = [Address addressComponent:@"route" inAddressArray:firstResultAddress ofType:@"long_name"];
			resultAddress.city = [Address addressComponent:@"locality" inAddressArray:firstResultAddress ofType:@"long_name"];
			resultAddress.stateCode = [Address addressComponent:@"administrative_area_level_1" inAddressArray:firstResultAddress ofType:@"short_name"];
			resultAddress.postalCode = [Address addressComponent:@"postal_code" inAddressArray:firstResultAddress ofType:@"short_name"];
			resultAddress.countryName = [Address addressComponent:@"country" inAddressArray:firstResultAddress ofType:@"long_name"];
			
			[results addObject:resultAddress];
		}
		
        return results;
		
    }
    
    return nil;
}


+ (NSString*) getAddress :(CLLocation*) location{
    
    return [GeoLocation getAddress:location.coordinate.latitude longitude: location.coordinate.longitude];
    
}

+ (NSString*) getAddress :(CLLocationDegrees) latitude longitude:(CLLocationDegrees) longitude{
    
    NSString *urlString = [Utils getAddressURLFromLocation:latitude : longitude];
    
    NSString *pinResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    id result = [JSonParser objectWithString:pinResult];
    

    NSString * status = [result objectForKey:@"status"];
    
    if ([status isEqualToString:@"OK"]) {
        
        NSMutableArray * arrResult = [result objectForKey: @"results"];
        
        if (arrResult != nil) {
            for (NSDictionary * oneResult in arrResult) {
                NSString * formatted_address = [oneResult objectForKey:@"formatted_address"];
                if (formatted_address != nil) {
                    return formatted_address;
                }
            }
        }
    }
    
    return @"User location cannot find";
}

+ (NSMutableDictionary*) getAddressDetail :(CLLocationDegrees) latitude longitude:(CLLocationDegrees) longitude{
    
    NSString *urlString = [Utils getAddressURLFromLocation:latitude : longitude];
    
    
    NSString *pinResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    id result = [JSonParser objectWithString:pinResult];
    
    
    NSString * status = [result objectForKey:@"status"];
    
    if ([status isEqualToString:@"OK"]) {
        
        NSMutableArray * arrResult = [result objectForKey: @"results"];
        
        
        if (arrResult != nil) {
            for (NSDictionary * oneResult in arrResult) {
                
                NSMutableDictionary * dicAddress = [NSMutableDictionary new];
                
                NSString * formatted_address = [oneResult objectForKey:@"formatted_address"];
                if (formatted_address != nil) {
                    [dicAddress setObject:formatted_address forKey:@"full_address"];
                }
                
                //////////
                NSString * router = nil;
                NSString * street_number = nil;
                
                NSArray * address_components = [oneResult objectForKey:@"address_components"];
                for (NSDictionary * dic in address_components) {
                    NSArray * typeAry = [dic objectForKey:@"types"];
                    NSString *type = [typeAry objectAtIndex:0];
                    
                    if ([type isEqualToString:@"country"]) {
                        [dicAddress setObject:[dic objectForKey:@"long_name"] forKey:@"country"];
                    }
                    
                    if ([type isEqualToString:@"administrative_area_level_1"]) {
                        [dicAddress setObject:[dic objectForKey:@"long_name"] forKey:@"state"];
                    }
                    
                    if ([type isEqualToString:@"locality"]) {
                        [dicAddress setObject:[dic objectForKey:@"long_name"] forKey:@"city"];
                    }

                    if ([type isEqualToString:@"route"]) {
                        router = [dic objectForKey:@"long_name"];
                    }
                    if ([type isEqualToString:@"street_number"]) {
                        street_number = [dic objectForKey:@"long_name"];
                    }

                }
                
                NSString * address = [NSString stringWithFormat:@"%@ %@", street_number==nil ? @"" : street_number,
                                      router == nil ? @"" : router];
                [dicAddress setObject:address forKey:@"address"];

                
                return dicAddress;
                
            }
        }
    }
    
    return nil;
}

+ (NSString*) getUserCountry{
    
//    NSString *urlString = [Utils getAddressURLFromLocation:self.currentLocation.coordinate.latitude :self.currentLocation.coordinate.longitude];
//    
//    NSString *pinResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
//    
//    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
//    id result = [JSonParser objectWithString:pinResult];
//    
//    NSMutableDictionary *mutPlace = [result objectForKey: @"Placemark"];
//    
//    for (NSDictionary * forAddress in mutPlace) {
//        NSString *Address = [forAddress objectForKey: @"address"];
//        
//        if (Address.length < 1) {
//            Address = @"user location can not find";
//            return @"user country can not find";
//        }
//        
//        NSArray *div = [Address componentsSeparatedByString:@","];
//        NSString * strCountry = [NSString stringWithFormat:@"%@", [div objectAtIndex: [div count] - 1]];
//        
//        return strCountry;
//        
//    }
//    return @"user location can not find";
    
    return @"";
    
}


@end
