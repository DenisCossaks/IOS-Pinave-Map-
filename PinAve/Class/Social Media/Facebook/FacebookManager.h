//
//  FacebookManager.h
//  aspire
//
//  Created by Satyadev Sain on 9/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"
#import "FBLoginButton.h"

@protocol FacebookManagerDelegate;


extern NSString* const kFacebookUpdateSuccessNotificationName;
extern NSString* const kFacebookUpdateFailureNotificationName;

@interface FacebookManager : NSObject<FBRequestDelegate,
FBDialogDelegate,
FBSessionDelegate> {
  id<FacebookManagerDelegate> delegate_;
  Facebook* facebook_;
  NSArray* permissions_;
}

@property(readonly) Facebook *facebook;
@property (nonatomic, strong) id<FacebookManagerDelegate> delegate;
@property (nonatomic, strong) FBRequest*    reqMyInfo;


+ (FacebookManager *)sharedInstance;
- (void)postMessage:(NSString *)message;
- (void)postMessage:(NSString *)message andCaption:(NSString *)caption andImage:(UIImage *)image;

- (void)getMyInfo;

@end

@protocol FacebookManagerDelegate <NSObject>
- (void) facebookLoginSucceeded;
- (void) facebookLoginFailed;
- (void) messagePostedSuccessfully;
- (void) messagePostingFailedWithError:(NSError *)error;

- (void) myInfoLoaded: (NSMutableDictionary*) myInfo;

@end



