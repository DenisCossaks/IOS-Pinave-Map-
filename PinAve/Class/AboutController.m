//
//  AboutController.m
//  PinAve
//
//  Created by Gold Luo on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AboutController.h"
#import "PrivacyController.h"
#import "TermsServiceController.h"


static NSString *kSectionName   = @"sectionNameKey";
static NSString *kRowData       = @"rowDataKey";

@interface AboutController ()

- (void)gotoReviews;

@end

@implementation AboutController

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
    
    [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Message Centre", kSectionName, [NSArray arrayWithObjects:@"Send Feedback", nil], kRowData, nil]];
    
    [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Help Centre", kSectionName, [NSArray arrayWithObjects:@"Terms of Service", @"Privacy Policy", nil], kRowData, nil]];
    [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Settings", kSectionName, [NSArray arrayWithObjects:@"Rate Pinave.", nil], kRowData, nil]];
    [sections addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Version", kSectionName, [NSArray arrayWithObjects:@"Version", nil], kRowData, nil]];
    
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

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:NO animated:YES];
}


- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    
       UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (indexPath.section == 3) {
            cell.backgroundColor = [UIColor clearColor];
        } 
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = [[[sectionAry objectAtIndex:indexPath.section] objectForKey:kRowData] objectAtIndex:indexPath.row];

    if (indexPath.section == 3) {
        cell.textLabel.text = [NSString stringWithFormat:@"Version %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType =  UITableViewCellAccessoryNone;
    } 

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
                    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
                    
                    NSString *subject = [NSString stringWithFormat:@"Feedback(%@)", version];
                    
                    NSArray* emails = [[NSArray alloc] initWithObjects:@"support@pinave.com", nil];
                    
                    if(![MFMailComposeViewController canSendMail]){
                        [[[UIAlertView alloc] initWithTitle:nil message:@"Please configure your mail settings to send email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        return;
                    }
                    
                    MFMailComposeViewController* mc = [[MFMailComposeViewController alloc] init];
                    mc.mailComposeDelegate = self;
                    [mc setSubject:subject];	
                    [mc setToRecipients:emails];	
//                    [mc setMessageBody:body isHTML:YES];	
                    
                    [self presentModalViewController:mc animated:YES];

                    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate setTabBarHidden:YES animated:YES];

                    break;
                }
                case 1:{
                    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
                    
                    NSString *subject = [NSString stringWithFormat:@"Help!(%@)", version];
                    
                    NSArray* emails = nil;
                    
                    if(![MFMailComposeViewController canSendMail]){
                        [[[UIAlertView alloc] initWithTitle:nil message:@"Please configure your mail settings to send email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        return;
                    }
                    
                    MFMailComposeViewController* mc = [[MFMailComposeViewController alloc] init];
                    mc.mailComposeDelegate = self;
                    [mc setSubject:subject];	
                    [mc setToRecipients:emails];	
//                    [mc setMessageBody:body isHTML:YES];	
                    
                    
                    [self presentModalViewController:mc animated:YES];

                    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate setTabBarHidden:YES animated:YES];

                    break;
                }
            }
            break;
            
        case 1:
            switch ([indexPath row]) {
                case 0:{
                    TermsServiceController * vc;
                    
                    if (iPad) {
                        vc = [[TermsServiceController alloc] initWithNibName:@"TermsServiceController-ipad" bundle:nil];
                    } else {
                        vc = [[TermsServiceController alloc] initWithNibName:@"TermsServiceController" bundle:nil];
                    }
                    vc.m_bMode = YES;
                    
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    break;
                }
                case 1:{
                    PrivacyController * vc;
                    
                    if (iPad) {
                        vc = [[PrivacyController alloc] initWithNibName:@"PrivacyController-ipad" bundle:nil];
                    } else {
                        vc = [[PrivacyController alloc] initWithNibName:@"PrivacyController" bundle:nil];
                    }
                    vc.m_bMode = YES;
                    
                    [self.navigationController pushViewController:vc animated:YES];

                }
            }
            break;
            
        case 2:
            switch ([indexPath row]) {
                case 0:{
                    [self gotoReviews];
                    break;
                }
            }
            
            break;
            
        case 3:
            
            break;
            
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    switch (result) {
        case MFMailComposeResultSent:	
            [[[UIAlertView alloc] initWithTitle:nil message:@"Feedback was sent!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            break;
        default:
            break;
    }
    [self dismissModalViewControllerAnimated:YES];	
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:NO animated:YES];

}

- (void)gotoReviews{
    NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa";
    str = [NSString stringWithFormat:@"%@/wa/viewContentsUserReviews?", str]; 
    str = [NSString stringWithFormat:@"%@type=Purple+Software&id=", str];
    
    // Here is the app id from itunesconnect
    str = [NSString stringWithFormat:@"%@437859993", str]; 
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
}

@end
