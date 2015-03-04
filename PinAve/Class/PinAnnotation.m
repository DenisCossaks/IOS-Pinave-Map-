//
//  PinAnnotation.m
//  NEP
//
//  Created by Dandong3 Sam on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PinAnnotation.h"

@implementation PinAnnotation

@synthesize coordinate = coordinate_;
@synthesize title = title_;
@synthesize subtitle = subtitle_;
@synthesize pinInfo = _pinInfo;
@synthesize pinIndex;

- (id)initWithPinInfo:(NSMutableDictionary *)pinDic
{
    if ((self = [super init])) {
        self.pinInfo = pinDic;
        self.coordinate = CLLocationCoordinate2DMake([[pinDic objectForKey:@"lat"] doubleValue], [[pinDic objectForKey:@"lng"] doubleValue]);
        self.title = [pinDic objectForKey:@"title"];
        self.subtitle = [pinDic objectForKey:@"full_address"];
    }
    
    return self;
}
/*
- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([[self.pinInfo objectForKey:@"lat"] doubleValue], [[self.pinInfo objectForKey:@"lng"] doubleValue]);
}

- (NSString *)title
{
    return [self.pinInfo objectForKey:@"title"];
}

- (NSString *)subtitle
{
    return [self.pinInfo objectForKey:@"address"];
}
*/
@end
