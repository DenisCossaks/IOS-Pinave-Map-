//
//  OnlineViewController.m
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OnlineViewController.h"
#import "JsonReader.h"

#import "ChatBoardController.h"

static NSString *kFirst_Name     = @"first_name";
static NSString *kLast_Name      = @"last_name";


@interface NSDictionary (SortingBranches)

- (NSComparisonResult) compareByBranchCode:(NSDictionary *)other;

@end

@implementation NSDictionary (SortingBranches)
- (NSComparisonResult) compareByBranchCode:(NSDictionary *)other
{
    NSString *nameOwn = [self objectForKey:kFirst_Name];
    NSString *nameOther = [other objectForKey:kFirst_Name];
    
    return [nameOwn compare:nameOther];
}

@end


@interface OnlineViewController ()
{
    BOOL isLoading;
    NSMutableDictionary * userInfo;
}
- (void) getOnlineUserList;

@property (strong, nonatomic) EGORefreshTableHeaderView *refreshHeaderView;

@end




@implementation OnlineViewController

@synthesize refreshHeaderView;
@synthesize userInfo;


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
    
    [self getOnlineUserList];
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


- (void) getOnlineUserList {
    if (isLoading) {
        return;
    }

    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];
    
    arrChart = nil;
    
    isLoading = YES;
    
    NSString * userCode = [self.userInfo objectForKey:@"chatcode"];
    NSString *urlString = [Utils getOnlineUsersUrl:userCode];
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
    
//    NSDictionary *users = [userResult objectForKey:@"users"];
//    NSArray *userList = [users allValues];
    NSArray * userList = [[NSArray alloc] initWithArray:result];
 
    arrChart = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (NSMutableDictionary * dic in userList) {
        [arrChart addObject:dic];
    }
    
    arrSearch = [[NSMutableArray alloc] initWithArray:arrChart];

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
    
    for (NSMutableDictionary * item in arrChart) {
        NSString * name = [NSString stringWithFormat:@"%@ %@", [item objectForKey:kFirst_Name], [item objectForKey:kLast_Name]];
        
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
    

    arrSearch = [NSMutableArray arrayWithArray:arrChart];
    
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
	[self getOnlineUserList];
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
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    NSArray *alphaArray = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N"
                           ,@"O",@"P",@"R",@"S",@"T",@"U",@"V",@"X",@"Y",@"Z",nil];
    
    return alphaArray;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrSearch count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CellIdentify";
    UIImageView * iconCategory;
    UILabel * lbCategory;
    
    UITableViewCell *cell ;//= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIImageView * background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_back"]];
        cell.backgroundView = background;
        
        iconCategory = (UIImageView*)[cell.contentView viewWithTag:9000 + indexPath.row];
        
        if(iconCategory == nil)
        {
            iconCategory = [[UIImageView alloc] initWithFrame:CGRectMake(10, 3, 38, 38)];
            iconCategory.tag = 9000 + indexPath.row;
            [cell.contentView addSubview:iconCategory];
        }
        
        lbCategory  = (UILabel*)[cell.contentView viewWithTag:10000 + indexPath.row];
        
        if(lbCategory == nil)
        {
            lbCategory = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 280, 44)];
            lbCategory.tag = 10000 + indexPath.row;
            lbCategory.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:lbCategory];
        }
        
    }
    
    NSMutableDictionary * item = [arrSearch objectAtIndex:indexPath.row];
    
//    iconCategory.image = [UIImage imageNamed:[item objectForKey:kImageName]];
    lbCategory.text =    [NSString stringWithFormat:@"%@ %@", [item objectForKey:kFirst_Name], [item objectForKey:kLast_Name]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatBoardController * vc;
    
    if (iPad) {
        vc = [[ChatBoardController alloc] initWithNibName:@"ChatBoardController-ipad" bundle:nil];
    } else {
        vc = [[ChatBoardController alloc] initWithNibName:@"ChatBoardController" bundle:nil];
    }
    
    [self.navigationController pushViewController:vc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableDictionary * item = [arrSearch objectAtIndex:indexPath.row];

    vc.receiveInfo = [[NSMutableDictionary alloc] initWithDictionary:item];

    vc.userInfo    = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
    
}


@end
