//
//  PinsPool.m
//  NEP
//
//  Created by Dandong3 Sam on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PinsPool.h"
#import "Utils.h"
#import "UsersPool.h"
#import "JSON.h"

static PinsPool *global_pool = nil;

@implementation PinsPool

@synthesize allPinList;
@synthesize isGotAllPin;

+ (PinsPool *)pool
{
    if (!global_pool) {
        global_pool = [[PinsPool alloc] init];
    }
    
    return global_pool;
}

- (id)init
{
    if ((self = [super init])) {
        isGotAllPin = NO;
        [NSThread detachNewThreadSelector:@selector(getAllPinThread) toTarget:self withObject:nil];
    }
    
    return self;
}

- (void)getAllPinThread
{
    @autoreleasepool {
        while (![UsersPool pool].isGotUsers) {
            [NSThread sleepForTimeInterval:0.1];
        }
        
        NSMutableDictionary *allPinsForUser = [NSMutableDictionary dictionary];
        for (NSDictionary *userItem in [UsersPool pool].userList) {
            NSMutableArray *pinItemForUser = [NSMutableArray array];
            
            NSString *user_id = [userItem objectForKey:@"id"];
            
            NSString *urlString = [Utils getPinForUserUrl:user_id];
            NSString *pinResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
            
            NSLog(@"pinResult = %@", pinResult);
            
            SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
            id result = [JSonParser objectWithString:pinResult];
            NSDictionary *forCategory = [result objectForKey:@"categories"];
            NSArray *pinForCategory = [forCategory allValues];
            for (NSDictionary *categoryItem in pinForCategory) {
                NSArray *pins = [categoryItem objectForKey:@"pins"];
                for (NSDictionary *pinItem in pins) {
                    NSMutableDictionary *pinArchive = [NSMutableDictionary dictionaryWithDictionary:pinItem];

                    NSString* strFull = [pinArchive objectForKey:@"full_address"];
                    if (strFull == nil || strFull.length < 1) {
                        strFull = [NSString stringWithFormat:@"%@ %@ %@", [pinArchive objectForKey:@"address"], [pinArchive objectForKey:@"city"], [pinArchive objectForKey:@"country"]];
                        
                        [pinArchive setObject:strFull forKey:@"full_address"];
                    }

                    [pinItemForUser addObject:pinArchive];
                }
            }
            
            [allPinsForUser setObject:pinItemForUser forKey:user_id];
        }
        
        self.allPinList = [NSDictionary dictionaryWithDictionary:allPinsForUser];
        
//        NSLog(@"self.allPinList = %@", self.allPinList);
        isGotAllPin = YES;
    }
}

- (void)getPinImage:(NSMutableDictionary *)pinItem
{
    [NSThread detachNewThreadSelector:@selector(getPinImageThread:) toTarget:self withObject:pinItem];
}

- (void)getPinImageThread:(NSMutableDictionary *)pinItem
{
    @autoreleasepool {
        NSString *imageUrl = [[pinItem objectForKey:@"image"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%@", imageUrl);
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        UIImage *iconImg = [UIImage imageWithData:imageData];
        if (iconImg) {
            [pinItem setObject:iconImg forKey:@"pin_image"];
        } else {
            [pinItem setObject:[NSNull null] forKey:@"pin_image"];
        }
    }
}

@end
