//
//  PinsPool.h
//  NEP
//
//  Created by Dandong3 Sam on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PinsPool : NSObject

@property (strong, nonatomic) NSDictionary *allPinList;
@property (atomic) BOOL isGotAllPin;

+ (PinsPool *)pool;

@end
