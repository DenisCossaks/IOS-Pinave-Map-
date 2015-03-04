//
//  LoginViewController.h
//  NEP
//
//  Created by Dandong3 Sam on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSession.h"

@interface LoginViewController : UIViewController<UserSessionDelegate>
{
    UIActivityIndicatorView *loadingView;
    
}

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)onCancel:(id)sender;
- (IBAction)attemptLogin;
- (IBAction)next;

- (IBAction)onTermsOfService:(id)sender;
- (IBAction)onPrivacyPolice:(id)sender;

@end
