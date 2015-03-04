//
//  UserPins.h
//  NEP
//
//  Created by Yuan Luo on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserPins : NSObject

@property (strong, nonatomic) NSMutableArray *allPinListForUser;
@property (atomic) BOOL isGotAllPin;

+ (UserPins *)pool;

- (void) start;
- (void) start :(NSString*) url;

@end
