//
//  Share.m
//  PinAve
//
//  Created by Gold-iron on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Share.h"


@implementation Share

@synthesize arrayCategory;
@synthesize arrayMyPin;

@synthesize allUsers;
@synthesize dicUserInfo;

@synthesize allAvenueUsers;
@synthesize allAvenuePins;
@synthesize userChatInfo;

static Share *instance = nil;

+ (Share*) getInstance {
    if (instance == nil) {
        instance = [[Share alloc] init];
        
        [instance initVal];
    }
    
    return instance;
}


- (void) initVal
{
    arrayCategory = [[NSMutableArray alloc] init];
    arrayMyPin = [[NSArray alloc] init];
    dicUserInfo = [[NSMutableDictionary alloc] init];
    allUsers = [[NSArray alloc] init];
    
    allAvenueUsers = [[NSMutableArray alloc] init];
    allAvenuePins = [[NSMutableArray alloc] init];
//    userChatInfo = [[NSDictionary alloc] init];
}


- (NSString*) getCategoryTitle:(int) _categoryId
{
    for (NSMutableDictionary * item in self.arrayCategory) {
        
        int _id = [[item objectForKey:@"id"] intValue];
        if (_id == _categoryId) {
            return [item objectForKey:@"name"];
        }
    }
    return @"";
}

+ (UIImage*) getCategoryImageWithID:(NSString*) _categoryID
{
    NSString * title = [[Share getInstance] getCategoryTitle:[_categoryID intValue]];
    
    return [self getCategoryImageName:title];
}

+ (UIImage*) getCategoryImageName:(NSString*) category_name
{
    UIImage * iconImg = nil;
    
    if ([category_name isEqualToString:@"Accommodation"]) {
        iconImg = [UIImage imageNamed:@"accom.png"];
    } else if ([category_name isEqualToString:@"Cars & Bikes"]) {
        iconImg = [UIImage imageNamed:@"car.png"];
    } else if ([category_name isEqualToString:@"Events & Parties"]) {
        iconImg = [UIImage imageNamed:@"party.png"];
    } else if ([category_name isEqualToString:@"Food & Drinks"]) {
        iconImg = [UIImage imageNamed:@"food.png"];
    } else if ([category_name isEqualToString:@"Garage Sales"]) {
        iconImg = [UIImage imageNamed:@"garage.png"];
    } else if ([category_name isEqualToString:@"Health & Beauty"]) {
        iconImg = [UIImage imageNamed:@"beauty.png"];
    } else if ([category_name isEqualToString:@"Homely Made"]) {
        iconImg = [UIImage imageNamed:@"homely.png"];
    } else if ([category_name isEqualToString:@"Jobs"]) {
        iconImg = [UIImage imageNamed:@"Jobs.png"];
    } else if ([category_name isEqualToString:@"Leisure"]) {
        iconImg = [UIImage imageNamed:@"leisure.png"];
    } else if ([category_name isEqualToString:@"Parking"]) {
        iconImg = [UIImage imageNamed:@"parking.png"];
    } else if ([category_name isEqualToString:@"On Sale!"]) {
        iconImg = [UIImage imageNamed:@"sale.png"];
    } else if ([category_name isEqualToString:@"Wanted"]) {
        iconImg = [UIImage imageNamed:@"wanted.png"];
    } else if ([category_name isEqualToString:@"Daily Deals"]) {
        iconImg = [UIImage imageNamed:@"deals.png"];
    } else if ([category_name isEqualToString:@"I'll Pay for"]) {
        iconImg = [UIImage imageNamed:@"pay.png"];
    }

    return iconImg;
}

/////////////////////////////////////
- (BOOL) getFirstApp {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"firstapp"];;
}
- (void) setFirstApp {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstapp"];
}



/***********************************************************************************************
 *
 *  Key algorithm for Login and Register
 *
 ************************************************************************************************/

#import <CommonCrypto/CommonDigest.h>

+ (NSString *)md5HexDigest:(NSString *)input
{
    const char *str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", result[i]];
    }
    
    return ret;
}
+ (NSString *)randomAlphanumericStringWithLength:(NSInteger)length
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i = 0; i < length; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }
    
    return randomString;
}

+ (NSString*) generateKey:(NSString*) firstName
                 lastName:(NSString*) lastName
                    email:(NSString*) email
                     fbid:(NSString*) fbID
{
    NSMutableString * string = [NSMutableString string];
    
    [string appendString:firstName];
    [string appendString:lastName];
    [string appendString:email];
    [string appendString:fbID];
    
    NSLog(@"string = %@", string);
    
    NSMutableString * key = [NSMutableString string];
    
    for (int i = 0 ; i < string.length ; i ++) {
        NSString * chr = [string substringWithRange:NSMakeRange(i, 1)];
        
        unichar ord = [chr characterAtIndex:0];
        int value = ord % string.length;
        
        [key appendString:[NSString stringWithFormat:@"%d%@", value, [string substringWithRange:NSMakeRange(value, 1)]]];
    }
    
    NSLog(@"key = %@", key);
    
    NSMutableString * covKey = [NSMutableString string];
    [covKey appendString:[self randomAlphanumericStringWithLength:10]];
    [covKey appendString:[self md5HexDigest:key]];
    [covKey appendString:[self randomAlphanumericStringWithLength:5]];
    
    NSLog(@"covKey = %@", covKey);
    
    return covKey;
}

@end
