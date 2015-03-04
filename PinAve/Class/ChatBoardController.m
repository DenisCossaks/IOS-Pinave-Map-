//
//  ChatBoardController.m
//  PinAve
//
//  Created by Gold Luo on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChatBoardController.h"
#import "IAMultipartRequestGenerator.h"
#import "SBJSON.h"


#define kMESSAGE    @"message"

enum _TAG_TABEL {
    TAG_NAME = 15000,
    TAG_TEXT
    };


@interface ChatBoardController ()

- (void) getPrivateMessage;

@end

@implementation ChatBoardController

@synthesize userInfo, receiveInfo;


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
    
    arrayMsg = [NSMutableArray array];
    
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

-(void) viewDidAppear:(BOOL)animated
{

    NSLog(@"userInfo = %@", userInfo);
    
    NSString *pinResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:[Utils getOtherChatIdUrl:[self.userInfo objectForKey:@"chatcode"] : [self.receiveInfo objectForKey:@"public_code"]]]
                                                   encoding:NSUTF8StringEncoding error:nil];
    
    SBJsonParser *JSonParser = [[SBJsonParser alloc] init];
    id result = [JSonParser objectWithString:pinResult];
    
    strReceiveChatId = [result objectForKey: @"recepient_id"];

    
    lbReceiveName.text = [NSString stringWithFormat:@"%@ %@", 
                          [self.receiveInfo objectForKey:@"first_name"], [self.receiveInfo objectForKey:@"last_name"]];
    
    [self getPrivateMessage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[SHKActivityIndicator currentIndicator] displayActivity:@"" : self];

    self.navigationController.navigationBarHidden = YES;
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:YES animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}


- (void) getPrivateMessage {
    [[SHKActivityIndicator currentIndicator] displayActivity:@"" : self];

    NSString * receiveId = strReceiveChatId;
    NSString * userCode =  [self.userInfo objectForKey:@"chatcode"];
    
    NSString *urlString = [Utils getPrivateChatUrl:receiveId : userCode];
    JsonReader *jsonReader = [[JsonReader alloc] initWithUrl:urlString delegate:self];
    [jsonReader read];
}

- (void)didJsonRead:(id)result
{
    
    if (result == nil)
        return;
    
    if (arrayMsg != nil) {
        [arrayMsg removeAllObjects];
    }
    
    
    arrayMsg = [[NSMutableArray alloc] initWithArray:result];
    
    [[SHKActivityIndicator currentIndicator] hide];
    
    [m_table reloadData];
}


-(void) sendMessage : (NSString*) _message 
{
    NSString *url = [Utils getChatSendText];
    
    IAMultipartRequestGenerator *request = [[IAMultipartRequestGenerator alloc] initWithUrl:url andRequestMethod:@"POST"];
    
    [request setString:[userInfo objectForKey:@"chatcode"] forField:@"code"];
    NSLog(@"code = %@", [userInfo objectForKey:@"chatcode"]);
    
    [request setString:_message forField:@"message[message]"];
    NSLog(@"message[message] = %@", _message);
    
    [request setString:[userInfo objectForKey:@"chat_id"] forField:@"message[user_id**]"];
    NSLog(@"message[user_id**] = %@", [userInfo objectForKey:@"chat_id"]);
    
    [request setString:strReceiveChatId forField:@"message[recepient_id**]"];
    NSLog(@"message[recepient_id**] = %@", strReceiveChatId);
    
    [request setDelegate:self];
    [request startRequest];

}

#pragma mark
#pragma mark IAMultipartRequestGenerator delegate methods

-(void)requestDidFailWithError:(NSError *)error 
{
    NSLog(@"IAMultipartRequestGenerator request failed");
    
//    [[[UIAlertView alloc] initWithTitle:@"Fail!" message:@"Creating pin is fails" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
}


-(void)requestDidFinishWithResponse:(NSData *)responseData 
{
    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"IAMultipartRequestGenerator finished: %@", response);
    
    [self getPrivateMessage];
}

#pragma mark ----------- Event
-(IBAction) onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction) onSend
{
    NSString* _text = tfSend.text;
    if (_text.length < 1) {
        return;
    }
    
    [self sendMessage:_text];
    
    [m_table reloadData];
}

-(IBAction) next
{
    
}

#pragma mark --------- table view delegate -------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayMsg count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary * item = [arrayMsg objectAtIndex:indexPath.row];
    
//    NSString *userName = [NSString stringWithFormat:@"%@ %@", [[item objectForKey:@"user"] objectForKey:@"first_name"], [[item objectForKey:@"user"] objectForKey:@"last_name"]];
    NSString *message  = [item objectForKey:kMESSAGE];
    
//    NSString * text = [NSString stringWithFormat:@"%@\n%@", userName, message];
    
    int line = [message length] / 40;
    
    return 15 * (1 + (line + 1));
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MenuCell";
    
    UILabel * lbName;
    UILabel * lbText;
    
    UITableViewCell *cell ;//= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        lbName  = (UILabel*)[cell.contentView viewWithTag:TAG_NAME + indexPath.row];
        if(lbName == nil)
        {
            lbName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 240, 20)];
            lbName.tag = TAG_NAME + indexPath.row;
            lbName.backgroundColor = [UIColor clearColor];
            lbName.font = [UIFont systemFontOfSize:10];
            lbName.numberOfLines = 0;
            lbName.lineBreakMode = UILineBreakModeWordWrap;

            [cell.contentView addSubview:lbName];
        }

        lbText  = (UILabel*)[cell.contentView viewWithTag:TAG_TEXT + indexPath.row];
        if(lbText == nil)
        {
            lbText = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, 240, 20)];
            lbText.tag = TAG_TEXT + indexPath.row;
            lbText.backgroundColor = [UIColor clearColor];
            lbText.font = [UIFont systemFontOfSize:10];
            lbText.numberOfLines = 0;
            lbText.lineBreakMode = UILineBreakModeWordWrap;

            [cell.contentView addSubview:lbText];
        }

    }
    
    NSMutableDictionary * data = [arrayMsg objectAtIndex:indexPath.row];

    NSString *userName = [NSString stringWithFormat:@"%@ %@", [[data objectForKey:@"user"] objectForKey:@"first_name"], [[data objectForKey:@"user"] objectForKey:@"last_name"]];
    
    NSString *message  = [data objectForKey:kMESSAGE];
    
    lbName.text = userName;
    lbText.text = message;
    [lbText sizeToFit];
    return cell;
}


#pragma mark ----------------------------
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    
}


#pragma mark ---------- Key board
-(void) keyboardDidShow: (NSNotification *)notif 
{
    if (keyboardVisible) 
	{
		return;
	}
	
	// Get the size of the keyboard.
	NSDictionary* info = [notif userInfo];
	NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
	CGSize keyboardSize = [aValue CGRectValue].size;
	

	viewSend.frame = CGRectMake(0, 460-keyboardSize.height-viewSend.frame.size.height, viewSend.frame.size.width, viewSend.frame.size.height);
    m_table.frame = CGRectMake(0, 44, m_table.frame.size.width, 460 - 44 - 44 - keyboardSize.height);
    
	// Keyboard is now visible
	keyboardVisible = YES;
    
    if ([arrayMsg count] != 0) {
        [m_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([arrayMsg count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void) keyboardDidHide: (NSNotification *)notif 
{
	// Is the keyboard already shown
	if (!keyboardVisible) 
	{
		return;
	}
	
    viewSend.frame = CGRectMake(0, 460 - viewSend.frame.size.height, viewSend.frame.size.width, viewSend.frame.size.height);	
    m_table.frame = CGRectMake(0, 44, m_table.frame.size.width, 460 - 44);
    
    
	// Keyboard is no longer visible
	keyboardVisible = NO;
    
}


@end
