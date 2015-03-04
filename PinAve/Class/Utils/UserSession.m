//
//  UserSession.m
//  NEP
//
//  Created by Dandong3 Sam on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserSession.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "JSON.h"
#import "CategoryViewController.h"

#import "UsersPool.h"

#import "ASIFormDataRequest.h"


static UserSession *g_singleton = nil;

@interface UserSession () {
    NSInteger currStatus;
}

@property (strong, nonatomic) NSMutableData *receivedData;

@end

@implementation UserSession

@synthesize username, password, authCode, userId;
@synthesize receivedData;

+ (UserSession *)session
{
    if (g_singleton == nil) {
        g_singleton = [[UserSession alloc] init];
    }
    
    return g_singleton;
}

- (id)init
{
    if ((self = [super init])) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.username = [defaults valueForKey:@"username"];
        self.password = [defaults valueForKey:@"password"];
    }
    
    return self;
}

#pragma mark - Register New User

- (void)signupWithFirstname:(NSString *)firstname andlastname:(NSString *)lastname andpassword:(NSString *)sspassword andconfirmpass:(NSString *)confirmpass andemail:(NSString *)email andkey:(NSString *)key
{
    NSString *url = [Utils getRegisterUrl];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString: url]];
    request.requestMethod = @"POST";
    
    [request setPostValue:firstname forKey:@"firstname"];
    [request setPostValue:lastname forKey:@"lastname"];
    [request setPostValue:sspassword forKey:@"password"];
    [request setPostValue:confirmpass forKey:@"password_confirm"];
    [request setPostValue:email forKey:@"email"];
    [request setPostValue:key forKey:@"key"];

    [request setDelegate:self];
    [request setDidFinishSelector:@selector(uploadRequestFinished:)];
    [request setDidFailSelector:@selector(uploadRequestFailed:)];
    
    [request startAsynchronous];
    
    self.username = email;
    self.password = sspassword;
}


- (void)uploadRequestFinished:(ASIHTTPRequest *)request{
    
    NSString *resultString = [request responseString];
    NSLog(@"result = %@", resultString);
    
    NSMutableDictionary* result = [resultString JSONValue];
    
    NSDictionary * message = [result objectForKey:@"message"];
    if (message != nil) {
        NSString * create = [message objectForKey:@"create"];
        NSString * login = [message objectForKey:@"login"];
        
        if ([create isEqualToString:@"OK"]
            || [login isEqualToString:@"OK"]) {
            
            NSDictionary * data = [result objectForKey:@"data"];
            if (data != nil) {
                self.authCode = [data objectForKey:@"code"];
                self.userId = [data objectForKey:@"user_id"];
                
                [self saveUser];
                
                [self.delegate loginSuccess];
                
                return;
            }
        }
    }
    
    [self.delegate loginFail];
}

- (void)uploadRequestFailed:(ASIHTTPRequest *)request{
    
    [self.delegate loginFail];
    
}


#pragma mark - Log in

- (BOOL)isLoggedIn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.username = [defaults valueForKey:@"username"];
    self.password = [defaults valueForKey:@"password"];
    
    return ([self.username length] > 0 && [self.password length] > 0);

}
- (void) login
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.username = [defaults valueForKey:@"username"];
    self.password = [defaults valueForKey:@"password"];

    [self loginWithUsername:self.username andPassword:self.password];
}

- (void)loginWithUsername:(NSString *)name andPassword:(NSString *)pass
{
    NSString *url = [Utils getRegisterUrl];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString: url]];
    request.requestMethod = @"POST";
    
    [request setPostValue:pass forKey:@"password"];
    [request setPostValue:name forKey:@"email"];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(uploadRequestFinished:)];
    [request setDidFailSelector:@selector(uploadRequestFailed:)];
    
    [request startAsynchronous];
    
    
    self.username = name;
    self.password = pass;
    
}
- (void)loginWithFacebook:(NSString *)firstname andlastname:(NSString *)lastname
                 andemail:(NSString *)email andkey:(NSString *)key facebook:(NSString*) fbid
{
    NSString *url = [Utils getRegisterUrl];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString: url]];
    request.requestMethod = @"POST";
    
    [request setPostValue:firstname forKey:@"firstname"];
    [request setPostValue:lastname forKey:@"lastname"];
    [request setPostValue:email forKey:@"email"];
    [request setPostValue:key forKey:@"key"];
    [request setPostValue:fbid forKey:@"fbid"];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(uploadRequestFinished:)];
    [request setDidFailSelector:@selector(uploadRequestFailed:)];
    
    [request startAsynchronous];
    
}

- (void)destroy
{
    self.username = @"";
    self.password = @"";
    self.userId = @"";
    self.authCode = @"";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:@"username"];
    [defaults setObject:@"" forKey:@"password"];
    [defaults setObject:@"" forKey:@"loginId"];
    [defaults setObject:@"" forKey:@"loginCode"];
    [defaults synchronize];
}

- (void)saveUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.username forKey:@"username"];
    [defaults setObject:self.password forKey:@"password"];
    [defaults setObject:self.userId forKey:@"loginId"];
    [defaults setObject:self.authCode forKey:@"loginCode"];
    [defaults synchronize];
}


- (void)logout
{
    if ([self.authCode length] < 1)
        return;
    
    NSString *logoutUrl = [Utils getLogoutUrl];
    JsonReader *jsonReader = [[JsonReader alloc] initWithUrl:logoutUrl delegate:self];
    [jsonReader read];
    currStatus = 101;
}



- (void)didJsonReadFail
{
    [[[UIAlertView alloc] initWithTitle:@"" message:@"Oops! We seem to be experiencing a system overload. Please try again in a few minute." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)didJsonRead:(id)result
{
    NSDictionary *loginResult = result;
    
    if (!loginResult) {
        if (currStatus == 100) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Login Fail!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            [self destroy];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Logout Fail!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        return;
    }
    
    if (currStatus == 100) {
        NSString *message = [loginResult objectForKey:@"message"];

        NSString *loginCode = nil;
        NSString *loginId = nil;
        if ([message isEqualToString:@"OK"]) {
            loginCode = [loginResult objectForKey:@"code"];
            loginId = [loginResult objectForKey:@"user_id"];
        }
        
        if ([loginCode length] > 0) {
            self.authCode = loginCode;
            self.userId = loginId;
            NSLog(@"User Code : %@, User Id : %@", loginCode, loginId);
            [self saveUser];
            
            [self.delegate loginSuccess];
            
        } else {
            [self destroy];
            
            [self.delegate loginFail];
        }
        
        //        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogin object:loginCode];
    } else if (currStatus == 101) {
        NSLog(@"logout = %@", loginResult);
        
        NSDictionary * message = [loginResult objectForKey:@"message"];
        
        if (message != nil) {
            NSString * login = [message objectForKey:@"logout"];
            
            if ([login isEqualToString:@"OK"]) {

                [self destroy];

                [self.delegate logoutSuccess];

                return;
            }
        }
        
        [self.delegate logoutFail];
       
    }
    
    currStatus = 0;
}



@end
