//
//  SettingViewController.m
//  PinAve
//
//  Created by Gold Luo on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"

#import "MyDetailsController.h"
#import "PinSettingViewController.h"
#import "HelpCategoryViewController.h"
#import "HelpPlacePinViewController.h"
#import "HelpNotifyViewController.h"
#import "PrivacyController.h"
#import "HelpMessageViewController.h"
#import "UserSession.h"
#import "AboutController.h"
#import "SetMapViewController.h"
#import "SetUnitViewController.h"
#import "InstructionViewController.h"

@interface SettingViewController ()


@end

static NSString *kSectionName   = @"sectionNameKey";
static NSString *kRowData       = @"rowDataKey";
static NSString *kImageName     = @"imagename";
static NSString *kName     = @"name";

#define TAG_LOGOUT      10002

@implementation SettingViewController

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
    
    NSMutableArray *sections = [NSMutableArray array];
    
    [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Message Centre", kSectionName, 
                         [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"SettingProfile128a.png", kImageName, @"Profile", kName,nil], 
                                                    [NSDictionary dictionaryWithObjectsAndKeys:@"PinSettings128.png", kImageName, @"Pin Setting", kName,nil], 
                                                    [NSDictionary dictionaryWithObjectsAndKeys:@"SettingMapView128.png", kImageName, @"Map View", kName,nil], 
                                                    [NSDictionary dictionaryWithObjectsAndKeys:@"SettingUnit128.png", kImageName, @"Unit Setting", kName,nil], 
                                                    nil ],
                          kRowData, nil]];

    [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"About Centre", kSectionName, 
                         [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"SettingCategories128.png", kImageName, @"Category Definitions", kName,nil], 
                                                    [NSDictionary dictionaryWithObjectsAndKeys:@"SettingHowPlace128.png", kImageName, @"How to place pins", kName,nil], 
                                                    [NSDictionary dictionaryWithObjectsAndKeys:@"SettingNotification128.png", kImageName, @"About Notifications", kName,nil], 
                                                    [NSDictionary dictionaryWithObjectsAndKeys:@"SettingMessage128.png", kImageName, @"About Messages", kName,nil],
                                                    [NSDictionary dictionaryWithObjectsAndKeys:@"SettingIntro.png", kImageName, @"Introduction", kName,nil],
                                                    [NSDictionary dictionaryWithObjectsAndKeys:@"SettingVideo128.png", kImageName, @"PinAve Video", kName,nil],
                                                     nil],
                          kRowData, nil]];

    [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"About Centre", kSectionName, 
                         [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"SettingLogout128.png", kImageName, @"Log Out", kName,nil], 
                          nil],
                         kRowData, nil]];

    sectionAry = [NSArray arrayWithArray:sections];

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

- (void) viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = YES;
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:NO animated:YES];
}


#pragma ---- UITableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sectionAry count];
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[sectionAry objectAtIndex:section] objectForKey:kSectionName];
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = [[[sectionAry objectAtIndex:section] objectForKey:kRowData] count];
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MenuCell";
    
    UIImageView * imgView;
    UILabel * label;
    
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        

        if (iPad) {
            imgView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 3, 54, 54)];
        } else {
            imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 3, 40, 40)];
        }
        imgView.tag = 123;
        [cell addSubview:imgView];
        
        if (iPad) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 768-100, cell.frame.size.height)];
        } else {
            label = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 320-80, cell.frame.size.height)];
        }
        label.backgroundColor = [UIColor clearColor];
        label.tag = 124;
        [cell addSubview:label];

    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    NSDictionary * dic = [[[sectionAry objectAtIndex:indexPath.section] objectForKey:kRowData] objectAtIndex:indexPath.row];

    NSString * imageName = [dic objectForKey:kImageName];
    NSString * name = [dic objectForKey:kName];
    
    if (imgView == nil) {
        imgView = (UIImageView*) [cell viewWithTag:123];
    }
    [imgView setImage:[UIImage imageNamed:imageName]];
    
    
    if (label == nil) {
        label = (UILabel*) [cell viewWithTag:124];
    }
    label.text = name;
    
    return cell;
}

#pragma ---- UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch ([indexPath section]) {
        case 0:
            switch ([indexPath row]) {
                case 0:{
                    MyDetailsController * vc;
                    
                    if (iPad) {
                        vc = [[MyDetailsController alloc] initWithNibName:@"MyDetailsController-ipad" bundle:nil];
                    } else {
                        vc = [[MyDetailsController alloc] initWithNibName:@"MyDetailsController" bundle:nil];
                    }
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    break;
                }
                case 1:{
                    PinSettingViewController * vc;
                    
                    if (iPad) {
                        vc = [[PinSettingViewController alloc] initWithNibName:@"PinSettingViewController-ipad" bundle:nil];
                    } else {
                        vc = [[PinSettingViewController alloc] initWithNibName:@"PinSettingViewController" bundle:nil];
                    }
                    
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    break;
                }
                case 2:{
                    SetMapViewController * vc;
                    
                    if (iPad) {
                        vc = [[SetMapViewController alloc] initWithNibName:@"SetMapViewController-ipad" bundle:nil];
                    } else {
                        vc = [[SetMapViewController alloc] initWithNibName:@"SetMapViewController" bundle:nil];
                    }
                    
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    break;
                }
                case 3:{
                    SetUnitViewController * vc;
                    
                    if (iPad) {
                        vc = [[SetUnitViewController alloc] initWithNibName:@"SetUnitViewController-ipad" bundle:nil];
                    } else {
                        vc = [[SetUnitViewController alloc] initWithNibName:@"SetUnitViewController" bundle:nil];
                    }
                    
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    break;
                }
            }
            break;
            
        case 1:
            switch ([indexPath row]) {
                case 0:{
                    HelpCategoryViewController * vc;
                    
                    if (iPad) {
                        vc = [[HelpCategoryViewController alloc] initWithNibName:@"HelpCategoryViewController-ipad" bundle:nil];
                    } else {
                        vc = [[HelpCategoryViewController alloc] initWithNibName:@"HelpCategoryViewController" bundle:nil];
                    }
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    break;
                }
                case 1:{
                    HelpPlacePinViewController * vc;
                    
                    if (iPad) {
                        vc = [[HelpPlacePinViewController alloc] initWithNibName:@"HelpPlacePinViewController-ipad" bundle:nil];
                    } else {
                        vc = [[HelpPlacePinViewController alloc] initWithNibName:@"HelpPlacePinViewController" bundle:nil];
                    }
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    break;
                }
                case 2:{
                    HelpNotifyViewController * vc;
                    
                    if (iPad) {
                        vc = [[HelpNotifyViewController alloc] initWithNibName:@"HelpNotifyViewController-ipad" bundle:nil];
                    } else {
                        vc = [[HelpNotifyViewController alloc] initWithNibName:@"HelpNotifyViewController" bundle:nil];
                    }
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    break;
                }
                case 3:{
                    HelpMessageViewController * vc;
                    
                    if (iPad) {
                        vc = [[HelpMessageViewController alloc] initWithNibName:@"HelpMessageViewController-ipad" bundle:nil];
                    } else {
                        vc = [[HelpMessageViewController alloc] initWithNibName:@"HelpMessageViewController" bundle:nil];
                    }
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    break;
                }
                case 4:{
                    
                    InstructionViewController * vc = [[InstructionViewController alloc] initWithNibName:@"InstructionViewController" bundle:nil];
                    
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    break;
                }
                case 5:{
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://youtu.be/mGLR--JM5HQ"]];
                    
                    break;
                }

            }
            break;
            
        case 2:
            switch ([indexPath row]) {
                case 0:{
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure?"
                                                                    delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
                    alert.tag = TAG_LOGOUT;
                    [alert show];
                    
                    break;
                }
            }
            break;
            
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (IBAction) onAbout:(id)sender
{
    AboutController * vc;
    
    if (iPad) {
        vc = [[AboutController alloc] initWithNibName:@"AboutController-ipad" bundle:nil];
    } else {
        vc = [[AboutController alloc] initWithNibName:@"AboutController" bundle:nil];
    }
    
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == TAG_LOGOUT) {
        if (buttonIndex == 0) { // cancel
            
        } else if (buttonIndex == 1) { // logout
            
            [[SHKActivityIndicator currentIndicator] displayActivity:@"Log Out" : self];
            
            [UserSession session].delegate = self;
            [[UserSession session] logout];
        }
    }
}

#pragma mark -----
-(void) logoutSuccess {
    [[SHKActivityIndicator currentIndicator] hide];
    
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.viewController gotoHomePage];
}
-(void) logoutFail{
    [[SHKActivityIndicator currentIndicator] hide];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Fail" message:@"Log out is fail!"
                                                    delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}


@end
