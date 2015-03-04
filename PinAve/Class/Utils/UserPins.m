//
//  UserPins.m
//  NEP
//
//  Created by Yuan Luo on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "UserPins.h"
#import "PinsPool.h"
#import "Utils.h"
#import "JSON.h"

static UserPins *global_pool = nil;

@implementation UserPins

@synthesize allPinListForUser;
@synthesize isGotAllPin;

+ (UserPins *)pool
{
    if (!global_pool) {
        global_pool = [[UserPins alloc] init];
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

- (void) start {
    isGotAllPin = NO;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * userId = [defaults objectForKey:@"loginId"];

    NSString *urlString = [Utils getPinForUserUrl:userId];
    [NSThread detachNewThreadSelector:@selector(getAllPinThread:) toTarget:self withObject:urlString];
}

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
        
        SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
        id result = [JSonParser objectWithString:pinResult];
        
 
        self.allPinListForUser = [[NSMutableArray alloc] initWithCapacity:10];
        
        NSDictionary *forCategory = [result objectForKey:@"categories"];
        NSArray *pinForCategory = [forCategory allValues];
        for (NSDictionary *categoryItem in pinForCategory) {
            NSArray *pins = [categoryItem objectForKey:@"pins"];
            
//            NSLog(@"user Pins = %@", pins);
            
            for (NSDictionary *pinItem in pins) {
                NSMutableDictionary *pinArchive = [NSMutableDictionary dictionaryWithDictionary:pinItem];
                
                NSString* strFull = [pinArchive objectForKey:@"full_address"];
                if (strFull == nil || strFull.length < 1) {
                    strFull = [NSString stringWithFormat:@"%@ %@ %@", [pinArchive objectForKey:@"address"], [pinArchive objectForKey:@"city"], [pinArchive objectForKey:@"country"]];
                    
                    [pinArchive setObject:strFull forKey:@"full_address"];
                }

//                [NSThread detachNewThreadSelector:@selector(getPinImage:) toTarget:self withObject:pinArchive];
                [self performSelectorOnMainThread:@selector(getPinImage:) withObject:pinArchive waitUntilDone:NO];

                
                [self.allPinListForUser addObject:pinArchive];
            }
        }
            
//        NSLog(@"User Pins = %@", self.allPinListForUser);
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
