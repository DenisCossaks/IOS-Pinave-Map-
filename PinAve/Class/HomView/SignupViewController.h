//
//  SignupViewController.h
//  NEP
//
//  Created by osone on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSession.h"




@interface SignupViewController : UIViewController <UserSessionDelegate>
{
    IBOutlet UITextField *firstnameTextField;
    IBOutlet UITextField *lastnameTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UITextField *confirmpasswordTextField;
    IBOutlet UITextField *emailTextField;
    
    BOOL    m_bIsRegistered;
    
    UIActivityIndicatorView * loadingView;
}

- (IBAction)onCancel:(id)sender;
- (IBAction)onJoin:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)onTermsOfService:(id)sender;
- (IBAction)onPrivacyPolice:(id)sender;


@end
