//
//  TwitterManager.m
//
//  Created by Satyadev Sain on 9/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TwitterManager.h"
#import "MGTwitterEngine.h"

@implementation TwitterManager

@synthesize currentRequestType=currentRequestType_;
@synthesize engine=engine_;
@synthesize delegate=delegate_;

+ (TwitterManager *) sharedTwitterManager {
  static TwitterManager *twitterSharedInstance = nil;
  if (!twitterSharedInstance) {
    twitterSharedInstance = [[self alloc] init];
  }
  return twitterSharedInstance;
}

- (id) init {
  if ((self = [super init])) {
    if(!engine_) {  
        engine_ = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];  

        engine_.consumerKey    = @"viL9AYt3rrFJXE1Oe4uQdA";  
        engine_.consumerSecret = @"03RRBTIPmQd3Aq3TbdNRFGWbLp8Sd9pCN6YzocbVmI";  
    }  	
  }
  return self;
}

- (void) authorizeUserFromController:(UIViewController *)controller { 	
  
  if(![engine_ isAuthorized]){  
    UIViewController *controller1 = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:engine_ delegate:self];  
    if (controller){ 
      [controller  presentModalViewController:controller1 animated: YES];  
    }
    else {
       [delegate_ twitterManager:self failedToAuthenticateWithError:nil];
    }
  }
  else {
    [delegate_ twitterManager:self didAuthenticateUser:[engine_ username]];
  }
}

- (void) logout {
  [engine_ clearAccessToken];
}

- (void) postMessage:(NSString *)message {
  currentRequestType_ = TwitterRequestTypePostMessage;
  [engine_ sendUpdate:message];
}

- (void) postImage:(UIImage *)image message:(NSString *)message {
  currentRequestType_ = TwitterRequestTypePostMessageWithImage;
  [engine_ uploadImage:image message:message];
}


#pragma mark delegate methods

- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
  if ([delegate_ respondsToSelector:@selector(twitterManager:didAuthenticateUser:)]) {
    [delegate_ twitterManager:self didAuthenticateUser:username];
  }
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
  if ([delegate_ respondsToSelector:@selector(twitterManager:failedToAuthenticateWithError:)]) {
   [delegate_ twitterManager:self failedToAuthenticateWithError:nil]; 
  }
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
  [delegate_ twitterManager:self failedToAuthenticateWithError:nil];
}


//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: data forKey: @"twitterAuthData"];
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"twitterAuthData"];
}

//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
  if (currentRequestType_ == TwitterRequestTypePostMessage ) {
    if ([delegate_ respondsToSelector:@selector(twitterManager:didPostMessage:)]) {
      [delegate_ twitterManager:self didPostMessage:nil];
    }
  }
  else if(currentRequestType_ == TwitterRequestTypePostMessageWithImage){
    if ([delegate_ respondsToSelector:@selector(twitterManager:didPostImage:)]) {
      [delegate_ twitterManager:self didPostImage:nil];
    }
  }
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	
  if (currentRequestType_ == TwitterRequestTypePostMessage ) {
    if ([delegate_ respondsToSelector:@selector(twitterManager:didPostMessage:)]) {
      [delegate_ twitterManager:self didPostMessage:error];
    }
  }
  else if(currentRequestType_ == TwitterRequestTypePostMessageWithImage){
    if ([delegate_ respondsToSelector:@selector(twitterManager:didPostImage:)]) {
      [delegate_ twitterManager:self didPostImage:error];
    }
  }
}

@end
