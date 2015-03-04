//
//  Notification.h
//  NEP
//
//  Created by Gold Luo on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject

+ (void) setNotify: (BOOL) _bSet;
+ (BOOL) getNotify;

+ (void) setDistance: (int) _distance;
+ (int) getDistance;

+ (void) setDate: (NSString*) _date;
+ (NSString*) getDate;

+ (void) setMinute: (int) _minute;
+ (int) getMinute;


+ (void) setCategory:(NSMutableArray *)_category;
+ (NSMutableArray*) getCategory;

+ (void) setDuration: (int) _duration;
+ (int) getDuration;


/////////////////
+ (BOOL) isChat;
+ (void) setChatAlarm: (NSString*) _chatId;
+ (NSMutableArray *) getChatAlarm;

@end
