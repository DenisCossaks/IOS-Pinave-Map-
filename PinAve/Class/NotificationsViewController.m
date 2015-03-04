//
//  NotificationsViewController.m
//  PinAve
//
//  Created by Gold Luo on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotificationsViewController.h"
#import "AppDelegate.h"
#import "Setting.h"
#import "Notification.h"
#import "WithCategoryController.h"


@interface UIApplication (extended) 
- (void) addStatusBarImageNamed:(NSString *)aName; 
- (void) removeStatusBarImageNamed:(NSString *)aName; 
@end 


@interface NotificationsViewController ()

@end

@implementation NotificationsViewController

@synthesize m_bPresent;

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
    
    [self setInterface];
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

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    if (m_bPresent) {
        AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate setTabBarHidden:YES animated:YES];
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
}


- (void) setInterface 
{
    BOOL bSetNoti = [Notification getNotify];
    [switchSet setOn:bSetNoti];
    [viewSubAll setHidden:!bSetNoti];
    
    int radius = [Notification getDistance];
    int value = 0;
    switch (radius) {
        case 1:
            value = 0;
            break;
        case 2:
            value = 1;
            break;
        case 5:
            value = 2;
            break;
        case 10:
            value = 3;
            break;
    }
    lbRadius.text = [NSString stringWithFormat:@"%d", radius];
    slRadius.value = value;
    
    if ([Setting getUnit] == 0) {
        lbUnit.text = @"Km";
    } else {
        lbUnit.text = @"Mile";
    }
    
    
    int minute = [Notification getMinute];
    switch (minute) {
        case 1:
            value = 0;            break;
        case 3:
            value = 1;            break;
        case 5:
            value = 2;            break;
        case 10:
            value = 3;            break;
        case 15:
            value = 4;            break;
        case 30:
            value = 5;            break;
        case 60:
            value = 6;            break;
    }
    lbMin.text = [NSString stringWithFormat:@"%d", minute];
    slScan.value = value;
    
    int duration = [Notification getDuration];
    lbHour.text = [NSString stringWithFormat:@"%d", duration];
    slNotify.value = duration;
    
    if (!m_bPresent) {
        [btnSet setHidden:YES];
        
        [btnBack setImage:[UIImage imageNamed:@"noti_btn_set.png"] forState:UIControlStateNormal];
    }
}


#pragma mark --------
- (IBAction)onBack:(id)sender
{
    if (m_bPresent) {
        BOOL bSetNoti = switchSet.on;

        [Notification setNotify:bSetNoti];
        
        AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate stopScanThread];
        [appDelegate setNotifyTabbar : bSetNoti];
        
        if (switchSet.on == YES) {
            if ([appDelegate isSelectedAnyNoti]) {
                [appDelegate startScanThread];
            }
            else {
                [[[UIAlertView alloc] initWithTitle:@"" message:@"Please select one or more categories." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
        
        }
        
        
        
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self onSet:nil];
    }
}

- (IBAction)changeSwitchSet:(UISwitch*)sender
{
    BOOL bSet = sender.on;
    
    [viewSubAll setHidden:!bSet];
}

- (IBAction)onWithCategory:(id)sender
{
    WithCategoryController * vc;
    
    if (iPad) {
        vc = [[WithCategoryController alloc] initWithNibName:@"WithCategoryController-ipad" bundle:nil];
    } else {
        vc = [[WithCategoryController alloc] initWithNibName:@"WithCategoryController" bundle:nil];
    }
    vc.m_nMode = MODE_NOTIFY;
    [self.navigationController pushViewController:vc animated:YES];

}
- (IBAction)changeRadius:(UISlider*)sender
{
    int value = sender.value;
    int radius = 1;
    switch (value) {
        case 0:
            radius = 1;
            break;
        case 1:
            radius = 2;
            break;
        case 2:
            radius = 5;
            break;
        case 3:
            radius = 10;
            break;
    }
    
    lbRadius.text = [NSString stringWithFormat:@"%d", radius];
    
    [Notification setDistance:radius];
}
- (IBAction)changeScan:(UISlider*)sender
{
    int value = sender.value;
    int minute = 1;
    switch (value) {
        case 0:
            minute = 1;
            break;
        case 1:
            minute = 3;
            break;
        case 2:
            minute = 5;
            break;
        case 3:
            minute = 10;
            break;
        case 4:
            minute = 15;
            break;
        case 5:
            minute = 30;
            break;
        case 6:
            minute = 60;
            break;
    }

    lbMin.text = [NSString stringWithFormat:@"%d", minute	];

    [Notification setMinute:minute];
}

- (IBAction)changeSet:(UISlider*)sender
{
    int value = sender.value;
    lbHour.text = [NSString stringWithFormat:@"%d", value];
    
    [Notification setDuration:value];
}
- (IBAction)onSet:(id)sender
{
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setNotifyTabbar : YES];
    [Notification setNotify:YES];
    
    [appDelegate stopScanThread];
    [appDelegate startScanThread];

    [self dismissModalViewControllerAnimated:YES];
}


- (void)performAction{
    if (YES) {
        [[UIApplication sharedApplication] addStatusBarImageNamed:@"Default_EN.png"];
    }
    else {
        [[UIApplication sharedApplication] addStatusBarImageNamed:@"Default_EC.png"];
        
    }
}


@end
