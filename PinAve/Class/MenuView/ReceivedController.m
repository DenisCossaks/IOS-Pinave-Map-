//
//  ReceivedController.m
//  NEP
//
//  Created by Dandong3 Sam on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReceivedController.h"
#import "UserSession.h"
#import "MessageDetailController.h"
#import "AppDelegate.h"
#import "MessageNewController.h"

@implementation ReceivedCell

@synthesize thumbImg, senderLbl, dateLbl, messageLbl;

@end


@interface ReceivedController ()
{
    BOOL isLoading;
}

@property (strong, nonatomic) EGORefreshTableHeaderView *refreshHeaderView;

- (void)getMessages;

@end

@implementation ReceivedController

@synthesize messageAry;
@synthesize refreshHeaderView;
@synthesize searchMsgBar;
@synthesize messageTbl, creatingCell;

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
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Inbox";
    UIViewController *homeCtlr = [self.navigationController.viewControllers objectAtIndex:0];
    self.navigationItem.leftBarButtonItem = homeCtlr.navigationItem.leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onNewMessage:)];
    
    isLoading = NO;
    CGRect tableFrame = self.messageTbl.frame;
    tableFrame.origin.y = -tableFrame.size.height;
    self.refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:tableFrame];
    self.refreshHeaderView.delegate = self;
    [self.messageTbl addSubview:self.refreshHeaderView];
    [self.refreshHeaderView refreshLastUpdatedDate];
    
    [self getMessages];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.searchMsgBar resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void)getMessages
{
    if (isLoading) {
        return;
    }
    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];
    
    self.messageAry = nil;
    [self.messageTbl reloadData];
    isLoading = YES;
    
    NSString *urlString = [Utils getMessageUrl];
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
    [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.messageTbl];
    
    NSDictionary *messageResult = result;
    if (!messageResult) {
        return;
    }
    /*
    NSString *message = [messageResult objectForKey:@"message"];
    if (![message isEqualToString:@"OK"]) {
        return;
    }*/
    
    NSDictionary *messages = [messageResult objectForKey:@"messages"];
    NSArray *messageList = [messages allValues];
    self.messageAry = [messageList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj2 objectForKey:@"currtime"] compare:[obj1 objectForKey:@"currtime"]];
    }];
    
    [self.messageTbl reloadData];
    
    [[SHKActivityIndicator currentIndicator] hide];
}

- (void)onNewMessage:(id)sender
{
    MessageNewController *messageNewCtlr = [[MessageNewController alloc] init];
    [self presentModalViewController:messageNewCtlr animated:YES];
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
	[self getMessages];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
	return isLoading; // should return if data source model is reloading
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
	return [NSDate date]; // should return date data source was last changed
}


#pragma ---- UITableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messageAry count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReceivedCell";
    
    ReceivedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ReceivedCell" owner:self options:nil];
        cell = self.creatingCell;
        self.creatingCell = nil;
    }
    
    // Configure the cell...
    NSDictionary *messageInfo = [self.messageAry objectAtIndex:indexPath.row];
    cell.senderLbl.text = [messageInfo objectForKey:@"user"];
    cell.dateLbl.text = [[messageInfo objectForKey:@"currtime"] substringToIndex:10];
    
    NSMutableString *message = [NSMutableString stringWithString:[messageInfo objectForKey:@"message"]];
    [message replaceOccurrencesOfString:@"<p>" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [message length])];
    [message replaceOccurrencesOfString:@"</p>" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [message length])];
    cell.messageLbl.text = message;
    
    return cell;
}

#pragma ---- UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageDetailController *detailCtlr = [[MessageDetailController alloc] init];
    detailCtlr.messageInfo = [self.messageAry objectAtIndex:indexPath.row];
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    ViewController * rootCtlr = appDelegate.viewController;
    [self.navigationController pushViewController:detailCtlr animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
