//
//  UserRoundPin.h
//  NEP
//
//  Created by Yuan Luo on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserRoundPin : NSObject

@property (strong, nonatomic) NSMutableArray *allPinListForUser;
@property (atomic) BOOL isGotAllPin;

+ (UserRoundPin *)pool;

- (void) start;
- (void) start :(NSString*) url;

@end
