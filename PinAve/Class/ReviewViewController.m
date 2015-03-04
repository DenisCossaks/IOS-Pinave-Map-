//
//  ReviewViewController.m
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReviewViewController.h"
#import "ASIFormDataRequest.h"

#import "SBJSON.h"
#import "SBJsonParser.h"
#import "UsersPool.h"
#import "JSON.h"

#import "GeoLocation.h"


#define TAG_NAME    4000
#define TAG_DATE    5000
#define TAG_MESSAGE 6000


//static NSString *kImageName     = @"imagename";
static NSString *kFirst_Name     = @"firstname";
static NSString *kLast_Name      = @"lastname";

/*
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
*/

@interface ReviewViewController ()
{
    BOOL isLoading;
    NSMutableDictionary * userInfo;
}
- (void) getPublishChat;

//@property (strong, nonatomic) EGORefreshTableHeaderView *refreshHeaderView;

@end




@implementation ReviewViewController

//@synthesize refreshHeaderView;
@synthesize nPinId;


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
    tapGesture.delegate = self; 
    tapGesture.numberOfTapsRequired = 1;
    [m_table addGestureRecognizer:tapGesture];
/*    
    isLoading = NO;
    
    CGRect tableFrame = m_table.frame;
    tableFrame.origin.y = -tableFrame.size.height;
    self.refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:tableFrame];
    self.refreshHeaderView.delegate = self;
    [m_table addSubview:self.refreshHeaderView];
    [self.refreshHeaderView refreshLastUpdatedDate];
*/
    
    m_tvMsg.layer.cornerRadius = 5.0;

//    NSString * country = [GeoLocation getUserCountry];
//    m_tfCountry.text = country;
    
//    [self getUserInfo];
    
    m_bFirstPass = NO;
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
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];

}
- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:YES animated:YES];
    
    if (!m_bFirstPass) {
        m_bFirstPass = YES;
        
        [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];

        [self performSelectorOnMainThread:@selector(getData) withObject:nil waitUntilDone:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

-(void) getData
{
    [self getUserInfo];
    [self getReviewInfo];
    [self getUserChatInfo];
    
//        [self getReviewStatus];
    
    [[SHKActivityIndicator currentIndicator] hide];

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
    
    m_viewMsg.frame = CGRectMake(0, self.view.frame.size.height - m_viewMsg.frame.size.height - 216,
                                 m_viewMsg.frame.size.width, m_viewMsg.frame.size.height);
    m_table.frame = CGRectMake(0, 44, 320, self.view.frame.size.height - (44+35) - 216);
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
    
    m_viewMsg.frame = CGRectMake(0, self.view.frame.size.height - m_viewMsg.frame.size.height,
                                 m_viewMsg.frame.size.width, m_viewMsg.frame.size.height);
    m_table.frame = CGRectMake(0, 44, 320, self.view.frame.size.height-(44+35));
    
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
    
    NSLog(@"userINfo = %@", userInfo);
    
}
 


- (void) getReviewInfo {
//    if (isLoading) {
//        return;
//    }

    arrPublishChart = nil;
    
//    isLoading = YES;

//    NSString *urlString = [Utils getReviewURL:self.nPinId];
//    JsonReader *jsonReader = [[JsonReader alloc] initWithUrl:urlString delegate:self];
//    [jsonReader read];

    NSString *urlString = [Utils getReviewURL:self.nPinId];
    NSString *pinResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    id result = [JSonParser objectWithString:pinResult];

    if (result == nil)
        return;
    
    NSLog(@"result = %@", result);
    
    //    arrPublishChart = [[NSMutableArray alloc] initWithArray:[result allValues]];
    if (arrPublishChart != nil) {
        [arrPublishChart removeAllObjects];
    }
    
    if ([result isKindOfClass:[NSArray class]]){
        arrPublishChart = [[NSMutableArray alloc] initWithArray:result];
    } else {
        arrPublishChart = [NSMutableArray new];
    }
    
    [m_table reloadData];
}

-(void) getUserChatInfo
{
    if ([Share getInstance].userChatInfo != nil) {
        return;
    }
    
    NSString *urlString = [Utils GetStartPinChat];
    NSString *pinResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    id result = [JSonParser objectWithString:pinResult];
    
    if (result == nil)
        return;
    
    NSDictionary *categoryResult = result;

    NSString * retOK = [categoryResult objectForKey:@"message"];
    if ([retOK isEqualToString:@"OK"]) {
        NSDictionary *values = [categoryResult objectForKey:@"user"];
        [Share getInstance].userChatInfo = [[NSDictionary alloc] initWithDictionary:values];
    }
}

-(void) getReviewStatus{
    NSString * auth_code = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginCode"];
    
    NSString *isReviewed = [NSString stringWithContentsOfURL:
                                [NSURL URLWithString:[Utils isReviewedUrl:auth_code :self.nPinId]] 
                                                        encoding:NSUTF8StringEncoding error:nil];
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    id result = [JSonParser objectWithString:isReviewed];
    
    NSLog(@"Is review = %@", result);
    bIsReviewed = [[result objectForKey: @"message"] intValue];
    
    if (bIsReviewed) {
        [m_viewMsg setHidden:YES];
    }

    
}


#pragma mark ------ 

-(IBAction) onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) onSendMsg:(id)sender
{
    
    NSString* _message = m_tvMsg.text;
    if (_message.length < 1) {
        return;
    }
    
    NSString *chat_code = [[Share getInstance].userChatInfo objectForKey:@"chatcode"];

/*    
    NSString * _date = [Utils getDateString:[NSDate date] :DATE_FULL];
    
    NSMutableDictionary * dicMsg = [[NSMutableDictionary alloc] initWithCapacity:3];
    [dicMsg setObject:_userId forKey:@"user_id"];
    [dicMsg setObject:_date   forKey:@"updated_at"];
    [dicMsg setObject:_message forKey:@"message"];
    
    [arrPublishChart addObject:dicMsg];
    
    [m_table reloadData];
*/
    
    
    ////////////////// POST
    
    NSString *url = [Utils sendReviewUrl];
    NSLog(@"publish msg URL = %@", url);
    
/*    
    IAMultipartRequestGenerator *request = [[IAMultipartRequestGenerator alloc] initWithUrl:url andRequestMethod:@"POST"];
    
    [request setString:chat_code forField:@"code"];
    NSLog(@"code = %@", chat_code);
    
    [request setString:_message forField:@"message[message]"];
    NSLog(@"message[message] = %@", _message);
    
    [request setString:[userInfo objectForKey:@"chat_id"] forField:@"message[user_id]"];
    NSLog(@"message[user_id] = %@", [userInfo objectForKey:@"chat_id"]);

    [request setString:[NSString stringWithFormat:@"%d", self.nPinId] forField:@"pin"];
    NSLog(@"pin = %d", self.nPinId);

    
    [request setDelegate:self];
    [request startRequest];
*/
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString: url]];
    request.requestMethod = @"POST";
    
    [request setPostValue:chat_code forKey:@"code"];
    [request setPostValue:_message forKey:@"message[message]"];
    [request setPostValue:[userInfo objectForKey:@"chat_id"] forKey:@"message[user_id]"];
    [request setPostValue:[NSString stringWithFormat:@"%d", self.nPinId] forKey:@"pin"];
    
    NSLog(@"code = %@", chat_code);
    NSLog(@"message[message] = %@", _message);
    NSLog(@"message[user_id] = %@", [userInfo objectForKey:@"chat_id"]);
    NSLog(@"pin = %d", self.nPinId);

    [request setDelegate:self];
    [request setDidFinishSelector:@selector(uploadRequestFinished:)];
    [request setDidFailSelector:@selector(uploadRequestFailed:)];
    
    [request startAsynchronous];
    
    
    [m_tvMsg resignFirstResponder];
    m_tvMsg.text = @"";
}

#pragma mark
#pragma mark ASIFormDataRequest delegate methods

- (void)uploadRequestFinished:(ASIHTTPRequest *)request{    
    
    [[SHKActivityIndicator currentIndicator] hide];
    
    NSString *responseString = [request responseString];
    NSLog(@"Upload response %@", responseString);
    
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully reviewed a pin" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
    
    [self getReviewInfo];
//    [self getReviewStatus];
}

- (void)uploadRequestFailed:(ASIHTTPRequest *)request{
    
    [[SHKActivityIndicator currentIndicator] hide];
    
    NSLog(@" Error - Statistics file upload failed: \"%@\"",[[request error] localizedDescription]); 
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Fail!" message:@"There seems to be an issue placing pins at present" delegate:self 
                                           cancelButtonTitle:@"OK" 
                                           otherButtonTitles:nil, nil];
    [alert show];
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

/*
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
*/


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
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
            lbDate = [[UILabel alloc] initWithFrame:CGRectMake(170, 0, 150, 30)];
            lbDate.tag = TAG_DATE + indexPath.row;
            lbDate.backgroundColor = [UIColor clearColor];
            lbDate.textAlignment = UITextAlignmentRight;
            lbDate.font = [UIFont systemFontOfSize:12];
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

//    lbName.text = [self getUserName:[[item objectForKey:@"user_id"] intValue]];  //[NSString stringWithFormat:@"%d", [[item objectForKey:@"user_id"] intValue]];
    
    NSMutableDictionary * _reviewUser = [item objectForKey:@"user"];
    lbName.text = [NSString stringWithFormat:@"%@ %@",[_reviewUser objectForKey:@"first_name"], [_reviewUser objectForKey:@"last_name"]];
    
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
