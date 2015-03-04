//
//  UserSession.h
//  NEP
//
//  Created by Dandong3 Sam on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JsonReader.h"

#define UserDidLogin            @"UserDidLogin"
#define UserDidLoginHome            @"UserDidLoginHome"

#define UserDidLoginSuccess         @"UserDidLoginSuccess"

#define UserDidLogoutSuccess           @"UserDidLogoutSuccess"
#define UserDidLogoutFailed           @"UserDidLogoutFaild"

#define UserRegisterFailed          @"UserRegisterFailed"
#define UserRegisterSuccess         @"UserRigisterSuccess"


#define kRelogin            @"RELOGIN"
#define kReloading          @"RELOADING"



@class UserSession;
@protocol UserSessionDelegate
-(void) loginSuccess;
-(void) loginFail;
-(void) logoutSuccess;
-(void) logoutFail;
@end


@interface UserSession : NSObject <JsonReaderDelegate>

@property (nonatomic, strong) id<UserSessionDelegate> delegate;



@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *authCode;
@property (nonatomic, strong) NSString *userId;


+ (UserSession *)session;

- (BOOL)isLoggedIn;
- (void)login;
- (void)loginWithUsername:(NSString *)name andPassword:(NSString *)pass;
- (void)logout;

- (void)signupWithFirstname:(NSString *)firstname andlastname:(NSString *)lastname andpassword:(NSString *)sspassword andconfirmpass:(NSString *)confirmpass andemail:(NSString *)email andkey:(NSString *)key;

- (void)loginWithFacebook:(NSString *)firstname andlastname:(NSString *)lastname
                 andemail:(NSString *)email andkey:(NSString *)key facebook:(NSString*) fbid;

- (void)destroy;
- (void)saveUser;



@end
