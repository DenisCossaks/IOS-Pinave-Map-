//
//  Setting.h
//  NEP
//
//  Created by Gold Luo on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Setting : NSObject

+ (void) setStartDate: (NSString*) start_time;
+ (NSString*) getStartDate;

+ (void) setEndDate: (NSString*) end_time;
+ (NSString*) getEndDate;

+ (void) setUnit: (int) _unit;
+ (int) getUnit;

+ (void) setRadius: (CLLocationDegrees) _radius;
+ (CLLocationDegrees) getRadius;

+ (void) setNumberOfPins: (int) _pins;
+ (int) getNumberOfPins;

+ (void) setTimezone: (NSString*) timezone;
+ (NSString*) getTimezone;

+ (void) setMapMode: (int) _mode;
+ (int)  getMapMode;

+ (void) setCategory: (NSMutableArray*) _category;
+ (NSMutableArray*) getCategory;


@end
