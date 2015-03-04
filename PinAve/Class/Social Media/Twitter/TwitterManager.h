//
//  TwitterManager.h
//  aspire
//
//  Created by Satyadev Sain on 9/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"

typedef enum {
  TwitterRequestTypePostMessage = 0,
  TwitterRequestTypePostMessageWithImage,
  TwitterRequestTypeNone
}TwitterRequestType;

@protocol TwitterManagerDelegate;

@interface TwitterManager : NSObject<SA_OAuthTwitterControllerDelegate> {
  id<TwitterManagerDelegate> delegate_;
  TwitterRequestType currentRequestType_;
  SA_OAuthTwitterEngine *engine_;
}

@property (nonatomic, strong) id<TwitterManagerDelegate> delegate;
@property (nonatomic, assign) TwitterRequestType currentRequestType;
@property (nonatomic, readonly) SA_OAuthTwitterEngine *engine;

+ (TwitterManager *) sharedTwitterManager;
- (void) authorizeUserFromController:(UIViewController *)controller;
- (void) logout;
- (void) postMessage:(NSString *)message;
- (void) postImage:(UIImage *)image message:(NSString *)message; 

@end

@protocol TwitterManagerDelegate <NSObject>
- (void)twitterManager:(TwitterManager *)manager didAuthenticateUser:(NSString *)username;
- (void)twitterManager:(TwitterManager *)manager failedToAuthenticateWithError:(NSError *)error;
- (void)twitterManager:(TwitterManager *)manager didPostMessage:(NSError *)error;
- (void)twitterManager:(TwitterManager *)manager didPostImage:(NSError *)error;
@end

