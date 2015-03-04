//
//  Utils.m
//  NEP
//
//  Created by Dandong3 Sam on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "UserSession.h"
#import "UserLocationManager.h"

#import "Setting.h"
#import "FilterSearch.h"


@implementation Utils

+ (NSString *)getLoginUrl:(NSString *)email password:(NSString *)password
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/login?email=%@&password=%@", email, password] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"login url : %@", urlString);
    
    return urlString;
}

+ (NSString *)getLogoutUrl
{
    NSString *authCode = [UserSession session].authCode;
    if ([authCode length] == 0) {
        NSLog(@"There is no auth code.");
        return nil;
    }
    
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"v2/user/auth/%@", authCode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"logout url : %@", urlString);
    
    return urlString;
}

+ (NSString *)getMessageUrl
{
    NSString *authCode = [UserSession session].authCode;
    if ([authCode length] == 0) {
        NSLog(@"There is no auth code.");
        return nil;
    }
    
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/inbox/%@", authCode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"inbox url : %@", urlString);
    
    return urlString;
}

+ (NSString *)getSentMsgUrl
{
    NSString *authCode = [UserSession session].authCode;
    if ([authCode length] == 0) {
        NSLog(@"There is no auth code.");
        return nil;
    }
    
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/sent/%@", authCode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"inbox url : %@", urlString);
    
    return urlString;
}

+ (NSString *)getWriteUrl:(NSString *)title message:(NSString *)message recepient_id:(NSString *)recepient_id reply:(NSString *)message_id
{
    NSString *authCode = [UserSession session].authCode;
    if ([authCode length] == 0) {
        NSLog(@"There is no auth code.");
        return nil;
    }
    
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/write/%@?title=%@&message=%@&recepient_id=%@&reply=%@", authCode, message, title, recepient_id, message_id] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"write url : %@", urlString);
    
    return urlString;
}



+ (NSString *)getCategoryUrl
{
    NSString *urlString = [[SERVER_URL stringByAppendingString:@"request/categories"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"category url : %@", urlString);
    
    return urlString;
}

+ (NSString *)getUsersUrl
{
    NSString *urlString = [[SERVER_URL stringByAppendingString:@"request/users"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"users url : %@", urlString);
    
    return urlString;
}
+ (NSString *)getProfileDetail:(NSString*) authCode
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"v2/user/myprofile/%@", authCode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"users url : %@", urlString);
    
    return urlString;
}
+ (NSString *)postProfileDetail
{
    NSString *urlString = [[SERVER_URL stringByAppendingString:@"v2/user/update"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"update url : %@", urlString);
    
    return urlString;
}

+ (NSString *)getMyAvenueUsersUrl
{
    NSString *auth_code = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginCode"];
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/myavenue/%@", auth_code] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"getMyAvenueUsersUrl url : %@", urlString);
    
    return urlString;
}

+ (NSString *)getPinForUserUrl:(NSString *)user_id
{
//    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/upins/%@", user_id] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/upins/%@&pg=5&limit=%d", user_id, [Setting getNumberOfPins]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];    
    NSLog(@"pins url : %@", urlString);
    
    return urlString;
}

+ (NSString *)getPinForUserUrl1:(NSString *)user_id
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/upins/%@", user_id] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return urlString;
}


+ (NSString *)getPinFromLocation:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude :(CLLocationDegrees) radius
{
    
    NSString * timezone = [Setting getTimezone];
/*
    NSString * str_start_full = [Setting getStartDate];
    NSDate * date_Start = [Utils dateFromString:str_start_full : DATE_FULL];
    
    NSString * start_date = [self getDateString: date_Start : DATE_DATE];
    NSString * start_time = [self getDateString: date_Start : DATE_TIME];
    
    NSString * str_end_full = [Setting getEndDate];
    NSDate * date_End = [Utils dateFromString: str_end_full : DATE_FULL];
    
    NSString * end_date = [self getDateString: date_End : DATE_DATE];
    NSString * end_time = [self getDateString: date_End : DATE_TIME];
*/
    
/*    
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/all_pins?lat=%f&lng=%f&radius=%fpins=%d&tz=%@&start_date=%@&end_date=%@&start_time=%@&end_time=%@", 
                            latitude, longitude,
                            radius, [Setting getNumberOfPins], 
                            timezone,
                            start_date, end_date, start_time, end_time] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
*/    
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/all_pins?lat=%f&lng=%f&radius=%fpins=%d&tz=%@", 
                            latitude, longitude,
                            radius, [Setting getNumberOfPins], 
                            timezone] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSLog(@"pins url : %@", urlString);
    
    return urlString;  
    
}

+ (NSString *)getCountPins
{
    NSString * timezone = [Setting getTimezone];

/*
    NSString * str_start_full = [Setting getStartDate];
    NSDate * date_Start = [Utils dateFromString:str_start_full : DATE_FULL];
    
    NSString * start_date = [self getDateString: date_Start : DATE_DATE];
    NSString * start_time = [self getDateString: date_Start : DATE_TIME];
    
    NSString * str_end_full = [Setting getEndDate];
    NSDate * date_End = [Utils dateFromString: str_end_full : DATE_FULL];
    
    NSString * end_date = [self getDateString: date_End : DATE_DATE];
    NSString * end_time = [self getDateString: date_End : DATE_TIME];
*/
    
    float radius = [Setting getRadius];
    if ([Setting getUnit] == 1) { // if mile
        radius = radius * 1.613;
    }
    
    NSString* strCategory = @"";
    for (NSMutableDictionary * dic in [Share getInstance].arrayCategory) {
        strCategory  = [strCategory stringByAppendingFormat:@"&category[]=%@", [dic objectForKey:@"id"]];
    }

//    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/count?lat=%f&lng=%f&radius=%f&pins=%d&tz=%@&start_date=%@&end_date=%@&start_time=%@&end_time=%@%@", 
//                            [UserLocationManager sharedInstance].latestLocation.coordinate.latitude,
//                            [UserLocationManager sharedInstance].latestLocation.coordinate.longitude,
//                            radius, [Setting getNumberOfPins], 
//                            timezone,
//                            start_date, end_date, start_time, end_time, strCategory] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    CLLocation* location;
    if ([UserLocationManager sharedInstance].latestLocation != nil) {
        location = [UserLocationManager sharedInstance].latestLocation;
    } else {
        location = [UserLocationManager sharedInstance].currentLocation;
    }
    
//    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/count?lat=%f&lng=%f&radius=%f&pins=%d&tz=%@%@",
//                            location.coordinate.latitude,
//                            location.coordinate.longitude,
//                            radius, [Setting getNumberOfPins],
//                            timezone,
//                            strCategory] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [SERVER_URL stringByAppendingFormat:@"request/count?lat=%f&lng=%f&radius=%f&pins=%d&tz=%@%@",
                            location.coordinate.latitude,
                            location.coordinate.longitude,
                            radius, [Setting getNumberOfPins],
                            timezone,
                            strCategory];
    
    NSLog(@"getCountPins url : %@", urlString);
    
    return urlString;
}



+ (NSString *)getPinForCurrentUser
{
    NSString * timezone = [Setting getTimezone];
/*
    NSString * str_start_full = [Setting getStartDate];
    NSDate * date_Start = [Utils dateFromString:str_start_full : DATE_FULL];
    
    NSString * start_date = [self getDateString: date_Start : DATE_DATE];
    NSString * start_time = [self getDateString: date_Start : DATE_TIME];
    
    NSString * str_end_full = [Setting getEndDate];
    NSDate * date_End = [Utils dateFromString: str_end_full : DATE_FULL];
    
    NSString * end_date = [self getDateString: date_End : DATE_DATE];
    NSString * end_time = [self getDateString: date_End : DATE_TIME];
*/
    
    float radius = [Setting getRadius];
    if ([Setting getUnit] == 1) { // if mile
        radius = radius * 1.613;
    }
    
/*    
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/all_pins?lat=%f&lng=%f&radius=%f&pins=%d&tz=%@&start_date=%@&end_date=%@&start_time=%@&end_time=%@", 
                            [UserLocationManager sharedInstance].currentLocation.coordinate.latitude,
                            [UserLocationManager sharedInstance].currentLocation.coordinate.longitude,
                            radius, [Setting getNumberOfPins], 
                            timezone,
                            start_date, end_date, start_time, end_time] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
*/    
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/all_pins?lat=%f&lng=%f&radius=%f&pins=%d&tz=%@", 
                            [UserLocationManager sharedInstance].currentLocation.coordinate.latitude,
                            [UserLocationManager sharedInstance].currentLocation.coordinate.longitude,
                            radius, [Setting getNumberOfPins], 
                            timezone] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSLog(@"pins url : %@", urlString);
    
    return urlString;
}

+ (NSString *)getPinForUser : (NSMutableArray* ) arrCategory : (float) _radius
{
    NSString * timezone = [Setting getTimezone];
    /*
     NSString * str_start_full = [Setting getStartDate];
     NSDate * date_Start = [Utils dateFromString:str_start_full : DATE_FULL];
     
     NSString * start_date = [self getDateString: date_Start : DATE_DATE];
     NSString * start_time = [self getDateString: date_Start : DATE_TIME];
     
     NSString * str_end_full = [Setting getEndDate];
     NSDate * date_End = [Utils dateFromString: str_end_full : DATE_FULL];
     
     NSString * end_date = [self getDateString: date_End : DATE_DATE];
     NSString * end_time = [self getDateString: date_End : DATE_TIME];
     */
    
    float radius = [Setting getRadius];
    if ([Setting getUnit] == 1) { // if mile
        radius = radius * 1.613;
    }
    
    
    NSString* strCategory = @"";
    for (NSMutableDictionary * itemCategory in arrCategory) {
        BOOL isSelected = [[itemCategory objectForKey:@"selected"] boolValue];
        if (isSelected == YES) {
            NSString * categoryID = [itemCategory objectForKey:@"id"];
            strCategory  = [strCategory stringByAppendingFormat:@"&category[]=%@", categoryID];
        }
    }
    
    /*
     NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/all_pins?lat=%f&lng=%f&radius=%f&pins=%d&tz=%@&start_date=%@&end_date=%@&start_time=%@&end_time=%@%@",
     [UserLocationManager sharedInstance].latestLocation.coordinate.latitude,
     [UserLocationManager sharedInstance].latestLocation.coordinate.longitude,
     _radius, [Setting getNumberOfPins],
     timezone,
     start_date, end_date, start_time, end_time,
     strCategory] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
     */
    CLLocation* location;
    if ([UserLocationManager sharedInstance].latestLocation != nil) {
        location = [UserLocationManager sharedInstance].latestLocation;
    } else {
        location = [UserLocationManager sharedInstance].currentLocation;
    }
    
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/all_pins?lat=%f&lng=%f&radius=%f&pins=%d&tz=%@%@",
                            location.coordinate.latitude,
                            location.coordinate.longitude,
                            _radius, [Setting getNumberOfPins],
                            timezone,
                            strCategory] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"pins url : %@", urlString);
    
    return urlString;
}

+ (NSString *)getPinForUser : (NSMutableArray* ) arrCategory : (float) _radius :(int) curPage : (int) limitPin
{
    NSString * timezone = [Setting getTimezone];
    
    float radius = [Setting getRadius];
    if ([Setting getUnit] == 1) { // if mile
        radius = radius * 1.613;
    }
    
    NSString* strCategory = @"";
    for (NSMutableDictionary * itemCategory in arrCategory) {
        BOOL isSelected = [[itemCategory objectForKey:@"selected"] boolValue];
        if (isSelected == YES) {
            NSString * categoryID = [itemCategory objectForKey:@"id"];
            strCategory  = [strCategory stringByAppendingFormat:@"&category[]=%@", categoryID];
        }
    }
    
    CLLocation* location;
    if ([UserLocationManager sharedInstance].latestLocation != nil) {
        location = [UserLocationManager sharedInstance].latestLocation;
    } else {
        location = [UserLocationManager sharedInstance].currentLocation;
    }
    
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/all_pins?lat=%f&lng=%f&radius=%f&pins=%d&tz=%@&pg=%d&limit=%d%@",
                            location.coordinate.latitude,
                            location.coordinate.longitude,
                            _radius, [Setting getNumberOfPins], 
                            timezone,
                            curPage,
                            limitPin,
                            strCategory] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSLog(@"pins url : %@", urlString);
    
    return urlString;
}

+ (NSString *)getPinForRealUser : (NSMutableArray* ) arrCategory : (float) _radius
{
    NSString * timezone = [Setting getTimezone];
/*
    NSString * str_start_full = [Setting getStartDate];
    NSDate * date_Start = [Utils dateFromString:str_start_full : DATE_FULL];
    
    NSString * start_date = [self getDateString: date_Start : DATE_DATE];
    NSString * start_time = [self getDateString: date_Start : DATE_TIME];
    
    NSString * str_end_full = [Setting getEndDate];
    NSDate * date_End = [Utils dateFromString: str_end_full : DATE_FULL];
    
    NSString * end_date = [self getDateString: date_End : DATE_DATE];
    NSString * end_time = [self getDateString: date_End : DATE_TIME];
*/    
    
    float radius = [Setting getRadius];
    if ([Setting getUnit] == 1) { // if mile
        radius = radius * 1.613;
    }
    
    
    NSString* strCategory = @"";
    for (NSMutableDictionary * itemCategory in arrCategory) {
        BOOL isSelected = [[itemCategory objectForKey:@"selected"] boolValue];
        if (isSelected == YES) {
            NSString * categoryID = [itemCategory objectForKey:@"id"];
            strCategory  = [strCategory stringByAppendingFormat:@"&category[]=%@", categoryID];
        }
    }
    
/*    
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/all_pins?lat=%f&lng=%f&radius=%f&pins=%d&tz=%@&start_date=%@&end_date=%@&start_time=%@&end_time=%@%@",
                            [UserLocationManager sharedInstance].latestLocation.coordinate.latitude,
                            [UserLocationManager sharedInstance].latestLocation.coordinate.longitude,
                            _radius, [Setting getNumberOfPins], 
                            timezone,
                            start_date, end_date, start_time, end_time,
                            strCategory] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
*/
    CLLocation* location;
    if ([UserLocationManager sharedInstance].latestLocation != nil) {
        location = [UserLocationManager sharedInstance].latestLocation;
    } else {
        location = [UserLocationManager sharedInstance].currentLocation;
    }

    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/all_pins?lat=%f&lng=%f&radius=%f&pins=%d&tz=%@%@",
                            location.coordinate.latitude,
                            location.coordinate.longitude,
                            _radius, [Setting getNumberOfPins], 
                            timezone,
                            strCategory] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSLog(@"pins url : %@", urlString);
    
    return urlString;
}


+ (NSString *)getRegisterUrl
{
//    NSString *urlString = [[SERVER_URL stringByAppendingString:@"request/reg"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [[SERVER_URL stringByAppendingString:@"v2/user/auth"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"register url : %@", urlString);
    
    return urlString;
}


+ (NSString *)getPlacePinUrl
{
    NSString *urlString = [[SERVER_URL stringByAppendingString:@"request/place_pin"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"place pin url : %@", urlString);
    
    return urlString;
}

+ (NSString *)getUpdateDetailUrl
{
    NSString *urlString = [[SERVER_URL stringByAppendingString:@"request/update"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"update url : %@", urlString);
    
    return urlString;
}



+ (NSString *)getSearchUrl:(NSString*) search :(NSString*) country : (NSString*) city : (NSMutableArray*) arrCategory : (int) timeOption
{
/*    
    NSString * str_start = [FilterSearch getStartDate];
    NSDate * date_start = [Utils dateFromString:str_start :DATE_FULL];
    NSString * start_date = [Utils getDateString:date_start :DATE_DATE]; 
    NSString * start_time = [Utils getDateString:date_start :DATE_TIME]; 

    NSString * str_end = [FilterSearch getEndDate];
    NSDate * date_end = [Utils dateFromString:str_end :DATE_FULL];
    NSString * end_date = [Utils getDateString:date_end :DATE_DATE]; 
    NSString * end_time = [Utils getDateString:date_end :DATE_TIME]; 
*/

    NSDate * date_start = [NSDate date];
    NSString * start_date = [Utils getDateString:date_start :DATE_DATE]; 
    NSString * start_time = [Utils getDateString:date_start :DATE_TIME]; 
    
    
    NSDate * date_end;
    NSString *end_date, *end_time;
    
    if (timeOption == NOW) {
        end_date = start_date;
        end_time = start_time;
    } else if (timeOption == TODAY) {
        end_date = start_date;
        end_time = @"23:59";
    } else if (timeOption == THISWEEK) {
        NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
        [dateComponents setWeek:1];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        date_end = [calendar dateByAddingComponents:dateComponents toDate:date_start options:0];
        
        end_date = [Utils getDateString:date_end :DATE_DATE];
        end_time = @"23:59";
    } else if (timeOption == THISMONTH) {
        NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
        [dateComponents setMonth:1];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        date_end = [calendar dateByAddingComponents:dateComponents toDate:date_start options:0];
        
        end_date = [Utils getDateString:date_end :DATE_DATE];
        end_time = @"23:59";
    }

    
    NSString* tz = [Setting getTimezone];
    
    NSString* strCategory = @"";
    for (NSString * categoryID in arrCategory) {
        strCategory  = [strCategory stringByAppendingFormat:@"&category[]=%@", categoryID];
    }

    country = @"USA";
    
//    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/map?search=%@&start_date=%@&end_date=%@&start_time=%@&end_time=%@&location=%@|:|%@&tz=%@&reload=true&%@", search, start_date, end_date, start_time, end_time, country, city, tz, strCategory ] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/map?search=%@&start_date=%@&end_date=%@&start_time=%@&end_time=%@&location=%@&tz=%@&reload=true&%@", search, start_date, end_date, start_time, end_time, country, tz, strCategory ] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"search = %@", urlString);
    
    return urlString;                           
}

+ (NSString *)getSearchUrl:(NSString*) search : (NSMutableArray*) arrCategory : (int) timeOption
{
    
    NSDate * date_start = [NSDate date];
    NSString * start_date = [Utils getDateString:date_start :DATE_DATE]; 
    NSString * start_time = [Utils getDateString:date_start :DATE_TIME]; 
    
    
    NSDate * date_end;
    NSString *end_date, *end_time;
    
    if (timeOption == NOW) {
        end_date = start_date;
        end_time = start_time;
    } else if (timeOption == TODAY) {
        end_date = start_date;
        end_time = @"23:59";
    } else if (timeOption == THISWEEK) {
        NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
        [dateComponents setWeek:1];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        date_end = [calendar dateByAddingComponents:dateComponents toDate:date_start options:0];
        
        end_date = [Utils getDateString:date_end :DATE_DATE];
        end_time = @"23:59";
    } else if (timeOption == THISMONTH) {
        NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
        [dateComponents setMonth:1];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        date_end = [calendar dateByAddingComponents:dateComponents toDate:date_start options:0];
        
        end_date = [Utils getDateString:date_end :DATE_DATE];
        end_time = @"23:59";
    }
    
    
    NSString* tz = [Setting getTimezone];
    
    NSString* strCategory = @"";
    for (NSString * categoryID in arrCategory) {
        strCategory  = [strCategory stringByAppendingFormat:@"&category[]=%@", categoryID];
    }
    
    CLLocationCoordinate2D userCoordinate = [UserLocationManager sharedInstance].currentLocation.coordinate;

    int radius = [Setting getRadius];
    int pins = [Setting getNumberOfPins];
    
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/all_pins?search=%@&lat=%f&lng=%f&radius=%d&pins=%d&start_date=%@&end_date=%@&start_time=%@&end_time=%@&tz=%@&%@", search, userCoordinate.latitude, userCoordinate.longitude, radius, pins, start_date, end_date, start_time, end_time, tz, strCategory ] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
//    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/all_pins?search=%@&lat=%f&lng=%f&radius=%d&pins=%d&tz=%@&%@", search, userCoordinate.latitude, userCoordinate.longitude, radius, pins, tz, strCategory ] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"search = %@", urlString);
    
    return urlString;                           
}


+(NSString* ) getAddressURLFromLocation:(CLLocationDegrees)latitude : (CLLocationDegrees)longitude{
//    NSString *urlString = [[@"" stringByAppendingFormat:@"http://maps.google.com/maps/geo?q=%f,%f&output=json", latitude, longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString *urlString = [[@"" stringByAppendingFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%.5f,%.5f&output=json&sensor=false", latitude, longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"location url = %@", urlString);
    
    return urlString;
}
+(NSString* ) getSearchURLFromText:(NSString*) searchText{
    
    NSString *urlString = [[@"" stringByAppendingFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", searchText] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"search url = %@", urlString);
    return urlString;
}

+(NSString* ) getRatingUrl:(NSString*) pinID{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/votes/%@", pinID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Get: rating url = %@", urlString);
    
    return urlString;
}

+(NSString* ) postRatingUrl:(NSString*) userCode : (NSString*) pinID : (int) rate{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/vote/%@?pin=%@&rate=%d", userCode, pinID, rate] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Post: rating url = %@", urlString);
    
    return urlString;
}

+(NSString* ) postAddUserUrl:(NSString*) userCode : (int) userId{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/add_avenue/%@/?user=%d", userCode, userId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"postAddUserUrl => %@", urlString);
    
    return urlString;
}
+(NSString* ) postDeleteUserUrl:(NSString*) userCode : (int) userId{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/delete_avenue/%@/?user=%d", userCode, userId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"postAddUserUrl => %@", urlString);
    
    return urlString;
}

+(NSString* ) postAdd_RemovePinUrl:(NSString*) userCode : (int) pinId{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/bookmark/%@/?pin=%d", userCode, pinId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"postAddUserUrl => %@", urlString);
    
    return urlString;
}

+(NSString* ) isAvenuePinUrl:(NSString*) userCode : (int) pinId{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/is_bookmark/%@/?pin=%d", userCode, pinId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"isAvenuePinUrl => %@", urlString);
    
    return urlString;
}
+(NSString* ) isAvenueUserUrl:(NSString*) userCode : (int) userId{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/is_friend/%@/?user=%d", userCode, userId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"isAvenueUserUrl => %@", urlString);
    
    return urlString;
}
+(NSString* ) getDeletePinUrl:(NSString*) userCode : (NSString*) pinId{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/delete_pin/%@/?pin=%@", userCode, pinId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"getDeletePinUrl => %@", urlString);
    
    return urlString;
}
+(NSString* ) isReviewedUrl:(NSString*) userCode : (int) pinId{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/voted/%@/?pin=%d", userCode, pinId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"isReviewedUrl => %@", urlString);
    
    return urlString;
}


//////////////////
+ (NSString *)getPinAroundRoute:(NSMutableArray *) arrlocation
{
    
    NSString* strCategory = @"";
    for (NSMutableDictionary * dic in [Share getInstance].arrayCategory) {
        strCategory  = [strCategory stringByAppendingFormat:@"&category[]=%@", [dic objectForKey:@"id"]];
    }

    NSString * strLocation = @"";
    for (NSMutableDictionary * dic in arrlocation) {
        strLocation  = [strLocation stringByAppendingFormat:@"&latlng[]=%@,%@", [dic objectForKey:@"lat"], [dic objectForKey:@"lng"]];
    }
    
    int radius = 1;
    
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/route_pins?search=""%@%@&radius=%d",
                            strCategory, strLocation, radius] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"getPinAroundRoute : %@", urlString);
    
    return urlString;
}


#pragma mark ------------- date ------
+(NSDate*) dateFromString:(NSString*) string : (int) option{
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    
    if (option == DATE_DATE) {
        [dateFormat setDateFormat:@"yyy-MM-dd"];
    } else if (option == DATE_TIME) {
        [dateFormat setDateFormat:@"HH:mm"];
    } else {
        [dateFormat setDateFormat:@"yyy-MM-dd HH:mm"];
    }
    
    return [dateFormat dateFromString: string];
    
} 
+(NSString*) getDateString:(NSDate*) date : (int) option{
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    
    if (option == DATE_DATE) {
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
    } else if (option == DATE_TIME) {
        [dateFormat setDateFormat:@"HH:mm"];
    } else {
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    
    NSString* strDate = [dateFormat stringFromDate: date];
    return strDate;
}

+(NSString*)stringFromFileNamed:(NSString*)name{
	NSString* result = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil] encoding:NSUTF8StringEncoding error:nil];
	return result;
}


#pragma mark -------- Chat -----
+ (NSString *)getChatSendText
{
    NSString *urlString = [[CHAT_URL stringByAppendingString:@"messages/create"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    return urlString;
}

+ (NSString *) getPublishListURL
{
    NSString *urlString = [[CHAT_URL stringByAppendingString:@"messages/list.json"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return urlString;
}

+ (NSString *) getUserURL : (NSString*) _userId
{
    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/uinfo/%@", _userId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    return urlString;
}

+ (NSString *)getOnlineUsersUrl :(NSString*) _chatcode
{
    NSString *urlString = [[CHAT_URL stringByAppendingFormat:@"users/list/%@.json", _chatcode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSLog(@"users url : %@", urlString);
    
    return urlString;
}

+ (NSString *)GetStartPinChat
{
//   http://pinave.com/request/private_uinfo/{auth_code}

    NSString *auth_code = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginCode"];

    NSString *urlString = [[SERVER_URL stringByAppendingFormat:@"request/private_uinfo/%@", auth_code] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"GetStartPinChat => %@", urlString);
    
    return urlString;
}

+ (NSString *)getPrivateChatUrl :(NSString*) otherId : (NSString*) _userChatcode
{
    
    NSString *urlString = [[CHAT_URL stringByAppendingFormat:@"messages/private/%@/%@.json", otherId, _userChatcode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"private chat Url : %@", urlString);
    
    return urlString;
}

+ (NSString *)getOtherChatIdUrl :(NSString*) curChatCode : (NSString*) othPubCode
{
    NSString *urlString = [[CHAT_URL stringByAppendingFormat:@"send_message_form/%@/%@.json", curChatCode, othPubCode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"getOtherChatIdUrl => %@", urlString);
    
    return urlString;
}

+ (NSString *) getReviewURL:(int) pinId
{
    NSString *urlString = [[CHAT_URL stringByAppendingFormat:@"comments/%d.json", pinId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"getReviewUrl => %@", urlString);
    return urlString;
}

+ (NSString *) sendReviewUrl
{
    NSString *urlString = [[CHAT_URL stringByAppendingString:@"messages/comment.json"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return urlString;
}


+(NSString *) getTimeFilter: (NSString *) _strTime
{
    if (_strTime == nil || [_strTime isEqualToString:@"null"]) {
        return @"";
    }
    
    // 2012-07-23T02:48:56Z
    NSString * _date = [_strTime substringWithRange:NSMakeRange(0, 10)];
    NSString * _time = [_strTime substringWithRange:NSMakeRange(11, 8)];
    
    NSLog(@"old time = %@", _time);
    int SERVER_TIMEZONE = 0;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:SERVER_TIMEZONE*3600]];
    
    NSDate *lastOnlineDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", _date, _time]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                               fromDate:lastOnlineDate];
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day       = [components day];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
//    NSInteger second = [components second];
    
//    NSString *convert = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
    
    NSString * convert = @"";
    
    NSString * sMonth = @"";
    switch (month) {
        case 1:
            sMonth = @"Jan";   break;
        case 2:
            sMonth = @"Feb";   break;
        case 3:
            sMonth = @"Mar";   break;
        case 4:
            sMonth = @"Apr";   break;
        case 5:
            sMonth = @"May";   break;
        case 6:
            sMonth = @"Jun";   break;
        case 7:
            sMonth = @"Jul";   break;
        case 8:
            sMonth = @"Aug";   break;
        case 9:
            sMonth = @"Sep";   break;
        case 10:
            sMonth = @"Oct";   break;
        case 11:
            sMonth = @"Nov";   break;
        case 12:
            sMonth = @"Dec";   break;
            
        default:
            break;
    }
    
    convert = [NSString stringWithFormat:@"%02d %@ %02d@%02d:%02d", day, sMonth, year, hour, minute];
    
    NSLog(@"convert = %@", convert);
    
    return convert;
}

@end
