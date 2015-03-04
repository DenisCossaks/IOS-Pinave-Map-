//
//  FilterSearch.m
//  NEP
//
//  Created by Gold Luo on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FilterSearch.h"

#import "Setting.h"


@implementation FilterSearch

static NSString *kFilterStartDate = @"filter_startdate";
static NSString *kFilterEndDate = @"filter_enddate";
static NSString *kFilterCountry = @"filter_country";
static NSString *kFilterCity = @"filter_city";
static NSString *kFilterTimezone = @"filter_timezone";
static NSString *kFilterCategory = @"filter_category";
static NSString *kFilterTime = @"filter_time";

+ (void) setStartDate: (NSString*) start_time
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setObject:start_time forKey:kFilterStartDate];
    [userStore synchronize];
    
}
+ (NSString*) getStartDate
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    NSString* startTime = [userStore stringForKey:kFilterStartDate];
    
    if (startTime == nil) {
        startTime = [Setting getStartDate];
        
        [self setStartDate:startTime];
    }
    
    return startTime;
}

+ (void) setEndDate: (NSString*) end_time
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setObject:end_time forKey:kFilterEndDate];
    [userStore synchronize];
    
}
+ (NSString*) getEndDate
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    NSString* endTime = [userStore stringForKey:kFilterEndDate];

    if (endTime == nil) {
//        NSString * start = [self getStartDate];
//        NSDate *start_date = [Utils dateFromString:start :DATE_FULL];
//        
//        NSDate * end_date = [start_date dateByAddingTimeInterval:3600 * 4];
//        NSString * endTime = [Utils getDateString:end_date :DATE_FULL];
        NSString * endTime = [Setting getEndDate];
        
        [self setEndDate:endTime];
    }
    
    return endTime;
}

+ (void) setCity:(NSString *)_city
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setObject:_city forKey:kFilterCity];
    [userStore synchronize];
    
}
+ (NSString*) getCity
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    NSString* city = [userStore stringForKey:kFilterCity];
    
    return city;
}

+ (void) setCountry:(NSString *)_country
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setObject:_country forKey:kFilterCountry];
    [userStore synchronize];
    
}
+ (NSString*) getCountry
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    NSString* country = [userStore stringForKey:kFilterCountry];
    
    return country;
}

/*
+ (void) setTimezone: (NSString*) timezone
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setObject:timezone forKey:kFilterTimezone];
    [userStore synchronize];
    
}
+ (NSString*) getTimezone
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    NSString* timezone = [userStore stringForKey:kFilterTimezone];
    
    if (timezone == nil) {
        [Setting getTimezone];
    }
    
    return timezone;
}
*/

+ (void) setCategory:(NSMutableArray *)_category 
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    
    [userStore setInteger:[_category count] forKey:kFilterCategory];

    for (int i = 0; i < [_category count]; i ++) {
        NSDictionary * _dic = [_category objectAtIndex:i];
        
        NSString * category_id = [_dic objectForKey:@"id"];
        [userStore setObject:category_id forKey:[NSString stringWithFormat:@"%@_%d_id", kFilterCategory, i]];
        
        BOOL isSelected = [[_dic objectForKey:@"selected"] boolValue];
        [userStore setBool:isSelected forKey:[NSString stringWithFormat:@"%@_%d_sel", kFilterCategory, i]];
    }
    
    
    [userStore synchronize];
}


+ (NSMutableArray*) getCategory
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];

    NSMutableArray * arrCategory;
    int _count = [userStore integerForKey:kFilterCategory];
    if (_count == 0) {
        arrCategory = [[NSMutableArray alloc] initWithArray:[Share getInstance].arrayCategory];
        for (NSMutableDictionary * item in arrCategory) {
            [item setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
        }
        [self setCategory:arrCategory];
    } else {
        arrCategory = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    for (int i = 0; i < _count; i ++) {
        NSString *category_id = [userStore objectForKey:[NSString stringWithFormat:@"%@_%d_id", kFilterCategory, i]];
        BOOL    isSelected = [userStore boolForKey:[NSString stringWithFormat:@"%@_%d_sel", kFilterCategory, i]];
        
        NSMutableDictionary * _dic = [[NSMutableDictionary alloc] initWithCapacity:10];
        [_dic setObject:category_id forKey:@"id"];
        [_dic setObject:[NSNumber numberWithBool:(isSelected)] forKey:@"selected"];
        
        [arrCategory addObject:_dic];
    }
    
    return arrCategory;
}

+ (int) getTimeOption
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    int _time = [userStore integerForKey:kFilterTime];
    
    return _time;
}
+ (void) setTimeOption :(int) _time
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setInteger:_time forKey:kFilterTime];
    [userStore synchronize];
}
@end
