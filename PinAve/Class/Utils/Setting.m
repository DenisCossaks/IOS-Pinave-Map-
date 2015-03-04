//
//  Setting.m
//  NEP
//
//  Created by Gold Luo on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Setting.h"

@implementation Setting

static NSString *kSettingRadius  = @"setting_radius";
static NSString *kSettingPins = @"setting_pins";
static NSString *kSettingStartDate = @"setting_startdate";
static NSString *kSettingEndDate = @"setting_enddate";
static NSString *kSettingTimezone = @"setting_imezone";
static NSString *kSettingMapMode = @"setting_mapmode";
static NSString *kSettingCategory = @"setting_category";
static NSString *kSettingUnit = @"setting_unit";

+ (void) setUnit: (int) _unit
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setObject:[NSNumber numberWithInt:_unit] forKey:kSettingUnit];
    [userStore synchronize];
}

+ (int) getUnit
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    int unit = [userStore doubleForKey:kSettingUnit];

    // o - km         1 - mile
    return unit;
}

+ (void) setRadius: (CLLocationDegrees) _radius
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setObject:[NSNumber numberWithDouble:_radius] forKey:kSettingRadius];
    [userStore synchronize];
    
}
+ (CLLocationDegrees) getRadius
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    CLLocationDegrees radius = [userStore doubleForKey:kSettingRadius];
    if (radius == 0) {
        radius = 500;
    }
    
    return radius;
}

+ (void) setNumberOfPins: (int) _pins
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setObject:[NSNumber numberWithInt:_pins] forKey:kSettingPins];
    [userStore synchronize];
}    
+ (int) getNumberOfPins
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    int pins = [userStore integerForKey:kSettingPins];
    
    if (pins == 0) {
        pins = 200;
        [self setNumberOfPins:pins];
    }
    
    return pins;
}

+ (void) setTimezone: (NSString*) timezone
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setObject:timezone forKey:kSettingTimezone];
    [userStore synchronize];
    
}
+ (NSString*) getTimezone
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    NSString* timezone = [userStore stringForKey:kSettingTimezone];
    
    if (timezone == nil) {
//        NSString *zone = [[NSTimeZone systemTimeZone] abbreviation];
//        
//        NSLog(@"user time zone = %@", zone);
        timezone = @"Australia/Melbourne";
        
        [self setTimezone:timezone];
    }
    
    return timezone;
}

+ (void) setMapMode: (int) _mode
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setObject:[NSNumber numberWithInt:_mode] forKey:kSettingMapMode];
    [userStore synchronize];
}    
+ (int) getMapMode
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    int mode = [userStore integerForKey:kSettingMapMode];    
    return mode;
}

+ (void) setStartDate: (NSString*) start_time
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setObject:start_time forKey:kSettingStartDate];
    
    [userStore synchronize];
    
}
+ (NSString*) getStartDate
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    NSString* startTime = [userStore stringForKey:kSettingStartDate];
    
    if (startTime == nil) {
        startTime = [Utils getDateString:[NSDate date] : DATE_FULL];
        
        [self setStartDate:startTime];
    }
    return startTime;
}


+ (void) setEndDate: (NSString*) end_time
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setObject:end_time forKey:kSettingEndDate];
    [userStore synchronize];
    
}
+ (NSString*) getEndDate
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    NSString* endTime = [userStore stringForKey:kSettingEndDate];
    
    if (endTime == nil || endTime.length < 1) {
        NSString * start = [self getStartDate];
        NSDate *start_date = [Utils dateFromString:start :DATE_FULL];
        
//        NSDate * end_date = [start_date dateByAddingTimeInterval:3600 * 4];
       
        NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
        [dateComponents setMonth:1];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDate* end_date = [calendar dateByAddingComponents:dateComponents toDate:start_date options:0];
        
        
        endTime = [Utils getDateString:end_date :DATE_FULL];
      
        
        [self setEndDate:endTime];
    }

    return endTime;
}

+ (void) setCategory:(NSMutableArray *)_category 
{
    [[NSUserDefaults standardUserDefaults] setInteger:[_category count] forKey:kSettingCategory];
    
    for (int i = 0; i < [_category count]; i ++) {
        NSNumber *opt = (NSNumber*)[_category objectAtIndex:i];
        
        
        [[NSUserDefaults standardUserDefaults] setInteger:[opt integerValue] forKey:[NSString stringWithFormat:@"%@_%d", kSettingCategory, i]];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];

}
+ (NSMutableArray*) getCategory
{
    NSMutableArray * arrCategory = [[NSMutableArray alloc] initWithCapacity:10];
    int _count = [[NSUserDefaults standardUserDefaults] integerForKey:kSettingCategory];
    for (int i = 0; i < _count; i ++) {
        NSInteger opt = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_%d", kSettingCategory, i]];
        [arrCategory addObject:[NSNumber numberWithInteger:opt]];
    }
    
    return arrCategory;
}
@end
