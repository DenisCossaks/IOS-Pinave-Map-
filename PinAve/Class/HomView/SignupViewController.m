//
//  SignupViewController.m
//  NEP
//
//  Created by osone on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignupViewController.h"
#import "LoginViewController.h"
#import "SHKActivityIndicator.h"
#import "UserSession.h"
#import <CommonCrypto/CommonDigest.h>
#import "PrivacyController.h"
#import "TermsServiceController.h"
#import "AppDelegate.h"


@implementation NSString (Sorting)

- (NSComparisonResult) sortStrings:(NSString *)other
{
    NSComparisonResult result =[self compare:other];
    
    //    enum _NSComparisonResult {NSOrderedAscending = -1, NSOrderedSame, NSOrderedDescending};
    
    if(result == NSOrderedAscending)
        return NSOrderedDescending;
    else if(result == NSOrderedDescending)
        return NSOrderedAscending;
    
    return result;
}
@end

@interface SignupViewController ()

@end

@implementation SignupViewController


- (NSString *)md5HexDigest:(NSString *)input
{
    const char *str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", result[i]];
    }
    
    return ret;
}


- (NSString *)keyAlgorithm:(NSString *)firstname : (NSString *)lastname
{
    NSString *sharp = @"#";
    NSString *percent = @"%";
    //    NSLog(@"Percent- %@",percent);
    NSString *firstkey = firstname;
    NSString *lastkey = lastname;
    firstkey = [NSString stringWithFormat:@"%@%@%@", sharp, firstkey, percent];
    lastkey = [NSString stringWithFormat:@"%@%@%@",sharp, lastkey, percent];
    NSLog(@"sharp - %@", firstkey);
    firstkey = [self md5HexDigest:firstkey];
    lastkey = [self md5HexDigest:lastkey];
    NSLog(@"MD5- %@", firstkey);
    
    NSMutableArray  *newArray = [[NSMutableArray alloc] init];
    
    for(int i = 0; i<[firstkey length]; i++)
    {
        NSString    *newChar = [NSString stringWithFormat:@"%c%c",[firstkey characterAtIndex:i],[lastkey characterAtIndex:i]];
        
        [newArray addObject:newChar];
    }
    
    [newArray sortUsingSelector:@selector(sortStrings:)];
    
    for(int i = 0; i<([newArray count] - 1); i++)
    {
        if([[newArray objectAtIndex:i] isEqualToString:[newArray objectAtIndex:i+1]])
        {
            [newArray removeObjectAtIndex:i+1];
            if(i > -1)
                i--;
        }
        
    }
    NSMutableString *key = [[NSMutableString alloc] init];
    for(int i = 0; i<([newArray count]); i++)
    {
        [key appendString:[newArray objectAtIndex:i]];
    }
    
    [key appendFormat:@"%@",[self md5HexDigest:key]];
//    NSLog(@"KEY - %@",key);
    return key;
}

- (IBAction)onCancel:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)onJoin:(id)sender
{
    if ([firstnameTextField.text length] < 1){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Firstname Error" message:@"Please input your first name!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    if ([lastnameTextField.text length] < 1){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lastname Error" message:@"Please input your last name!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    if ([passwordTextField.text length] < 6){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Error" message:@"Your password must have at least 6 characters long." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    if (![passwordTextField.text isEqualToString:confirmpasswordTextField.text]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Error" message:@"Password do not match" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }

    if ([emailTextField.text length] < 1){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Error" message:@"You need a Email name to register." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    
    NSString *firstKey = firstnameTextField.text;
    NSString *lastKey = lastnameTextField.text;
    NSString *RealKey = [Share generateKey:firstKey lastName:lastKey
                                     email:emailTextField.text fbid:@""];//[self keyAlgorithm:firstKey :lastKey];
    
    
//    [[SHKActivityIndicator currentIndicator] displayActivity:@"Sign Up..."];
//    loadingView.hidden = NO;
    [loadingView startAnimating];
    
    [[UserSession session] signupWithFirstname:firstnameTextField.text andlastname:lastnameTextField.text andpassword:passwordTextField.text andconfirmpass:confirmpasswordTextField.text andemail:emailTextField.text andkey:RealKey];
    [UserSession session].delegate = self;
    
}

- (IBAction)next:(id)sender
{
    if ([firstnameTextField isFirstResponder]) {
		[lastnameTextField becomeFirstResponder];
	}else if ([lastnameTextField isFirstResponder]){
		[emailTextField becomeFirstResponder];         
	} else if ([emailTextField isFirstResponder]) {
        [passwordTextField becomeFirstResponder];
    } else if ([passwordTextField isFirstResponder]) {
		[confirmpasswordTextField becomeFirstResponder];
	}
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

#pragma mark -------- usersession delegate --------
-(void) loginSuccess {
//    loadingView.hidden = YES;
    [loadingView stopAnimating];
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.viewController gotoMainPage];
}
-(void) loginFail{
//    loadingView.hidden = YES;
    [loadingView stopAnimating];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Registering"
                                                    message:@"There was an error registering new user. Please try again."
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}


- (void)userRegistrationDidSucceed{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)userRegistrationFailed{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Registering"
                                                    message:@"There was an error registering new user. Please try again."
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];
    
    self.navigationController.navigationBarHidden = YES;
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:YES animated:YES];

    if (loadingView == nil) {
        loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        loadingView.center = self.view.center;
        loadingView.color = [UIColor blackColor];
        [self.view addSubview:loadingView];
//        loadingView.hidden = YES;
//        [loadingView startAnimating];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignupCallFail) name:UserRegisterFailed object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignupCallBack) name:UserRegisterSuccess object:nil];
    
//    m_bIsRegistered = NO;
    
    firstnameTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    lastnameTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

//
//- (void)userSignupCallFail
//{
//    [[SHKActivityIndicator currentIndicator] hide];
//
////    [[[UIAlertView alloc] initWithTitle:nil message:@"Signup Fail! Please retry." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to Sign Up. This email is a registered user. Please proceed with Log in." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];    
//    
//    
//
//}
//
//- (void)userSignupCallBack
//{
//    [[SHKActivityIndicator currentIndicator] hide];
//
//    m_bIsRegistered = YES;
//    [self dismissModalViewControllerAnimated:YES];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginSuccess object:nil];        
//}

@end
