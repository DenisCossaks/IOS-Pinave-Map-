//
//  ContactViewController.m
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendViewController.h"
#import "ChatBoardController.h"
#import "AvenueDetailViewController.h"


enum TAG_TABLE {
    TAG_ICON = 12000,
    TAG_NAME,
    TAG_ADDRESS,
    };

#define kFirstName  @"first_name"
#define kLastName   @"last_name"


@interface NSDictionary (SortingBranches)

- (NSComparisonResult) compareByBranchCode:(NSDictionary *)other;

@end

@implementation NSDictionary (SortingBranches)
- (NSComparisonResult) compareByBranchCode:(NSDictionary *)other
{
    NSString *nameOwn = [self objectForKey:kFirstName];
    NSString *nameOther = [other objectForKey:kLastName];
    
    return [nameOwn compare:nameOther];
}

@end


@interface FriendViewController ()

@end




@implementation FriendViewController


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
 
    m_nDeletedIndex = -1;
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



#pragma mark ------ 

-(IBAction) onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark --------- table view delegate -------
/*
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    NSArray *alphaArray = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N"
                           ,@"O",@"P",@"R",@"S",@"T",@"U",@"V",@"X",@"Y",@"Z",nil];
    
    return alphaArray;
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[Share getInstance].allAvenueUsers count];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSMutableDictionary * item = [[Share getInstance].allAvenueUsers objectAtIndex:indexPath.row];
        NSLog(@"delete item = %@", item);
        
        m_nDeletedIndex = indexPath.row;
        
        [self userToAvenue: [[item objectForKey:@"id"] intValue]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CellIdentify";
    
    UILabel * lbName;
//    UILabel * lbCountry;
    
    UITableViewCell *cell ;//= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIImageView * background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_back"]];
        cell.backgroundView = background;
        
        lbName  = (UILabel*)[cell.contentView viewWithTag:TAG_NAME + indexPath.row];
        
        if(lbName == nil)
        {
            lbName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 44)];
            lbName.tag = TAG_NAME + indexPath.row;
            lbName.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:lbName];
        }

//        lbCountry  = (UILabel*)[cell.contentView viewWithTag:TAG_ADDRESS + indexPath.row];
//        if(lbCountry == nil)
//        {
//            lbCountry = [[UILabel alloc] initWithFrame:CGRectMake(55, 30, 250, 14)];
//            lbCountry.textAlignment = UITextAlignmentRight;
//            lbCountry.font = [UIFont systemFontOfSize:8];
//            lbCountry.tag = TAG_ADDRESS + indexPath.row;
//            lbCountry.backgroundColor = [UIColor clearColor];
//            [cell.contentView addSubview:lbCountry];
//        }
        
    }
    
    NSMutableDictionary * item = [[Share getInstance].allAvenueUsers objectAtIndex:indexPath.row];

    NSString * firstName = [item objectForKey:kFirstName];
    NSString * lastName  = [item objectForKey:kLastName];
    
    lbName.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
/*    
    ChatBoardController *vc;
    
    if (iPad) {
        vc = [[ChatBoardController alloc] initWithNibName:@"ChatBoardController-ipad" bundle:nil];
    } else {
        vc = [[ChatBoardController alloc] initWithNibName:@"ChatBoardController" bundle:nil];
    }
    
    NSMutableDictionary * item = [[Share getInstance].allAvenueUsers objectAtIndex:indexPath.row];
    
    vc.receiveInfo = item;
    vc.userInfo = (NSMutableDictionary*)[Share getInstance].userChatInfo;
    
    [self.navigationController pushViewController:vc animated:YES];
*/    
    AvenueDetailViewController *vc;
    
    if (iPad) {
        vc = [[AvenueDetailViewController alloc] initWithNibName:@"AvenueDetailViewController-ipad" bundle:nil];
    } else {
        vc = [[AvenueDetailViewController alloc] initWithNibName:@"AvenueDetailViewController" bundle:nil];
    }
    
    NSMutableDictionary * item = [[Share getInstance].allAvenueUsers objectAtIndex:indexPath.row];
    vc.user = item;
    
    [self.navigationController pushViewController:vc animated:YES];

    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


///////////// delete user
- (void) userToAvenue : (int) userId
{
    NSString * auth_code = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginCode"];
    
    NSString *url;
    
    url = [Utils postDeleteUserUrl: auth_code : userId];
    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"" : self];
    
    ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setDelegate:self];
    [request setRequestMethod:@"GET"];
    [request setDidFinishSelector:@selector(requestAddUserDone:)];
    [request setDidFailSelector:@selector(requestAddUserFailed:)];
    [request startAsynchronous];
    
}
- (void)requestAddUserDone:(ASIFormDataRequest*)request {
    
    NSLog(@"%@", [request responseString] );
    
    [[SHKActivityIndicator currentIndicator] hide];

    if (m_nDeletedIndex != -1) {
        [[Share getInstance].allAvenueUsers removeObjectAtIndex:m_nDeletedIndex];
        
        [m_table reloadData];
    }

    NSString * message = @"";
    message = @"The user has been removed into MyAvenue";
    
    [[[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
}

- (void)requestAddUserFailed:(ASIFormDataRequest*)request {
    
    NSLog(@"Failed");
    
    [[SHKActivityIndicator currentIndicator] hide];
    
    [[[UIAlertView alloc] initWithTitle:@"" message:@"Fail!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
}

@end
