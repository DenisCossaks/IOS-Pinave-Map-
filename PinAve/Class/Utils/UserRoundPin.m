//
//  UserRoundPin.m
//  NEP
//
//  Created by Yuan Luo on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "UserRoundPin.h"
#import "PinsPool.h"
#import "Utils.h"
#import "JSON.h"

static UserRoundPin *global_pool = nil;

@implementation UserRoundPin

@synthesize allPinListForUser;
@synthesize isGotAllPin;

+ (UserRoundPin *)pool
{
    if (!global_pool) {
        global_pool = [[UserRoundPin alloc] init];
    }
    
    return global_pool;
}

- (id)init
{
    if ((self = [super init])) {
//        isGotAllPin = NO;
//        [NSThread detachNewThreadSelector:@selector(getAllPinThread) toTarget:self withObject:nil];
    }
    
    return self;
}

/*
- (void) start {
    isGotAllPin = NO;

    NSString *urlString = [Utils getPinForUser];
    [NSThread detachNewThreadSelector:@selector(getAllPinThread:) toTarget:self withObject:urlString];
}
*/

- (void) start :(NSString*) url
{
    isGotAllPin = NO;
    [NSThread detachNewThreadSelector:@selector(getAllPinThread:) toTarget:self withObject:url];
}


- (void)getAllPinThread:(NSString*) url
{
    @autoreleasepool
    {

        NSString *pinResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
        
//        NSLog(@"pinResult surround USER = %@", pinResult);
        
        SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
        id result = [JSonParser objectWithString:pinResult];
        
 
        self.allPinListForUser = [[NSMutableArray alloc] initWithCapacity:10];
        
        NSDictionary *forCategory = [result objectForKey:@"categories"];
        NSArray *pinForCategory = [forCategory allValues];
        for (NSDictionary *categoryItem in pinForCategory) {
            NSArray *pins = [categoryItem objectForKey:@"pins"];
            
//            NSLog(@"user Pins = %@", pins);
            
            for (NSMutableDictionary *pinItem in pins) {
                
                NSString* strFull = [pinItem objectForKey:@"full_address"];
                if (strFull == nil || strFull.length < 1) {
                    strFull = [NSString stringWithFormat:@"%@ %@ %@", [pinItem objectForKey:@"address"], [pinItem objectForKey:@"city"], [pinItem objectForKey:@"country"]];
                    
                    [pinItem setObject:strFull forKey:@"full_address"];
                }
                
                NSMutableDictionary *pinArchive = [NSMutableDictionary dictionaryWithDictionary:pinItem];
                
//                [NSThread detachNewThreadSelector:@selector(getPinImage:) toTarget:self withObject:pinArchive];
//                [self performSelectorOnMainThread:@selector(getPinImage:) withObject:pinArchive waitUntilDone:NO];

                
                [self.allPinListForUser addObject:pinArchive];
            }
        }
            
//        NSLog(@"pinResult surround USER= %@", self.allPinListForUser);
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
