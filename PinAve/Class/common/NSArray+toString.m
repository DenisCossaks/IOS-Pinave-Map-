//
//  NSArray+toString.m
//  BabyName
//
//  Created by RamotionMac on 7/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSArray+toString.h"


@implementation NSArray (toString)

- (NSString*)toString {
    NSString* result = @"";
    
    for (NSString* currStr in self) {
        result = [result stringByAppendingString:currStr];
        
        // add comma if this is not last member
        BOOL isLast = [self indexOfObject:currStr] == [self count] - 1;
        if (! isLast) {
            result = [result stringByAppendingString:@", "];
        }
    }
    
    return result;
}

@end
