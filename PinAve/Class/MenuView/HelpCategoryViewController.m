//
//  CategoryViewController.m
//  NEP
//
//  Created by Gold Luo on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HelpCategoryViewController.h"

@interface HelpCategoryViewController ()

@end

@implementation HelpCategoryViewController

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
    self.navigationItem.title = @"DESCRIPTIONS";

    scrollView.frame = CGRectMake(0, 0, viewBoard.frame.size.width, viewBoard.frame.size.height);
    if (iPad) {
        [scrollView setContentSize:CGSizeMake(768, 1780)];
    } else {
        [scrollView setContentSize:CGSizeMake(320, 1904)];
    }
     
    [viewBoard addSubview:scrollView];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

-(void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:YES animated:YES];

}

-(IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
