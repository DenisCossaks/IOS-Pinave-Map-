//
//  LoginViewController.m
//  NEP
//
//  Created by Dandong3 Sam on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "PrivacyController.h"
#import "TermsServiceController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize usernameTextField;
@synthesize passwordTextField;


#pragma mark - Actions

- (IBAction)onCancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)attemptLogin
{
    if ([usernameTextField.text length] > 0 && [passwordTextField.text length] > 0) {
        
        for (UITextField *textField in self.view.subviews) {
            if ([textField isKindOfClass:[UITextField class]]) {
                [textField resignFirstResponder];
            }
        }
        
        
//        [[SHKActivityIndicator currentIndicator] displayActivity:@"Sign in..."];
//        loadingView.hidden = NO;
        [loadingView startAnimating];
        
        [[UserSession session] loginWithUsername:usernameTextField.text andPassword:passwordTextField.text];
        [UserSession session].delegate = self;
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:usernameTextField.text forKey:@"save_username"];
        [defaults setValue:passwordTextField.text forKey:@"save_password"];
        [defaults synchronize];
    }
}

- (IBAction)next
{
	if ([self.usernameTextField isFirstResponder]) {
		[self.passwordTextField becomeFirstResponder];
	}
}


/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginCallBack:) name:UserDidLogin object:nil];
//    m_bIsLogDid = NO;
    // Do any additional setup after loading the view from its nib.
	
	
//	[self.usernameTextField becomeFirstResponder];
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
 
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;

    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:YES animated:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    usernameTextField.text = [defaults valueForKey:@"save_username"];
    passwordTextField.text = [defaults valueForKey:@"save_password"];
    
    if (loadingView == nil) {
        loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        loadingView.center = self.view.center;
        loadingView.color = [UIColor blackColor];
        [self.view addSubview:loadingView];
    }
}


#pragma mark ------ UserSession delegate -
-(void) loginSuccess
{
//    [[SHKActivityIndicator currentIndicator] hide];
//    loadingView.hidden = YES;
    [loadingView stopAnimating];

    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.viewController gotoMainPage];
}

-(void) loginFail
{
//    [[SHKActivityIndicator currentIndicator] hide];
//    loadingView.hidden = YES;
    [loadingView stopAnimating];

    usernameTextField.text = @"";
    passwordTextField.text = @"";
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"Login Fail! Please retry." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
}

/////////////////////////////////////////////////////////////////////////////////////////////
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

@end
