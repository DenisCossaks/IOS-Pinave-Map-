//
//  HomeViewController.m
//  PinAve
//
//  Created by Gold Luo on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"
#import "PrivacyController.h"
#import "TermsServiceController.h"
#import "SignupViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "UserSession.h"
#import "InstructionViewController.h"
#import "Share.h"
#import "JSON.h"


#define FACEBOOK_IOS6
#define FB_ID   @"167805526734467"
//393012184055088
@interface HomeViewController ()

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignupCallBack) name:UserDidLoginHome object:nil];
    
#ifdef FACEBOOK_IOS6
    
#else
    btnFacebook.hidden = YES;
    [self addFBLoginView];
#endif

}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:YES animated:NO];
    
    self.navigationController.navigationBarHidden = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -------- 

- (IBAction)onLoginFacebook:(id)sender
{
//    FacebookManager* myFacebook = [FacebookManager sharedInstance];
//    [myFacebook setDelegate: self];
//    if ( [[myFacebook facebook] isSessionValid]) {
//        [[[UIAlertView alloc] initWithTitle:nil message:@"You already registered on Facebook" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        return;
//    }
//

    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {

        [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];

        if(!_accountStore)
            _accountStore = [[ACAccountStore alloc] init];
        
        
        ACAccountType *facebookTypeAccount = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        [_accountStore requestAccessToAccountsWithType:facebookTypeAccount
                                               options:@{ACFacebookAppIdKey: FB_ID, ACFacebookPermissionsKey: @[@"email"]}
                                            completion:^(BOOL granted, NSError *error) {
                                                if(granted){
                                                    NSArray *accounts = [_accountStore accountsWithAccountType:facebookTypeAccount];
                                                    _facebookAccount = [accounts lastObject];
                                                    NSLog(@"Success");
                                                    
                                                    [self me];
                                                }else{
                                                    // ouch
                                                    
                                                    NSLog(@"Fail");
                                                    NSLog(@"Error: %@", error);
                                                    
                                                    [self performSelectorOnMainThread:@selector(loginFail) withObject:nil waitUntilDone:NO];
                                                }
                                            }];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a facebook right now, make sure \
                                  your device has an internet connection and you have \
                                  at least one Facebook account setup"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }

}


- (void)me{
    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." :self];

    NSURL *meurl = [NSURL URLWithString:@"https://graph.facebook.com/me"];
    
    SLRequest *merequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                              requestMethod:SLRequestMethodGET
                                                        URL:meurl
                                                 parameters:nil];
    
    merequest.account = _facebookAccount;
    
    [merequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSString *meDataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", meDataString);
        
        NSDictionary * result = [meDataString JSONValue];
        NSDictionary * errorDic = [result objectForKey:@"error"];
        if (errorDic != nil) {
            
            NSString * message = [errorDic objectForKey:@"message"];
            
            [self performSelectorOnMainThread:@selector(mefail:) withObject:message waitUntilDone:NO];
            
            return;
        }

        NSString * firstName = [result objectForKey:@"first_name"];
        NSString * lastName = [result objectForKey:@"last_name"];
        NSString * email = [result objectForKey:@"email"];
        NSString * fbid = FB_ID;
        
        [self loginWithFacebook:firstName lastName:lastName email:email fbID:fbid];
        
    }];
    
}

-(void) mefail:(NSString*) msg
{
    [[SHKActivityIndicator currentIndicator] hide];
    
    [[[UIAlertView alloc] initWithTitle:@"error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    
}
- (IBAction)onRegister:(id)sender
{
//    [self dismissModalViewControllerAnimated:YES];
    
    SignupViewController * vc;
    
    if (iPad) {
        vc = [[SignupViewController alloc] initWithNibName:@"SignupViewController-ipad" bundle:nil];
    } else {
        vc = [[SignupViewController alloc] initWithNibName:@"SignupViewController" bundle:nil];
    }
    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentModalViewController:nav animated:YES];
    
}
- (IBAction)onLogin:(id)sender
{
    LoginViewController * vc;
    
    if (iPad) {
        vc = [[LoginViewController alloc] initWithNibName:@"LoginViewController-ipad" bundle:nil];
    } else {
        vc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    }

    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentModalViewController:nav animated:YES];
    
}
- (IBAction)onTermsOfService:(id)sender
{
    TermsServiceController * vc;
    
    if (iPad) {
        vc = [[TermsServiceController alloc] initWithNibName:@"TermsServiceController-ipad" bundle:nil];
    } else {
        vc = [[TermsServiceController alloc] initWithNibName:@"TermsServiceController" bundle:nil];
    }
    
    vc.m_bMode = NO;
    
    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentModalViewController:nav animated:YES];
    
}
- (IBAction)onPrivacyPolice:(id)sender
{
    PrivacyController * vc;
    
    if (iPad) {
        vc = [[PrivacyController alloc] initWithNibName:@"PrivacyController-ipad" bundle:nil];
    } else {
        vc = [[PrivacyController alloc] initWithNibName:@"PrivacyController" bundle:nil];
    }
    
    vc.m_bMode = NO;
    
    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentModalViewController:nav animated:YES];

}

- (void) addFBLoginView
{
    FBLoginView * loginview = [[FBLoginView alloc] initWithPermissions: [NSArray arrayWithObjects: @"email", @"user_birthday", @"publish_stream", @"offline_access",@"read_stream", nil] ];
    loginview.frame = CGRectMake(24, 263, 272, 42);
    
    for (id obj in loginview.subviews)
    {
        if ([obj isKindOfClass:[UIButton class]])
        {
            UIButton * loginButton =  obj;
            
            loginButton.frame = CGRectMake(0,0,272,42);
            
            [loginButton setBackgroundImage:[UIImage imageNamed:@"loginFacebook.png"] forState:UIControlStateNormal];
            [loginButton setBackgroundImage:nil forState:UIControlStateSelected];
            [loginButton setBackgroundImage:nil forState:UIControlStateHighlighted];
        }
        
        if ([obj isKindOfClass:[UILabel class]])
        {
            UILabel * loginLabel =  obj;
            loginLabel.text = @"";
            loginLabel.hidden = YES;
        }
    }
    loginview.delegate = self;
    [self.view addSubview:loginview];
    
}

#pragma mark -
#pragma mark - FBLoginViewDelegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    
    NSLog(@"facebook Logged In");
    
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    NSString* firstName = user.first_name;
    NSString* lastName = user.last_name;
    NSString* email = [user objectForKey:@"email"];
    NSString* fbid = FB_ID;

    [self loginWithFacebook:firstName lastName:lastName email:email fbID:fbid];
}

- (void) loginWithFacebook:(NSString*) firstName lastName:(NSString*)lastName email:(NSString*) email fbID:(NSString*) fbid
{
    NSString *RealKey = [Share generateKey:firstName lastName:lastName
                                     email:email fbid:fbid];
    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"" : self];
    
    [[UserSession session] loginWithFacebook:firstName
                                 andlastname:lastName
                                    andemail:email
                                      andkey:RealKey
                                    facebook:fbid];
    [UserSession session].delegate = self;
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    // Called after logout
    NSLog(@"facebook Logged out");
}

-(void) loginSuccess {
    [[SHKActivityIndicator currentIndicator] hide];
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.viewController gotoMainPage];
}
-(void) loginFail{
    [[SHKActivityIndicator currentIndicator] hide];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail"
                                                    message:@"Facebook Login Fail. Please try again."
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

/*
#pragma mark FacebookManagerDelegate Methods
- (void) facebookLoginSucceeded 
{
    [[[UIAlertView alloc] initWithTitle:nil message:@"Completed Successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

//    FacebookManager* myFacebook = [FacebookManager sharedInstance];
//    [myFacebook getMyInfo];

}

- (void) facebookLoginFailed {
    NSLog(@"facebook login failed");
    [[SHKActivityIndicator currentIndicator] hide];  
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"facebook login failed"
                                                   delegate:nil
                                          cancelButtonTitle:@"YES"
                                          otherButtonTitles:nil, nil];
    [alert show];
    
}


- (void) myInfoLoaded: (NSMutableDictionary*) myInfo
{
//    user.first_name = [myInfo objectForKey: @"first_name"];
//    user.last_name = [myInfo objectForKey: @"last_name"];
//    user.name = [myInfo objectForKey: @"name"];
//    user.gender = [myInfo objectForKey: @"gender"];
//    user.photo_url = [myInfo objectForKey: @"picture"];
//    //    user.verified = [myInfo objectForKey: @"verified"];
//    [self login: user];
//    [self updateUserLocation];
//
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:@"" forKey:@"first_name"];
//    [defaults setObject:@"" forKey:@"last_name"];
//    [defaults setObject:@"" forKey:@"gender"];
//    [defaults synchronize];
//
//    
//    [[SHKActivityIndicator currentIndicator] hide];
//    
//    [[[UIAlertView alloc] initWithTitle:nil message:@"Completed Successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

}
*/

@end
