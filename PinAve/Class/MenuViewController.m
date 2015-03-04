//
//  MenuViewController.m
//  NEP
//
//  Created by Gold Luo on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuViewController.h"

#import "ReceivedController.h"
#import "SentController.h"
#import "NotificationsController.h"

#import "HelpCategoryViewController.h"
#import "HelpPlacePinViewController.h"
#import "HelpNotifyViewController.h"
#import "HelpMessageViewController.h"

#import "UserSession.h"
#import "MyDetailsController.h"
#import "PrivacyController.h"


@interface MenuViewController ()

@property (strong, nonatomic) NSArray *sectionAry;

@end

static NSString *kSectionName   = @"sectionNameKey";
static NSString *kRowData       = @"rowDataKey";

@implementation MenuViewController

@synthesize sectionAry;
@synthesize menuTbl;
@synthesize categoryAry;



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
    
    [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Message Centre", kSectionName, [NSArray arrayWithObjects:@"Messages", @"Notifications", nil], kRowData, nil]];
    
    [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Help Centre", kSectionName, [NSArray arrayWithObjects:@"Category Definitions", @"How to place pins", @"About Notifications"
                                                                                                  , @"About Messages", nil], kRowData, nil]];
    [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Settings", kSectionName, [NSArray arrayWithObjects:@"Log out", @"My Details", @"Privacy Settings", nil], kRowData, nil]];
    
    self.sectionAry = [NSArray arrayWithArray:sections];

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
}

#pragma ---- UITableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionAry count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.sectionAry objectAtIndex:section] objectForKey:kSectionName];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = [[[self.sectionAry objectAtIndex:section] objectForKey:kRowData] count];
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MenuCell";
 
/*    
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"MenuCell" owner:self options:nil];
        cell = self.creatingCell;
        self.creatingCell = nil;
    }
    
    // Configure the cell...
    if (indexPath.section == 1) {
        if (indexPath.row < [self.categoryAry count]) {
            NSDictionary *categoryItem = [self.categoryAry objectAtIndex:indexPath.row];
            cell.titleLbl.text = [categoryItem objectForKey:@"name"];
            UIImage *pinImg = [categoryItem objectForKey:@"iconData"];
            if ([pinImg isKindOfClass:[UIImage class]]) {
                cell.iconImg.image = pinImg;
            } else {
                cell.iconImg.image = nil;
            }
            BOOL isSelected = [[categoryItem objectForKey:@"selected"] boolValue];
            if (isSelected) {
                cell.selectedImg.image = [UIImage imageNamed:@"selected.png"];
            } else {
                cell.selectedImg.image = [UIImage imageNamed:@"unselected.png"];
            }
            cell.selectedImg.hidden = NO;
        } else {
            cell.titleLbl.text = [[[self.sectionAry objectAtIndex:indexPath.section] objectForKey:kRowData] objectAtIndex:(indexPath.row - [self.categoryAry count])];
            cell.iconImg.image = nil;
            cell.selectedImg.hidden = YES;
        }
    } else {
        cell.titleLbl.text = [[[self.sectionAry objectAtIndex:indexPath.section] objectForKey:kRowData] objectAtIndex:indexPath.row];
        cell.iconImg.image = nil;
        cell.selectedImg.hidden = YES;
    }
*/
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = [[[self.sectionAry objectAtIndex:indexPath.section] objectForKey:kRowData] objectAtIndex:indexPath.row];
    if (iPad) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:26];
    }
    
    
    
    return cell;
}

#pragma ---- UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    switch ([indexPath section]) {
        case 0:
            switch ([indexPath row]) {
                case 0:{
                    ReceivedController * vc = [[ReceivedController alloc] initWithNibName:@"ReceivedController" bundle:nil];
                    [self.navigationController pushViewController:vc animated:YES];
                
                    break;
                }
//                case 1:{
//                    SentController * vc = [[SentController alloc] init];
//                    [self.navigationController pushViewController:vc animated:YES];
//                    
//                    break;
//                }
                case 1:{
                    NotificationsController * vc;
                    
                    if (iPad) {
                        vc = [[NotificationsController alloc] initWithNibName:@"NotificationsController-ipad" bundle:nil];
                    } else {
                        vc = [[NotificationsController alloc] initWithNibName:@"NotificationsController" bundle:nil];
                    }
                    
                    vc.listCategory = self.categoryAry;
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
            }
            break;
            
        case 2:
            switch ([indexPath row]) {
                case 0:{
                    [[UserSession session] logout];
                    break;
                }
                case 1:{
                    MyDetailsController * vc;
                    
                    if (iPad) {
                        vc = [[MyDetailsController alloc] initWithNibName:@"MyDetailsController-ipad" bundle:nil];
                    } else {
                        vc = [[MyDetailsController alloc] initWithNibName:@"MyDetailsController" bundle:nil];
                    }
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    break;
                }
                case 2:{
                    PrivacyController * vc;
                    
                    if (iPad) {
                        vc = [[PrivacyController alloc] initWithNibName:@"PrivacyController-ipad" bundle:nil];
                    } else {
                        vc = [[PrivacyController alloc] initWithNibName:@"PrivacyController" bundle:nil];
                    }
                    vc.m_bMode = YES;
                    
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    break;
                }
            }
            break;

    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark ---- Button Event -----
-(IBAction)onBack:(id)sender {
//    [self.navigationController popViewControllerAnimated:NO];
    [self dismissModalViewControllerAnimated: YES];

}
@end
