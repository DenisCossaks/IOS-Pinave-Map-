//
//  MainViewController.m
//  PinAve
//
//  Created by Yuan Luo on 4/24/13.
//  Copyright (c) 2013 Sun Zhe. All rights reserved.
//

#import "MainViewController.h"
#import "UserSession.h"
#import "HomeViewController.h"
#import "InstructionViewController.h"


@interface MainViewController ()

@end

@implementation MainViewController

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

    CGRect rt;
    UIImage * image;
    
    if (iPhone) {
        if (![Global isIPhone5]) {
            rt = CGRectMake(0, 0, 320.0f, 460.0f);
            image = [UIImage imageNamed:@"Default.png"];
        } else {
            rt = CGRectMake(0, 0, 320.0f, 548.0f);
            image = [UIImage imageNamed:@"Default-568h@2x.png"];
        }
    }

    m_SplashView = [[UIImageView alloc] initWithFrame:rt];
    [m_SplashView setImage:image];

    [self.view addSubview:m_SplashView];
    [self.view bringSubviewToFront:m_SplashView];

    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(showSplash) userInfo:nil repeats:NO];
    
}
-(void) viewWillAppear:(BOOL)animated
{
    if (loadingView == nil) {
        loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        loadingView.center = self.view.center;
        loadingView.color = [UIColor blackColor];
        [self.view addSubview:loadingView];
//        loadingView.hidden = YES;
        [loadingView stopAnimating];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) showSplash
{
    [self gotoNext];
    
}

-(void) removeSplash
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
    m_SplashView.alpha = 0.0;
    [UIView commitAnimations];

}

- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [m_SplashView removeFromSuperview];
}


-(void) gotoNext
{
    if ([[UserSession session] isLoggedIn]) {
//        [[SHKActivityIndicator currentIndicator] displayActivity:@"LogIn..."];
//        loadingView.hidden = NO;
        [loadingView startAnimating];
        
        [UserSession session].delegate = self;
        [[UserSession session] login];
    } else {
        [self removeSplash];
        
        if (![[Share getInstance] getFirstApp]) {
            
            [self gotoIntro];
        }
        else {
            [self gotoHomePage];
        }
	}

}
- (void) gotoHomePage
{
    HomeViewController *vc;
    
    if (iPad) {
        vc = [[HomeViewController alloc] initWithNibName:@"HomeViewController-ipad" bundle:nil];
    } else {
        vc = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    }
    
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:vc];
    [appDelegate.window setRootViewController:navController];
}
- (void) gotoMainPage
{
    [self removeSplash];
    
    AppDelegate *delegate  = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate initTabBar];
    
//    [delegate.window addSubview:delegate.tabBarController.view];
//    [delegate.window setRootViewController:delegate.tabBarController];
}
-(void) gotoIntro
{
    InstructionViewController *vc = [[InstructionViewController alloc] initWithValue:YES];

    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.window setRootViewController:vc];
    
}


#pragma mark ----- Login Delegate -------
-(void) loginSuccess{
//    [[SHKActivityIndicator currentIndicator] hide];
    loadingView.hidden = YES;
    [loadingView stopAnimating];
    
    [self gotoMainPage];
}
-(void) loginFail
{
//    [[SHKActivityIndicator currentIndicator] hide];
    loadingView.hidden = YES;
    [loadingView stopAnimating];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Fail" message:@"Login is fail!" delegate:self
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self gotoHomePage];
}
@end
