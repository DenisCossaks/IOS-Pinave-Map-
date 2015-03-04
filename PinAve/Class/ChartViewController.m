//
//  ChartViewController.m
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChartViewController.h"
#import "ContactViewController.h"
#import "OnlineViewController.h"

#import "UsersPool.h"
#import "SBJSON.h"


#define TAG_NAME    4000
#define TAG_DATE    5000
#define TAG_MESSAGE 6000


//static NSString *kImageName     = @"imagename";
static NSString *kFirst_Name     = @"firstname";
static NSString *kLast_Name      = @"lastname";


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


@interface ChartViewController ()
{
    BOOL isLoading;
    NSMutableDictionary * userInfo;
}
- (void) getPublishChat;

@property (strong, nonatomic) EGORefreshTableHeaderView *refreshHeaderView;

@end




@implementation ChartViewController

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
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self           
                                                          action:@selector(gestureTapped:)]; 
    tapGesture.delegate = (id)self;
    tapGesture.numberOfTapsRequired = 1;
    [m_table addGestureRecognizer:tapGesture];
    
    isLoading = NO;
    
    CGRect tableFrame = m_table.frame;
    tableFrame.origin.y = -tableFrame.size.height;
    self.refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:tableFrame];
    self.refreshHeaderView.delegate = self;
    [m_table addSubview:self.refreshHeaderView];
    [self.refreshHeaderView refreshLastUpdatedDate];
    
    m_tvMsg.layer.cornerRadius = 5.0;

//    NSString * country = [[UserLocationManager sharedInstance] getUserCountry];
//    m_tfCountry.text = country;
    
    [self getUserInfo];
    
    m_bFirstPass = YES;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];

    if (!m_bFirstPass) {
        m_bFirstPass = YES;
        
        [UsersPool pool];
        [self getPublishChat];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)gestureTapped:(UIGestureRecognizer *)sender{
    if (!keyboardVisible) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [m_tvMsg resignFirstResponder];
        m_tvMsg.text = @"";
    }
}

-(void) keyboardDidShow: (NSNotification *)notif 
{
    if (keyboardVisible) 
	{
		return;
	}
	
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    m_viewMsg.frame = CGRectMake(0, 210, m_viewMsg.frame.size.width, m_viewMsg.frame.size.height);
    m_table.frame = CGRectMake(0, 62, 320, 314 - 165);
    [UIView commitAnimations];
		
	// Keyboard is now visible
	keyboardVisible = YES;
    
    if ([arrPublishChart count] != 0) {
        [m_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([arrPublishChart count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void) keyboardDidHide: (NSNotification *)notif 
{
	// Is the keyboard already shown
	if (!keyboardVisible) 
	{
		return;
	}
	
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    m_viewMsg.frame = CGRectMake(0, 376, m_viewMsg.frame.size.width, m_viewMsg.frame.size.height);
    m_table.frame = CGRectMake(0, 62, 320, 314);
    
    [UIView commitAnimations];
	
	// Keyboard is no longer visible
	keyboardVisible = NO;
}

- (void) getUserInfo
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * _userId = [defaults objectForKey:@"loginId"];

    NSString *urlString = [Utils getUserURL:_userId];
    
    NSString *pinResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];

    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    id result = [JSonParser objectWithString:pinResult];
    
    userInfo = [[NSMutableDictionary alloc] initWithCapacity:10];
    userInfo = [result objectForKey: @"user"];
}


- (void) getPublishChat {
    if (isLoading) {
        return;
    }

    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];
    
    arrPublishChart = nil;
    
    isLoading = YES;

    NSString *urlString = [Utils getPublishListURL];
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
        
    if (result == nil)
        return;
        
//    arrPublishChart = [[NSMutableArray alloc] initWithArray:[result allValues]];
    if (arrPublishChart != nil) {
        [arrPublishChart removeAllObjects];
    }
    arrPublishChart = [[NSMutableArray alloc] initWithArray:result];
    
    [m_table reloadData];
    
    [[SHKActivityIndicator currentIndicator] hide];
}



#pragma mark ------ 

-(IBAction) onMyAvenue:(id)sender
{
    ContactViewController * vc = [[ContactViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
-(IBAction) onUsers:(id)sender
{
    NSLog(@"userInfo = %@", userInfo);
    
    OnlineViewController * vc = [[OnlineViewController alloc] init];
    vc.userInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
    
    
    [self.navigationController pushViewController:vc animated:YES];
    
}
-(IBAction) onChangeLocation:(id)sender
{
    
}

-(IBAction) onSendMsg:(id)sender
{
    NSString* _message = m_tvMsg.text;
    if (_message.length < 1) {
        return;
    }
    
    NSString * _userId = [userInfo objectForKey:@"id"];
    
    NSString * _date = [Utils getDateString:[NSDate date] :DATE_FULL];
    
    
    NSMutableDictionary * dicMsg = [[NSMutableDictionary alloc] initWithCapacity:3];
    [dicMsg setObject:_userId forKey:@"user_id"];
    [dicMsg setObject:_date   forKey:@"updated_at"];
    [dicMsg setObject:_message forKey:@"message"];
    
    [arrPublishChart addObject:dicMsg];
    
    [m_table reloadData];

    ////////////////// POST
    
    NSString *url = [Utils getChatSendText];
    NSLog(@"publish msg URL = %@", url);
    
    IAMultipartRequestGenerator *request = [[IAMultipartRequestGenerator alloc] initWithUrl:url andRequestMethod:@"POST"];
    
    [request setString:[userInfo objectForKey:@"chatcode"] forField:@"code"];
    NSLog(@"code = %@", [userInfo objectForKey:@"chatcode"]);
    
    [request setString:_message forField:@"message[message]"];
    NSLog(@"message[message] = %@", _message);
    
    [request setString:[userInfo objectForKey:@"id"] forField:@"message[user_id]"];
    NSLog(@"message[user_id] = %@", [userInfo objectForKey:@"id"]);
    
    
    // public chat
    [request setString:nil forField:@"message[recepient_id]"];
    NSLog(@"message[recepient_id] = %@", @"");
    
    [request setDelegate:self];
    [request startRequest];
    
    [m_tvMsg resignFirstResponder];
    m_tvMsg.text = @"";
}



#pragma mark
#pragma mark IAMultipartRequestGenerator delegate methods

-(void)requestDidFailWithError:(NSError *)error 
{
    NSLog(@"IAMultipartRequestGenerator request failed");
    
}


-(void)requestDidFinishWithResponse:(NSData *)responseData 
{
    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"IAMultipartRequestGenerator finished: %@", response);
    
}

-(IBAction) onKeyboardDone:(id)sender
{
    
}

#pragma mark ----------  Search Bar

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
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
	[self getPublishChat];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrPublishChart count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary * item = [arrPublishChart objectAtIndex:indexPath.row];
    NSString* message  = [item objectForKey:@"message"];
    
    int line = [message length] / 50;
  
    return 30 + 20 * (line + 1);
//    return 30 + 16  + ((line == 0) ? 0 : 10 * line);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CellIdentify";

    UILabel * lbName, *lbDate, *lbMsg;
    
    UITableViewCell *cell ;//= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UIImageView * background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableCell_back"]];
        cell.backgroundView = background;
        

        lbName  = (UILabel*)[cell.contentView viewWithTag:TAG_NAME + indexPath.row];
        if(lbName == nil)
        {
            lbName = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 223, 30)];
            lbName.tag = TAG_NAME + indexPath.row;
            lbName.backgroundColor = [UIColor clearColor];
            lbName.font = [UIFont boldSystemFontOfSize:16];
            lbName.textColor = [UIColor blackColor];
            [cell.contentView addSubview:lbName];
        }
        
        lbDate  = (UILabel*)[cell.contentView viewWithTag:TAG_DATE + indexPath.row];
        if(lbDate == nil)
        {
            lbDate = [[UILabel alloc] initWithFrame:CGRectMake(250, 0, 82, 30)];
            lbDate.tag = TAG_DATE + indexPath.row;
            lbDate.backgroundColor = [UIColor clearColor];
            lbDate.font = [UIFont systemFontOfSize:14];
            lbDate.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
            [cell.contentView addSubview:lbDate];
        }
        
        lbMsg  = (UILabel*)[cell.contentView viewWithTag:TAG_MESSAGE + indexPath.row];
        if(lbMsg == nil)
        {
            lbMsg = [[UILabel alloc] initWithFrame:CGRectMake(5, 28, 310, 16)];
            lbMsg.tag = TAG_MESSAGE + indexPath.row;
            lbMsg.backgroundColor = [UIColor clearColor];
            lbMsg.font = [UIFont systemFontOfSize:13];
            lbMsg.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
            [lbMsg setNumberOfLines:0];
            [lbMsg setLineBreakMode:UILineBreakModeWordWrap];
            [cell.contentView addSubview:lbMsg];
        }
        
    }
    
    NSMutableDictionary * item = [arrPublishChart objectAtIndex:indexPath.row];

    lbName.text = [self getUserName:[[item objectForKey:@"user_id"] intValue]];  //[NSString stringWithFormat:@"%d", [[item objectForKey:@"user_id"] intValue]];
    
    
    lbDate.text = [Utils getTimeFilter:[item objectForKey:@"updated_at"]];
    
    lbMsg.text  = [item objectForKey:@"message"];
    int line = [lbMsg.text length] / 50;
    lbMsg.frame = CGRectMake(5, 28, 310, 20 * (line + 1));
//    [lbMsg sizeToFit];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSString*) getUserName:(int) _userId
{
    for (NSMutableDictionary * dic in [UsersPool pool].userList)
    {
        NSString* strUserId = [dic objectForKey:@"id"];
        if ([strUserId isEqualToString:[NSString stringWithFormat:@"%d", _userId]]) {
//            NSLog(@"dic = %@", dic);
            
            NSString * name = [NSString stringWithFormat:@"%@ %@", [dic objectForKey:kFirst_Name], [dic objectForKey:kLast_Name]];
            return name;
        }
    }
    
    return @"";
}


@end
