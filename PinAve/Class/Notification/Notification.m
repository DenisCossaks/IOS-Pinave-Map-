//
//  Notification.m
//  NEP
//
//  Created by Gold Luo on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Notification.h"

@implementation Notification

static NSString *kNotiSet  = @"Noti_set";
static NSString *kNotiDistance  = @"Noti_distance";
static NSString *kNotiDate  = @"Noti_date";
static NSString *kNotiCategory  = @"Noti_category";
static NSString *kNotiMinute  = @"Noti_minute";
static NSString *kNotiDuration  = @"Noti_duration";

static NSString *kMsgAlarm  = @"Chat_notification";

+ (void) setNotify: (BOOL) _bSet
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setBool:_bSet forKey:kNotiSet];
    [userStore synchronize];
}

+ (BOOL) getNotify
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    
    BOOL bSet = [userStore boolForKey:kNotiSet];
    
    return bSet;
}


+ (void) setDistance: (int) _distance
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setObject:[NSNumber numberWithInt:_distance] forKey:kNotiDistance];
    [userStore synchronize];
}

+ (int) getDistance
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    int  distance = [userStore integerForKey:kNotiDistance];

    if (distance == 0) { // default
        distance = 2;
        [self setDistance:distance];
    }
    
    return distance;
}

+ (void) setDate: (NSString*) _date
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setObject:_date forKey:kNotiDate];
    [userStore synchronize];
}

+ (NSString*) getDate
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    NSString * date = [userStore stringForKey:kNotiDate];
    
    if (date == nil) {
        NSDate * cur_Date = [NSDate date];
        date = [Utils getDateString:cur_Date :DATE_FULL];
        [self setDate:date];
    }

    return date;
}


+ (void) setMinute: (int) _minute
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setObject:[NSNumber numberWithInt:_minute] forKey:kNotiMinute];
    [userStore synchronize];
}

+ (int) getMinute
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    int  minute = [userStore integerForKey:kNotiMinute];
    
    if (minute == 0) { // default
        minute = 15;
        [self setMinute:minute];
    }
    
    return minute;
}

+ (void) setDuration: (int) _duration
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setObject:[NSNumber numberWithInt:_duration] forKey:kNotiDuration];
    [userStore synchronize];
}

+ (int) getDuration
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    int  minute = [userStore integerForKey:kNotiDuration];
    
    if (minute == 0) { // default
        minute = 2;
        [self setDuration:minute];
    }
    
    return minute;
}


+ (void) setCategory:(NSMutableArray *)_category 
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    
    [userStore setInteger:[_category count] forKey:kNotiCategory];
    
    for (int i = 0; i < [_category count]; i ++) {
        NSDictionary * _dic = [_category objectAtIndex:i];
        
        NSString * category_id = [_dic objectForKey:@"id"];
        [userStore setObject:category_id forKey:[NSString stringWithFormat:@"%@_%d_id", kNotiCategory, i]];
        
        BOOL isSelected = [[_dic objectForKey:@"selected"] boolValue];
        [userStore setBool:isSelected forKey:[NSString stringWithFormat:@"%@_%d_sel", kNotiCategory, i]];
    }
    
    [userStore synchronize];
}

+ (NSMutableArray*) getCategory
{
    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray * arrCategory;
    int _count = [userStore integerForKey:kNotiCategory];
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
        NSString *category_id = [userStore objectForKey:[NSString stringWithFormat:@"%@_%d_id", kNotiCategory, i]];
        BOOL    isSelected = [userStore boolForKey:[NSString stringWithFormat:@"%@_%d_sel", kNotiCategory, i]];
        
        NSMutableDictionary * _dic = [[NSMutableDictionary alloc] initWithCapacity:10];
        [_dic setObject:category_id forKey:@"id"];
        [_dic setObject:[NSNumber numberWithBool:(isSelected)] forKey:@"selected"];
        
        [arrCategory addObject:_dic];
    }
    
    return arrCategory;
}

+ (BOOL) isChat 
{
    if([[self getChatAlarm] count] > 0 ){
        return YES;
    }
    return NO;
}

+ (void) setChatAlarm: (NSString*) _chatId
{
    NSMutableArray * arry = [self getChatAlarm];

    [arry addObject:_chatId];

    NSUserDefaults *userStore = [NSUserDefaults standardUserDefaults];
    [userStore setObject:arry forKey:kMsgAlarm];
    [userStore synchronize];
}

+ (NSMutableArray *) getChatAlarm
{
    NSMutableArray * arrIds = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kMsgAlarm]];
    
    return arrIds;
}


@end
