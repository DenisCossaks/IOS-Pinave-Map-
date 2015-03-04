//
//  TermsServiceController.m
//  PinAve.
//
//  Created by Yuan Luo on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TermsServiceController.h"

@interface TermsServiceController ()

@end

@implementation TermsServiceController

@synthesize m_bMode;


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
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Terms of Service";
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:YES animated:YES];
    
//    NSString * url = @"http://pinave.com/p/privacy-policy";
//   [m_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    
    [scrollView setContentSize:CGSizeMake(txtView.frame.size.width, txtView.frame.size.height)];
    [scrollView addSubview:txtView];
}

- (IBAction)onBack:(id)sender
{
    if (m_bMode) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

@end
