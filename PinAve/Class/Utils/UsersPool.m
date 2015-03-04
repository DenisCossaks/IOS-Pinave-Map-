//
//  UsersPool.m
//  NEP
//
//  Created by Dandong3 Sam on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UsersPool.h"
#import "Utils.h"

static UsersPool *global_pool = nil;

@implementation UsersPool

@synthesize userList;
@synthesize isGotUsers;

+ (UsersPool *)pool
{
    if (!global_pool) {
        global_pool = [[UsersPool alloc] init];
    }
    
    return global_pool;
}

- (id)init
{
    if ((self = [super init])) {
        isGotUsers = NO;
        
        
        NSString *urlString = [Utils getUsersUrl];
        [NSThread detachNewThreadSelector:@selector(getUserInfoThread:) toTarget:self withObject:urlString];
    }
    
    
    return self;
}

- (void)getUserInfoThread:(NSString*) url
{
    @autoreleasepool
    {
        
        NSString *userResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
        
        SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
        id result = [JSonParser objectWithString:userResult];
        
//        NSDictionary *users = [result objectForKey:@"users"];
//        [Share getInstance].allUsers = [users allValues];
        [Share getInstance].allUsers = [result objectForKey:@"users"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString * userLoginId = [defaults objectForKey:@"loginId"];
        
        for (NSMutableDictionary * dic in [Share getInstance].allUsers) {
            NSString* strUserId = [dic objectForKey:@"id"];
            if ([strUserId isEqualToString:[NSString stringWithFormat:@"%@", userLoginId]]) {
//                NSLog(@"dic = %@", dic);
                [Share getInstance].dicUserInfo = [[NSMutableDictionary alloc] initWithDictionary:dic];
                break;
            }
        }
        
        isGotUsers = YES;
    }
}

- (void)didJsonReadFail
{
    [[[UIAlertView alloc] initWithTitle:@"" message:@"Oops! We seem to be experiencing a system overload. Please try again in a few minute." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
- (void)didJsonRead:(id)result
{
    NSDictionary *users = [result objectForKey:@"users"];
    NSArray *allUsers = [users allValues];
    self.userList = [allUsers sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int id1 = [[obj1 objectForKey:@"id"] intValue];
        int id2 = [[obj2 objectForKey:@"id"] intValue];
        if (id1 < id2) {
            return NSOrderedAscending;
        } else if (id1 > id2) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    
    
    
    isGotUsers = YES;
}

@end
