//
//  HomeViewController.h
//  PinAve
//
//  Created by Gold Luo on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "FacebookManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UserSession.h"

#import <Social/Social.h>
#import "accounts/Accounts.h"


@interface HomeViewController : UIViewController <FBLoginViewDelegate, UserSessionDelegate>
{
    IBOutlet UIButton * btnFacebook;
}

@property (nonatomic, retain) ACAccountStore *accountStore;
@property (nonatomic, retain) ACAccount *facebookAccount;


- (IBAction)onLoginFacebook:(id)sender;
- (IBAction)onRegister:(id)sender;
- (IBAction)onLogin:(id)sender;
- (IBAction)onTermsOfService:(id)sender;
- (IBAction)onPrivacyPolice:(id)sender;

@end
