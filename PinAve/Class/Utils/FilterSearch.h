//
//  FilterSearch.h
//  NEP
//
//  Created by Gold Luo on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterSearch : NSObject


+ (void) setStartDate: (NSString*) start_time;
+ (NSString*) getStartDate;

+ (void) setEndDate: (NSString*) end_time;
+ (NSString*) getEndDate;

+ (void) setCountry: (NSString*) _country;
+ (NSString*) getCountry;

+ (void) setCity: (NSString*) _city;
+ (NSString*) getCity;

//+ (void) setTimezone: (NSString*) timezone;
//+ (NSString*) getTimezone;

+ (void) setCategory: (NSMutableArray*) _category;
+ (NSMutableArray*) getCategory;

+ (int) getTimeOption;
+ (void) setTimeOption :(int) _time;


@end
