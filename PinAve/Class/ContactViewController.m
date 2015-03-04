//
//  ContactViewController.m
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactViewController.h"
#import "JsonReader.h"

#import "ChatBoardController.h"
#import "PinDetailController.h"
#import "FriendViewController.h"


static NSString *kFistName      = @"first_name";
static NSString *kLastName      = @"first_name";

enum TAG_TABLE {
    TAG_ICON = 12000,
    TAG_NAME,
    TAG_ADDRESS,
    };

@interface NSDictionary (SortingUser)

- (NSComparisonResult) compareAvenueUser:(NSDictionary *)other;

@end

@implementation NSDictionary (SortingUser)
- (NSComparisonResult) compareAvenueUser:(NSDictionary *)other
{
    NSString *nameOwn = [self objectForKey:kFistName];
    NSString *nameOther = [other objectForKey:kLastName];
    
    return [nameOwn compare:nameOther];
}

@end


@interface ContactViewController ()
{
    BOOL isLoading;
    NSMutableDictionary * userInfo;
}
- (void) getUserList;

@property (strong, nonatomic) EGORefreshTableHeaderView *refreshHeaderView;

@end




@implementation ContactViewController

@synthesize refreshHeaderView;

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
    
    
    isLoading = NO;
    
    CGRect tableFrame = m_table.frame;
    tableFrame.origin.y = -tableFrame.size.height;
    self.refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:tableFrame];
    self.refreshHeaderView.delegate = self;
    [m_table addSubview:self.refreshHeaderView];
    [self.refreshHeaderView refreshLastUpdatedDate];
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

    [m_table setContentOffset:CGPointMake(0, 44)];

    [self getUserList];

}


- (void) getUserList {
    if (isLoading) {
        return;
    }

    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];
    
    isLoading = YES;
    
    NSString *urlString = [Utils getMyAvenueUsersUrl];
    JsonReader *jsonReader = [[JsonReader alloc] initWithUrl:urlString delegate:self];
    [jsonReader read];
    
}

- (void)didJsonReadFail
{
    [[[UIAlertView alloc] initWithTitle:@"" message:@"Oops! We seem to be experiencing a system overload. Please try again in a few minute." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
- (void)didJsonRead:(id)result
{
    isLoading = NO;
    [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:m_table];
    
    NSDictionary *userResult = result;
    if (!userResult) {
        return;
    }
    
    NSString * retOK = [userResult objectForKey:@"message"];
    if ([retOK isEqualToString:@"OK"]) {
//        NSArray * users = [[userResult objectForKey:@"friends"] allValues];
//        NSArray * pins = [[userResult objectForKey:@"pins"] allValues];
        NSArray * users = [userResult objectForKey:@"friends"];
        NSArray * pins = [userResult objectForKey:@"pins"];

        
        [Share getInstance].allAvenueUsers = [[NSMutableArray alloc] initWithArray:users];
        [[Share getInstance].allAvenueUsers sortUsingSelector:@selector(compareAvenueUser:)];

        [Share getInstance].allAvenuePins = [[NSMutableArray alloc] initWithArray:pins];
        
        arrSearch = [[NSMutableArray alloc] initWithArray:pins];
    } else {
        [Share getInstance].allAvenueUsers = nil;
        [Share getInstance].allAvenuePins = nil;
        arrSearch = nil;
    }
    

    [m_table reloadData];
    
    [[SHKActivityIndicator currentIndicator] hide];
}



#pragma mark ------ 

- (IBAction)onGroupChart:(id)sender
{
    
}

-(IBAction) onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark ----------  Search Bar

- (void) textSearch : (NSString*) _search
{
    [arrSearch removeAllObjects];
    
    for (NSMutableDictionary * item in [Share getInstance].allAvenuePins) {
        NSString * name = [item objectForKey:@"title"];
        
        if ([name rangeOfString:_search].location != NSNotFound) {
            [arrSearch addObject:item];
        }
    }
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    [theSearchBar setShowsCancelButton:YES animated:YES];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{   
    searchBar.text = nil; 
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    

    arrSearch = [NSMutableArray arrayWithArray:[Share getInstance].allAvenuePins];
    
    [m_table reloadData];

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;

    [self textSearch:searchBar.text];
    [m_table reloadData];

}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text 
{
    NSString * _searchText = [NSString stringWithFormat:@"%@%@", searchBar.text , text];
    
    [self textSearch:_searchText];
    
    [m_table reloadData];
    
    return YES;
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
	[self getUserList];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
	return isLoading; // should return if data source model is reloading
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
	return [NSDate date]; // should return date data source was last changed
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
    return [arrSearch count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0f;
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
            iconCategory = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 38, 38)];
            iconCategory.tag = TAG_ICON + indexPath.row;
            [cell.contentView addSubview:iconCategory];
        }
        
        lbName  = (UILabel*)[cell.contentView viewWithTag:TAG_NAME + indexPath.row];
        
        if(lbName == nil)
        {
            lbName = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, 240, 44)];
            lbName.tag = TAG_NAME + indexPath.row;
            lbName.backgroundColor = [UIColor clearColor];
            lbName.numberOfLines = 2;
            [cell.contentView addSubview:lbName];
        }

        lbAddress  = (UILabel*)[cell.contentView viewWithTag:TAG_ADDRESS + indexPath.row];
        
        if(lbAddress == nil)
        {
            lbAddress = [[UILabel alloc] initWithFrame:CGRectMake(55, 40, 240, 14)];
            lbAddress.textAlignment = UITextAlignmentRight;
            lbAddress.font = [UIFont systemFontOfSize:10];
            lbAddress.tag = TAG_ADDRESS + indexPath.row;
            lbAddress.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:lbAddress];
        }
        
    }
    
    NSMutableDictionary * item = [arrSearch objectAtIndex:indexPath.row];

    iconCategory.image = nil;
    NSMutableDictionary * category = [item objectForKey:@"category"];
    for (NSMutableDictionary *dic in [Share getInstance].arrayCategory) {
        if ([[category objectForKey:@"id"] intValue] == [[dic objectForKey:@"id"] intValue]) {
            iconCategory.image = [Share getCategoryImageName:[dic objectForKey:@"name"]]; // [dic objectForKey:@"iconData"];
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
    
    NSMutableDictionary * item = [arrSearch objectAtIndex:indexPath.row];

    NSString* strFull = [NSString stringWithFormat:@"%@ %@ %@", [item objectForKey:@"address"], [item objectForKey:@"city"], [item objectForKey:@"country"]];
    
    [item setObject:strFull forKey:@"full_address"];
    
    detailCtlr.pinInfo = item;
    
    [self.navigationController pushViewController:detailCtlr animated:YES];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)onUsers:(id)sender
{
    FriendViewController *vc;
    
    if (iPad) {
        vc = [[FriendViewController alloc] initWithNibName:@"FriendViewController-ipad" bundle:nil];
    } else {
        vc = [[FriendViewController alloc] initWithNibName:@"FriendViewController" bundle:nil];
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
