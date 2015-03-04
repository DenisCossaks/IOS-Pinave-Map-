//
//  Global.m
//  LocationWeather
//
//  Created by Yuan Luo on 4/24/13.
//  Copyright (c) 2013 Sun Zhe. All rights reserved.
//

#import "Global.h"

static Global* instance = nil;


@implementation Global

+(Global*) Instance
{
    if (instance == nil) {
        instance = [[Global alloc] init];
    }
    
    return instance;
}

+ (BOOL) isIPhone5
{
    if ((![UIApplication sharedApplication].statusBarHidden && (int)[[UIScreen mainScreen] applicationFrame].size.height == 548 )|| ([UIApplication sharedApplication].statusBarHidden && (int)[[UIScreen mainScreen] applicationFrame].size.height == 568))
        return YES;
    
    return NO;
}


@end
