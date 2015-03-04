//
//  FacebookManager.m
//  aspire
//
//  Created by Satyadev Sain on 9/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FacebookManager.h"

static NSString* kAppId = @"393012184055088"; //@"169634153148209";
static NSString* kAppSecretKey = @"4b6bac309de19e37444ae6718d2200a7"; //@"6f6dcb4e4a9378bf91c92863dd5803fb";

NSString* const kFacebookUpdateSuccessNotificationName = @"FacebookUpdateSuccessful";
NSString* const kFacebookUpdateFailureNotificationName = @"FacebookUpdateFailed";
static FacebookManager *sharedInstance = nil;

@interface FacebookManager ()
- (id) initPrivately;
@end


@implementation FacebookManager

@synthesize delegate=delegate_;
@synthesize facebook=facebook_;

+ (FacebookManager *)sharedInstance {
  if (!sharedInstance) {
    sharedInstance = [[self alloc] initPrivately];
  }
  return sharedInstance;
}

- (id) initPrivately 
{
  
  if (!kAppId) 
  {
    NSLog(@"missing app id!");
    exit(1);
    return nil;
  }
  
  if ((self = [super init])) {
    permissions_ =  [NSArray arrayWithObjects:
                      @"read_stream", @"publish_stream", @"offline_access",nil];
    facebook_ = [[Facebook alloc] initWithAppId:kAppId
                                    andDelegate:self];
    
    [facebook_ authorize:permissions_];
  }
  return self;
}

- (void)postMessage:(NSString *)message {
  
  NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:message,@"message",@"Test it!",@"name",nil];
  
  [facebook_ requestWithGraphPath:@"me/feed"  andParams:params andHttpMethod:@"POST" andDelegate:self];
}

- (void)postMessage:(NSString *)message andCaption:(NSString *)caption andImage:(UIImage *)image
{
    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
    [args setObject:caption forKey:@"caption"];
    [args setObject:message forKey:@"message"];
    [args setObject:UIImageJPEGRepresentation(image, 0.7) forKey:@"picture"];
    
    [facebook_ requestWithMethodName:@"photos.upload" andParams:args andHttpMethod:@"POST" andDelegate:self];
}

-(void) getMyInfo
{
    @autoreleasepool {
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"name,id,picture,gender,email,first_name,last_name", @"fields", nil];
        //        self.reqMyInfo = [facebook_ requestWithGraphPath:@"me" andDelegate: self ];
        self.reqMyInfo = [facebook_ requestWithGraphPath:@"me" andParams:params andDelegate:self];
    }
}


#pragma mark Facebook login delegates
- (void)fbDidLogin {
  if ([delegate_ respondsToSelector:@selector(facebookLoginSucceeded)]) {
    [delegate_ facebookLoginSucceeded];
  }
}

-(void)fbDidNotLogin:(BOOL)cancelled {
  sharedInstance = nil;
  if ([delegate_ respondsToSelector:@selector(facebookLoginFailed)]) {
    [delegate_ facebookLoginFailed];
  }
}
#pragma mark facebook delegate methods

/**
 * FBRequestDelegate
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
  if ([delegate_ respondsToSelector:@selector(messagePostedSuccessfully)]) {
    [delegate_ messagePostedSuccessfully];
  }
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
  if ([delegate_ respondsToSelector:@selector(messagePostingFailed)]) {
    [delegate_ messagePostingFailedWithError:error];
  }
}


-(void) processMyInfoQuery: (id) result
{
    NSLog(@"MyInfo - %@", result);
    [self.delegate myInfoLoaded: result];
}



@end
