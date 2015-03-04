//
//  ContactViewController.m
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AvenueDetailViewController.h"

#import "PinDetailController.h"

enum TAG_TABLE {
    TAG_ICON = 12000,
    TAG_NAME,
    TAG_ADDRESS,
    };



@interface AvenueDetailViewController ()
{
    int nJSON_STATE;
}

@end


@implementation AvenueDetailViewController

@synthesize user;


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

    [self getUserInfo];
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

    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:NO animated:YES];

}


- (void) getUserInfo {

    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];
    
    nJSON_STATE = 0;
    NSString *urlString = [Utils getUserURL:[self.user objectForKey:@"id"]];
    JsonReader *jsonReader = [[JsonReader alloc] initWithUrl:urlString delegate:self];
    [jsonReader read];
    
}

- (void)didJsonReadFail
{
    [[[UIAlertView alloc] initWithTitle:@"" message:@"Oops! We seem to be experiencing a system overload. Please try again in a few minute." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)didJsonRead:(id)result
{
    
    NSDictionary *userResult = result;
    
    if (nJSON_STATE == 0) {
        if (userResult != nil) {
            NSString * retOK = [userResult objectForKey:@"message"];
            if ([retOK isEqualToString:@"OK"]) {
                userInfo = [[NSMutableDictionary alloc] initWithDictionary:[userResult objectForKey:@"user"]];
            }
        }
        
        nJSON_STATE = 1;
        NSString *urlString = [Utils getPinForUserUrl1:[self.user objectForKey:@"id"]];
        JsonReader *jsonReader = [[JsonReader alloc] initWithUrl:urlString delegate:self];
        [jsonReader read];

    }
    else if (nJSON_STATE == 1) {
        if (userResult != nil) {
            userPins = [[NSMutableArray alloc] initWithArray:[[userResult objectForKey:@"categories"] allValues]];
        }

//        NSLog(@"userPins = %@", userPins);
        
        [self setInterface];
    }

}

-(void) setInterface {
    lbTitle.text = [NSString stringWithFormat:@"%@ %@", [userInfo objectForKey:@"firstname"], [userInfo objectForKey:@"lastname"]];
    lbLocation.text = [[userInfo objectForKey:@"detail"] objectForKey:@"country"];
    lbTimezone.text = [[userInfo objectForKey:@"detail"] objectForKey:@"timezone"];
    lbLogin.text = [userInfo objectForKey:@"last_activity"];
    
    [m_table reloadData];
    
    [[SHKActivityIndicator currentIndicator] hide];

}

#pragma mark ------ 


-(IBAction) onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark --------- table view delegate -------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userPins count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CellIdentify";
    UIImageView * iconCategory;
    UILabel * lbName;
    UILabel * lbAddress;
    
    UITableViewCell *cell ;//= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIImageView * background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_back"]];
        cell.backgroundView = background;
        
        iconCategory = (UIImageView*)[cell.contentView viewWithTag:TAG_ICON + indexPath.row];
        
        if(iconCategory == nil)
        {
            iconCategory = [[UIImageView alloc] initWithFrame:CGRectMake(10, 3, 38, 38)];
            iconCategory.tag = TAG_ICON + indexPath.row;
            [cell.contentView addSubview:iconCategory];
        }
        
        lbName  = (UILabel*)[cell.contentView viewWithTag:TAG_NAME + indexPath.row];
        
        if(lbName == nil)
        {
            lbName = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, 240, 30)];
            lbName.tag = TAG_NAME + indexPath.row;
            lbName.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:lbName];
        }

        lbAddress  = (UILabel*)[cell.contentView viewWithTag:TAG_ADDRESS + indexPath.row];
        
        if(lbAddress == nil)
        {
            lbAddress = [[UILabel alloc] initWithFrame:CGRectMake(55, 30, 250, 14)];
            lbAddress.textAlignment = UITextAlignmentRight;
            lbAddress.font = [UIFont systemFontOfSize:8];
            lbAddress.tag = TAG_ADDRESS + indexPath.row;
            lbAddress.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:lbAddress];
        }
        
    }
    
    NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:2];

    NSArray * pins = [[userPins objectAtIndex:indexPath.row] objectForKey:@"pins"];
    for (NSDictionary *pinItem in pins) {
        item = [NSMutableDictionary dictionaryWithDictionary:pinItem];
        break;
    }

    
    
    NSLog(@"item = %@", item);
    
    iconCategory.image = nil;

    
    for (NSMutableDictionary *dic in [Share getInstance].arrayCategory) {
        if ([[item objectForKey:@"category_id"] intValue] == [[dic objectForKey:@"id"] intValue]) {
            iconCategory.image = [Share getCategoryImageName:[dic objectForKey:@"name"]]; //[dic objectForKey:@"iconData"];
        }
    }
    
    lbName.text = [item objectForKey:@"title"];
    
    lbAddress.text = [NSString stringWithFormat:@"%@ %@ %@ Address:%@", 
                      [item objectForKey:@"country"], [item objectForKey:@"state"], [item objectForKey:@"city"],
                      [item objectForKey:@"address"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PinDetailController *detailCtlr;
    
    if (iPad) {
        detailCtlr = [[PinDetailController alloc] initWithNibName:@"PinDetailController-ipad" bundle:nil];
    } else {
        detailCtlr = [[PinDetailController alloc] initWithNibName:@"PinDetailController" bundle:nil];
    }
    
//    NSMutableDictionary * item = [userPins objectAtIndex:indexPath.row];

    NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    NSArray * pins = [[userPins objectAtIndex:indexPath.row] objectForKey:@"pins"];
    for (NSDictionary *pinItem in pins) {
        item = [NSMutableDictionary dictionaryWithDictionary:pinItem];
        break;
    }

    NSString* strFull = [NSString stringWithFormat:@"%@ %@ %@", [item objectForKey:@"address"], [item objectForKey:@"city"], [item objectForKey:@"country"]];
    
    [item setObject:strFull forKey:@"full_address"];
    
    detailCtlr.pinInfo = item;
    
    [self.navigationController pushViewController:detailCtlr animated:YES];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
