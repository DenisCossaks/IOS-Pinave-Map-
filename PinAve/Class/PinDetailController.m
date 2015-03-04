//
//  PinDetailController.m
//  NEP
//
//  Created by Dandong3 Sam on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PinDetailController.h"
#import "AppDelegate.h"
#import "ShareController.h"
#import "RouteViewController.h"
#import "SentController.h"
#import "ReviewViewController.h"
#import "SBJsonParser.h"
#import "SBJSON.h"
#import "JSON.h"

#import "WebController.h"
#import "SendMessageController.h"
#import "UIImageView+Cached.h"

#import <Social/Social.h>
#import "accounts/Accounts.h"

#define TAG_ALERT_DEL   1909
#define TAG_ALERT_DEL_1   1908

@interface PinDetailController ()

@end

@implementation PinDetailController

@synthesize pinInfo;
@synthesize delegate;

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

    
    viewTitle.layer.cornerRadius = 5;
    viewTitle.layer.borderColor = [[UIColor blackColor] CGColor];
    viewTitle.layer.borderWidth = 1;

    viewTitle.layer.cornerRadius = 5;
    viewTitle.layer.borderColor = [[UIColor blackColor] CGColor];
    viewTitle.layer.borderWidth = 1;

    tvDescription.layer.cornerRadius = 5;
    tvDescription.layer.borderColor = [[UIColor blackColor] CGColor];
    tvDescription.layer.borderWidth = 1;

    
    
    m_bRefreshed = YES;
    m_bLoadingDone = YES;

    pinImgViw.userInteractionEnabled = YES;
    [pinImgViw setContentMode:UIViewContentModeScaleAspectFit];
    
    UITapGestureRecognizer * lgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFullImage:)];
    lgr.delegate = self;
    lgr.numberOfTapsRequired = 1;
    [pinImgViw addGestureRecognizer:lgr];
    
    [ivFullImage setContentMode:UIViewContentModeScaleAspectFit];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:YES animated:YES];

    if (!m_bRefreshed) {
        return;
    }
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//
//    if (!m_bRefreshed) {
//        return;
//    }
    m_bRefreshed = NO; //m_bLoadingDone = NO;
    
    lbTitle.text = [[Share getInstance] getCategoryTitle:[[self.pinInfo objectForKey:@"category_id"] intValue]];
    
    int expire = [[self.pinInfo objectForKey:@"expire_in"] intValue];
    int hour = expire/(60*60);
    int min = (expire - hour * (60*60)) / 60;
    lbExpire.text = [NSString stringWithFormat:@"Pin expires in %dh : %d m", hour, min];
    
   
    int userId = [[self.pinInfo objectForKey:@"user_id"] intValue];
    int signedId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"loginId"] intValue];
    
    if (userId == signedId) {
        nPinStatue = PIN_USER;
        [btnReview setTitle:@"Delete" forState:UIControlStateNormal];
        
        [btnMyAvenue setEnabled:NO];
        [btnMessage setEnabled:NO];
        
    } else if (userId == 13) {
        nPinStatue = PIN_SYSTEM;
        
        [btnMessage setImage:[UIImage imageNamed:@"btnGetIt"] forState:UIControlStateNormal];
        
    } else if (userId == 70 || userId == 69) { // Real estate, carsales
        nPinStatue = PIN_OTHER;
        
        [btnMyAvenue setEnabled:NO];
        [btnMessage setEnabled:NO];
        
    } else {
        nPinStatue = PIN_OTHER;
        
        [btnReview setHidden:NO];
    }
    
    
    [self setPinnedBy:userId];
    
    
    lbFullAddress.text = [self.pinInfo objectForKey:@"full_address"];
    
    titleLbl.text = [self.pinInfo objectForKey:@"title"];
    addressLbl.text = [self.pinInfo objectForKey:@"address"];
    cityLbl.text = [self.pinInfo objectForKey:@"city"];
    countryLbl.text = [self.pinInfo objectForKey:@"country"];
    
    NSString* data = [NSString stringWithFormat:@"<html>%@</html>", [self.pinInfo objectForKey:@"description"]];
    [tvDescription loadHTMLString:data baseURL:nil];
    //    tvDescription.text = [self.pinInfo objectForKey:@"description"];
    
    titleLbl.layer.cornerRadius = 10.0;
    viewAddress.layer.cornerRadius = 10.0;
    lbBtnDicTo.layer.cornerRadius = 10.0;
    lbBtnDicFrom.layer.cornerRadius = 10.0;
    tvDescription.layer.cornerRadius = 10.0;
    

    [[SHKActivityIndicator currentIndicator] displayActivity:@"" : self];
    
    m_nLoadingCount = 0;
    [self setRating];
    [self setBookmark];
    [self setFriend];
    
    NSString *imageUrl = [pinInfo objectForKey:@"image"];
    NSLog(@"imageUrl = %@", imageUrl);
    
    [NSThread detachNewThreadSelector:@selector(getThumbImage:) toTarget:self withObject:imageUrl];

}

- (void) setRating
{
    m_strPinId = [self.pinInfo objectForKey:@"id"];
    
    NSString * urlString = [Utils getRatingUrl:m_strPinId];

    ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setDelegate:self];
    [request setRequestMethod:@"GET"];
    [request setDidFinishSelector:@selector(requestRatingDone:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request startAsynchronous];
}

- (void)requestRatingDone:(ASIFormDataRequest*)request {
    
    NSString *responseString = [request responseString];
    NSMutableDictionary* result = [responseString JSONValue];
    
    int rate = [[result objectForKey: @"rating"] intValue];
    NSString* strVote   = [result objectForKey: @"votes"];

    // rating control
    ratingControl = [[DLStarRatingControl alloc] initWithFrame:CGRectMake(120, 75, 150, 40) andStars:5 isFractional:NO];
    ratingControl.delegate = self;
  	ratingControl.backgroundColor = [UIColor clearColor];
	ratingControl.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
    ratingControl.rating = rate;
    if (rate == 0) {
        m_bEnableRating = YES;
    } else {
        m_bEnableRating = NO;
    }
    [ratingControl setStarRatingControlDisable:!m_bEnableRating];
	[self.view addSubview:ratingControl];
    
    if ([strVote rangeOfString:@"null"].location != NSNotFound) {
        strVote = @"0";
    }
    lbVotes.text = [NSString stringWithFormat:@"(%@)", strVote];
    
    m_nLoadingCount ++;
    if (m_nLoadingCount == 3) {
        [[SHKActivityIndicator currentIndicator] hide];
    }
}

-(void) setBookmark
{
    NSString * auth_code = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginCode"];

    NSString * urlString = [Utils isAvenuePinUrl:auth_code :[m_strPinId intValue]];
    
    ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setDelegate:self];
    [request setRequestMethod:@"GET"];
    [request setDidFinishSelector:@selector(requestBookmarkDone:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request startAsynchronous];

}
- (void)requestBookmarkDone:(ASIFormDataRequest*)request {
    NSString *responseString = [request responseString];
    NSMutableDictionary* result = [responseString JSONValue];

    bIsAddPin = [[result objectForKey: @"message"] intValue];
    
    m_nLoadingCount ++;
    if (m_nLoadingCount == 3) {
        [[SHKActivityIndicator currentIndicator] hide];
    }

}

-(void) setFriend
{
    NSString * auth_code = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginCode"];
    int userId = [[self.pinInfo objectForKey:@"user_id"] intValue];

    NSString * urlString = [Utils isAvenueUserUrl:auth_code :userId];
    
    ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setDelegate:self];
    [request setRequestMethod:@"GET"];
    [request setDidFinishSelector:@selector(requestFriendDone:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request startAsynchronous];
    
}
- (void)requestFriendDone:(ASIFormDataRequest*)request {
    NSString *responseString = [request responseString];
    NSMutableDictionary* result = [responseString JSONValue];

    bIsAddUser = [[result objectForKey: @"message"] intValue];
    
    m_nLoadingCount ++;
    if (m_nLoadingCount == 3) {
        [[SHKActivityIndicator currentIndicator] hide];
    }
}


- (void)requestFailed:(ASIFormDataRequest*)request {
    
    [[SHKActivityIndicator currentIndicator] hide];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There seems to be an issue at present" delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil];
    [alert show];
}



- (void) setPinnedBy:(int) _userId
{
    for (NSMutableDictionary * user in [Share getInstance].allUsers) {
        int nUserId = [[user objectForKey:@"id"] intValue];
        if (nUserId == _userId) {
            
//            NSLog(@"user infof = %@", user);
            NSString* str = @"Pinned by:";
            
            NSString * firstName = [user objectForKey:@"firstname"];
            if (firstName == nil || [firstName isKindOfClass:[NSNull class]] || [firstName rangeOfString:@"null"].location != NSNotFound) {
            } else {
                str = [str stringByAppendingFormat:@" %@", firstName];
            }
            
            NSString * lastName  = [user objectForKey:@"lastname"];
            if (lastName == nil || [lastName isKindOfClass:[NSNull class]] || [lastName rangeOfString:@"null"].location != NSNotFound) {
            } else {
                str = [str stringByAppendingFormat:@" %@", lastName];
            }
            
            NSString * city = [[user objectForKey:@"detail"] objectForKey:@"city"];
            if (city == nil || [city isKindOfClass:[NSNull class]] || [city rangeOfString:@"null"].location != NSNotFound) {
            } else {
                str = [str stringByAppendingFormat:@", %@", city];
            }
            
            NSString * country = [[user objectForKey:@"detail"] objectForKey:@"country"];
            if (country == nil || [country isKindOfClass:[NSNull class]] || [country rangeOfString:@"null"].location != NSNotFound) {
                
            } else {
                str = [str stringByAppendingFormat:@", %@", country];
            }
            
            lbPinBy.text = str;//[NSString stringWithFormat:@"Pinned by: %@ %@, %@, %@", firstName, lastName, city, country];
            
            break;
        }
    }

}


#pragma mark -
#pragma mark Delegate implementation of NIB instatiated DLStarRatingControl

-(void)newRating:(DLStarRatingControl *)control :(float)rating {
//	self.stars.text = [NSString stringWithFormat:@"%0.1f star rating",rating];
    m_nRating = rating;
    
    NSString * message = [NSString stringWithFormat:@"You are about to submit a rating of %d stars for this pin.", m_nRating];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Your Review" 
                                                     message:message
                                                    delegate:self
                                           cancelButtonTitle:@"Change"
                                           otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{ 
    if (alertView.tag == TAG_ALERT_DEL) {
//        [delegate closeDeletePin];
//        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        return;
    }
    else if (alertView.tag == TAG_ALERT_DEL_1) {
        if (buttonIndex == 1) {
            [self onDeletePin];
        }
    }
    else {
        if (buttonIndex == 1) {
            [self submitRating];
        }
    }
}

- (void) submitRating{
    m_bEnableRating = NO;
    [ratingControl setStarRatingControlDisable:!m_bEnableRating];
    
    /// post
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * userCode = [defaults objectForKey:@"loginCode"];
    
    m_bLoadingDone = NO;
    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];
    
    NSString *url = [Utils postRatingUrl:userCode :m_strPinId :m_nRating];
    
    ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setDelegate:self];
    [request setRequestMethod:@"GET"];
    [request setDidFinishSelector:@selector(requestUserInfoDone:)]; 
    [request setDidFailSelector:@selector(requestFailed:)]; 
    [request setTimeOutSeconds:9999];
    [request setNumberOfTimesToRetryOnTimeout:2];
    [request startAsynchronous];

}
- (void)requestUserInfoDone:(ASIFormDataRequest*)request {
    
    NSLog(@"%@", [request responseString] );
    
    [[SHKActivityIndicator currentIndicator] hide];
    
    [[[UIAlertView alloc] initWithTitle:@"" message:@"Your rating has been submitted\n Thank you." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

    m_bRefreshed = YES;
    m_bLoadingDone = YES;
}



#pragma mark
#pragma mark IAMultipartRequestGenerator delegate methods

-(void)requestDidFailWithError:(NSError *)error 
{
    NSLog(@"IAMultipartRequestGenerator request failed");
    
    [[SHKActivityIndicator currentIndicator] hide];
    
    [[[UIAlertView alloc] initWithTitle:@"Fail!" message:@"Submitting rating is fails" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
    m_bLoadingDone = YES;
    
}


-(void)requestDidFinishWithResponse:(NSData *)responseData 
{
    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"IAMultipartRequestGenerator finished: %@", response);
    
    [[SHKActivityIndicator currentIndicator] hide];
    
    [[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Submitting rating success" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
    m_bRefreshed = YES;
    m_bLoadingDone = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark ---- ThumbImage --------
- (void) getThumbImage:(NSString *)url
{
    
    if ([url rangeOfString:@"http"].location == NSNotFound) {
        url = [NSString stringWithFormat:@"%@%@", SERVER_URL, url];
    }
    if ([url rangeOfString:@".png"].location != NSNotFound 
        || [url rangeOfString:@"jpg"].location != NSNotFound
        || [url rangeOfString:@"jpeg"].location != NSNotFound) {
        
    } else {
        url = [NSString stringWithFormat:@"%@.png", url];
    }


//    NSLog(@"img url = %@", url);
    [pinImgViw loadFromURL:[NSURL URLWithString:url]];
    
//    
//    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
//    UIImage *iconImg = [UIImage imageWithData:imageData];
//    if (iconImg) {
//        [pinImgViw setImage:iconImg];
//    }        
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

- (IBAction)onBack:(id)sender
{
    if (!m_bLoadingDone) {
        return;
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onReview:(id)sender{
    if (!m_bLoadingDone) {
        return;
    }
    
    if (nPinStatue == PIN_USER) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to delete this pin?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        alert.tag = TAG_ALERT_DEL_1;
        [alert show];
    }
    else {
        ReviewViewController * vc;
        
        if (iPhone) {
            vc = [[ReviewViewController alloc] initWithNibName:@"ReviewViewController" bundle:nil];
        } else {
            vc = [[ReviewViewController alloc] initWithNibName:@"ReviewViewController-ipad" bundle:nil];
        }
        
        int pinId = [[self.pinInfo objectForKey:@"id"] intValue];
        vc.nPinId = pinId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void) onDeletePin
{
    m_bLoadingDone = NO;
    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"" : self];
    
    NSString * auth_code = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginCode"];
    NSString * url = [Utils getDeletePinUrl: auth_code : m_strPinId];
    
    ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setDelegate:self];
    [request setRequestMethod:@"GET"];
    [request setDidFinishSelector:@selector(requestDelPinDone:)];
    [request setDidFailSelector:@selector(requestDelPinFailed:)];
    [request startAsynchronous];
    
}

- (void)requestDelPinDone:(ASIFormDataRequest*)request {
    
    NSLog(@"%@", [request responseString] );
    
    [[SHKActivityIndicator currentIndicator] hide];
    m_bLoadingDone = YES;
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Your pin has been removed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = TAG_ALERT_DEL;
    [alert show];
    
    
//    m_bRefreshed = YES;
}

- (void)requestDelPinFailed:(ASIFormDataRequest*)request {
    
    NSLog(@"Failed");
    
    [[SHKActivityIndicator currentIndicator] hide];
    m_bLoadingDone = YES;
    
    [[[UIAlertView alloc] initWithTitle:@"" message:@"Fail!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
}



- (IBAction)onDirectToHere:(id)sender{
    if (!m_bLoadingDone) {
        return;
    }

    
    [self.navigationController popViewControllerAnimated:NO];
  
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabbarIndex:3];

    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotiDicToHere object:nil userInfo:self.pinInfo];
//    [[RouteViewController getInstance] DirectToHere:self.pinInfo];

//    [delegate closeDirectToHere:self.pinInfo];
    
}
- (IBAction)onDirectFromHere:(id)sender{
    if (!m_bLoadingDone) {
        return;
    }

    
    [self.navigationController popViewControllerAnimated:NO];

    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabbarIndex:3];

    [[NSNotificationCenter defaultCenter] postNotificationName:NotiDicFromHere object:nil userInfo:self.pinInfo];
//    [delegate closeDirectFromHere:self.pinInfo];
}
- (IBAction)onAddToContact:(id)sender{
    if (!m_bLoadingDone) {
        return;
    }

    
    NSString *UserTo = bIsAddUser != 1 ? @"Add User to My Avenue" : @"Remove User to My Avenue";
    NSString *PinTo  = bIsAddPin  != 1 ? @"Add Pin to My Avenue" : @"Remove Pin to My Avenue";
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate: self cancelButtonTitle: @"Cancel" destructiveButtonTitle:nil otherButtonTitles: UserTo, PinTo, nil];
    
    actionSheet.tag = 90;
    [actionSheet showInView: self.view];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 90) {
        if ( buttonIndex == 0 )
        {
            [self userToAvenue];
        }
        else if ( buttonIndex == 1 )
        {
            [self pinToAvenue];
        }    
    }
    
    if (actionSheet.tag == 91) {
        if ( buttonIndex == 0 )
        {
            [self shareEmail: nil];
        }
        else if ( buttonIndex == 1 )
        {
            [self shareFacebook];
        }    
        else if ( buttonIndex == 2 )
        {
            [self shareTwitter];
        }    
        
    }
    
    
}
- (IBAction)onReferToFriend:(id)sender{
    if (!m_bLoadingDone) {
        return;
    }

    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate: self cancelButtonTitle: @"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Invite by Email", @"Invite From Facebook", @"Invite From Twitter", nil];
    
    actionSheet.tag = 91;
    [actionSheet showInView: self.view];

}
- (IBAction)onSendMessage:(id)sender{
/*
    SentController * vc;
    
    if (iPad) {
        vc = [[SentController alloc] initWithNibName:@"SentController-ipad" bundle:nil];
    } else {
        vc = [[SentController alloc] initWithNibName:@"SentController" bundle:nil];
    }
    
    [self.navigationController pushViewController:vc animated:YES];
*/    
    
//    [self showPeoplePickerController];
    
    if (!m_bLoadingDone) {
        return;
    }

    
    if (nPinStatue == PIN_SYSTEM) {
        NSString * dealUrl = [self.pinInfo objectForKey:@"url"];
        
        WebController * vc = [[WebController alloc] init];
        vc.m_urlPost = dealUrl;

        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (nPinStatue == PIN_USER){
        
    } else {
        SendMessageController * vc = [[SendMessageController alloc] init];
        vc.pinInfo = self.pinInfo;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}
-(void) sendMessageViaEmail
{
     int userId = [[self.pinInfo objectForKey:@"user_id"] intValue];
    
    for (NSMutableDictionary * user in [Share getInstance].allUsers) {
        int nUserId = [[user objectForKey:@"id"] intValue];
        if (nUserId == userId) {
            
            NSLog(@"user infof = %@", user);
            
            break;
        }
    }

}


#pragma mark -------------------------

#pragma mark in MyAvenue

#pragma mark Add User to 

- (void) userToAvenue
{
    NSString * auth_code = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginCode"];
    int userId = [[self.pinInfo objectForKey:@"user_id"] intValue];
    
    NSString *url; 
    
    if (bIsAddUser == 1) {
        url = [Utils postDeleteUserUrl: auth_code : userId];
    } else {
        url = [Utils postAddUserUrl: auth_code : userId];
    }

    [[SHKActivityIndicator currentIndicator] displayActivity:@"" : self];
    m_bLoadingDone = NO;
    
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
    
    NSString * message = @"";
    if (bIsAddUser == 1) { //delete
        message = @"The user has been removed into MyAvenue";
    } else {
        message = @"The user has been added into MyAvenue";
    }
    [[[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
    bIsAddUser = bIsAddUser == 0 ? 1 : 0;
    m_bRefreshed = YES;
    m_bLoadingDone = YES;
    
}

- (void)requestAddUserFailed:(ASIFormDataRequest*)request {
    
    NSLog(@"Failed");
    
    [[SHKActivityIndicator currentIndicator] hide];
    m_bLoadingDone = YES;
    
    [[[UIAlertView alloc] initWithTitle:@"" message:@"Fail!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
}

- (void) pinToAvenue
{
    NSString * auth_code = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginCode"];
    int pinId = [[self.pinInfo objectForKey:@"id"] intValue];
    
    NSString *url = [Utils postAdd_RemovePinUrl:auth_code : pinId];
    
    [[SHKActivityIndicator currentIndicator] displayActivity:@"" : self];
    m_bLoadingDone = NO;
    
    ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setDelegate:self];
    [request setRequestMethod:@"GET"];
    [request setDidFinishSelector:@selector(requestPinDone:)]; 
    [request setDidFailSelector:@selector(requestPinFailed:)]; 
    [request startAsynchronous];
    
}
- (void)requestPinDone:(ASIFormDataRequest*)request {
    
    NSLog(@"%@", [request responseString] );
    
    [[SHKActivityIndicator currentIndicator] hide];
    m_bLoadingDone = YES;
    
    
    NSString * message = @"";
    if (bIsAddPin != 1) { //delete
        message = @"The pin has been added into MyAvenue";
    } else {
        message = @"The pin has been removed into MyAvenue";
    }
    [[[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
    bIsAddPin = bIsAddPin == 0 ? 1 : 0;
    m_bRefreshed = YES;
}

- (void)requestPinFailed:(ASIFormDataRequest*)request {
    
    NSLog(@"Failed");
    
    [[SHKActivityIndicator currentIndicator] hide];
    m_bLoadingDone = YES;
    
    
    [[[UIAlertView alloc] initWithTitle:@"" message:@"Fail!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
}



#pragma mark --- Invite
-(void) shareEmail : (NSArray *) emails{
    
	NSString *subject = @"PinAve";
    
    
	NSString* tpl = [Utils stringFromFileNamed:@"email.html"];
    
    NSString *first_name = [[Share getInstance].dicUserInfo objectForKey:@"firstname"];
    NSString *last_name = [[Share getInstance].dicUserInfo objectForKey:@"lastname"];;

	NSString* body = [NSString stringWithFormat:tpl, first_name, last_name, m_strPinId];
	
	
	if(![MFMailComposeViewController canSendMail]){
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please configure your mail settings to send email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		return;
	}
    
	MFMailComposeViewController* mc = [[MFMailComposeViewController alloc] init];
	mc.mailComposeDelegate = self;
	[mc setSubject:subject];	
	[mc setToRecipients:emails];	
	[mc setMessageBody:body isHTML:YES];	
    
	[self presentModalViewController:mc animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
	switch (result) {
		case MFMailComposeResultSent:	
            [[[UIAlertView alloc] initWithTitle:nil message:@"Invite was sent!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
			break;
		default:
			break;
	}
	[self dismissModalViewControllerAnimated:YES];	
}


- (void) startAnimating {
    [[SHKActivityIndicator currentIndicator] displayActivity:@"Loading..." : self];  
}

- (void) stopAnimating {
    [[SHKActivityIndicator currentIndicator] hide];
}

- (void) messagePostedSuccessfully
{
    [self stopAnimating];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: nil message: @"Thanks for sharing." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
    [alert show];
}


- (void) shareFacebook{
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        [self facebook];
    }
    else {
        ShareController* facebook;
        
        if (iPhone) {
            facebook = [[ShareController alloc] initWithNibName:@"ShareController" bundle:nil];
        } else {
            facebook = [[ShareController alloc] initWithNibName:@"ShareController-ipad" bundle:nil];
        }
        
        [facebook initWithMode:SHARE_FACEBOOK];
        
        [self presentModalViewController:facebook animated:YES];
    }

}

- (void) shareTwitter{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        [self twitter];
    }
    else {
        ShareController* twitter;
        
        if (iPhone) {
            twitter = [[ShareController alloc] initWithNibName:@"ShareController" bundle:nil];
        } else {
            twitter = [[ShareController alloc] initWithNibName:@"ShareController-ipad" bundle:nil];
        }
        
        [twitter initWithMode:SHARE_TWITTER];
        
        [self presentModalViewController:twitter animated:YES];
    }

}

-(void)facebook{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                
                NSLog(@"Cancelled");
                
            } else
            {
                NSLog(@"Done");
            }
            
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        controller.completionHandler =myBlock;
        
        //Adding the Text to the facebook post value from iOS
        
        NSString* message = @"Welcome to PinAve. I found there many useful and interesting stuff: ";
        [controller setInitialText:message];
        
        
        //Adding the URL to the facebook post value from iOS
        NSString * urlPath = @"http://pinave.com/user/create?refer=TEdY89CwGtUDTJF0hr";
        [controller addURL:[NSURL URLWithString:urlPath]];
        
        
         //Adding the Text to the facebook post value from iOS
        NSString * imageName = @"icon512";
         [controller addImage:[UIImage imageNamed:imageName]];
         
        [self presentViewController:controller animated:YES completion:Nil];
        
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a facebook right now, make sure \
                                  your device has an internet connection and you have \
                                  at least one Facebook account setup"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
    
}

- (void) twitter {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        NSString* message = @"Welcome to PinAve. I found there many useful and interesting stuff: ";
        [tweetSheet setInitialText:message];
        
      
        NSString * urlPath = @"http://pinave.com/user/create?refer=TEdY89CwGtUDTJF0hr";
        [tweetSheet addURL:[NSURL URLWithString:urlPath]];
        
 
//        NSString * imageName = @"icon.png";
//        if([UIImage imageNamed:imageName])
//        {
//            [tweetSheet addImage:[UIImage imageNamed:imageName]];
//        }
        
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure \
                                  your device has an internet connection and you have \
                                  at least one Twitter account setup"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}


#pragma mark 
#pragma mark ----------- 
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {   
    return YES;
}


-(void) onFullImage:(UITapGestureRecognizer*) gesture {
    
    if (pinImgViw.image != nil) {
        [aiFullImage startAnimating];
        
        viewFullImage.alpha = 1.0f;
        viewFullImage.frame = self.view.frame;
        [self.view addSubview:viewFullImage];
        
        
        NSString *url = [pinInfo objectForKey:@"image"];
        NSLog(@"url = %@", url);
        if ([url rangeOfString:@"http"].location == NSNotFound) {
            url = [NSString stringWithFormat:@"%@%@", SERVER_URL, url];
        }
        
        if ([url rangeOfString:@"url=uploads"].location != NSNotFound) {
            int p1 = [url rangeOfString:@"uploads"].location;
            
            url = [NSString stringWithFormat:@"%@%@", SERVER_URL, [url substringFromIndex:p1]];
        }
        
        if ([url rangeOfString:@".png"].location != NSNotFound
            || [url rangeOfString:@"jpg"].location != NSNotFound
            || [url rangeOfString:@"jpeg"].location != NSNotFound) {
            
        } else {
            url = [NSString stringWithFormat:@"%@.png", url];
        }
        
        
        int p = [url rangeOfString:@"url="].location;
        NSString * imgUrl;
        if (p != NSNotFound) {
            imgUrl = [url substringFromIndex:p + 4];
        } else {
            imgUrl = url;
        }
        
        p = [imgUrl rangeOfString:@"&w="].location;
        if (p != NSNotFound) {
            imgUrl = [imgUrl substringToIndex:p];
        }
        NSLog(@"img url = %@", imgUrl);
        
        
        [ivFullImage loadFromURL:[NSURL URLWithString:imgUrl]];
        
//        float rotations = 2;
//        float duration = 0.5;
//        CABasicAnimation* rotationAnimation;
//        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
////        rotationAnimation.toValue = [NSNumber numberWithFloat:1];
//        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
//        rotationAnimation.duration = duration;
//        rotationAnimation.cumulative = YES;
//        rotationAnimation.repeatCount = 1.0; 
//        rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//        
//        [viewFullImage.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        
        viewFullImage.alpha = 0.0f;

        [UIView beginAnimations:@"" context:nil];
        [UIView setAnimationDuration:0.5];
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector:@selector(animationEnd)];
        viewFullImage.alpha = 1.0f;
        
        [UIView commitAnimations];

    }
}

- (IBAction) onBackFullImage:(id)sender
{
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationEnd)];
    viewFullImage.alpha = 0.0f;
    
    [UIView commitAnimations];
}
-(void) animationEnd {
    [viewFullImage removeFromSuperview];
    viewFullImage.alpha = 1.0f;
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    aiFullImage.hidden = YES;
    
    return ivFullImage;
}

#pragma mark Show all contacts
// Called when users tap "Display Picker" in the application. Displays a list of contacts and allows users to select a contact from that list.
// The application only shows the phone, email, and birthdate information of the selected contact.
-(void)showPeoplePickerController
{
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
	// Display only a person's phone, email, and birthdate
	NSArray *displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty], 
                               [NSNumber numberWithInt:kABPersonEmailProperty],
                               [NSNumber numberWithInt:kABPersonBirthdayProperty], nil];
	
	
	picker.displayedProperties = displayedItems;
	// Show the picker 
	[self presentModalViewController:picker animated:YES];
}

/*
 #pragma mark Display and edit a person
 // Called when users tap "Display and Edit Contact" in the application. Searches for a contact named "Appleseed" in 
 // in the address book. Displays and allows editing of all information associated with that contact if
 // the search is successful. Shows an alert, otherwise.
 -(void)showPersonViewController
 {
 // Fetch the address book 
 ABAddressBookRef addressBook = ABAddressBookCreate();
 // Search for the person named "Appleseed" in the address book
 NSArray *people = (NSArray *)ABAddressBookCopyPeopleWithName(addressBook, CFSTR("Vug"));
 // Display "Appleseed" information if found in the address book 
 if ((people != nil) && [people count])
 {
 ABRecordRef person = (ABRecordRef)[people objectAtIndex:0];
 CustomAbPerson *picker = [[[CustomAbPerson alloc] init] autorelease];
 picker.personViewDelegate = self;
 picker.displayedPerson = person;
 // Allow users to edit the person’s information
 picker.allowsEditing = YES;
 [self.navigationController pushViewController:picker animated:YES];
 }
 else 
 {
 // Show an alert if "Appleseed" is not in Contacts
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
 message:@"Could not find Appleseed in the Contacts application" 
 delegate:nil 
 cancelButtonTitle:@"Cancel" 
 otherButtonTitles:nil];
 [alert show];
 [alert release];
 }
 
 [people release];
 CFRelease(addressBook);
 }
 */

#pragma mark Create a new person
// Called when users tap "Create New Contact" in the application. Allows users to create a new contact.
-(void)showNewPersonViewController
{
	ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
	picker.newPersonViewDelegate = self;
	
	UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
	[self presentModalViewController:navigation animated:YES];
}


#pragma mark Add data to an existing person
// Called when users tap "Edit Unknown Contact" in the application. 
-(void)showUnknownPersonViewController
{
	ABRecordRef aContact = ABPersonCreate();
	CFErrorRef anError = NULL;
	ABMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	bool didAdd = ABMultiValueAddValueAndLabel(email, @"John-Appleseed@mac.com", kABOtherLabel, NULL);
	
	if (didAdd == YES)
	{
		ABRecordSetValue(aContact, kABPersonEmailProperty, email, &anError);
		if (anError == NULL)
		{
			ABUnknownPersonViewController *picker = [[ABUnknownPersonViewController alloc] init];
			picker.unknownPersonViewDelegate = self;
			picker.displayedPerson = aContact;
			picker.allowsAddingToAddressBook = YES;
		    picker.allowsActions = YES;
			picker.alternateName = @"John Appleseed";
			picker.title = @"John Appleseed";
			picker.message = @"Company, Inc";
			
			[self.navigationController pushViewController:picker animated:YES];
		}
		else 
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
															message:@"Could not create unknown user" 
														   delegate:nil 
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:nil];
			[alert show];
		}
	}	
	CFRelease(email);
	CFRelease(aContact);
}


#pragma mark ABPeoplePickerNavigationControllerDelegate methods
// Displays the information of a selected person
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{

    ABMultiValueRef addresses = nil;
//    m_tfFirstName.text = @"";
//    m_tfLastName.text = @"";
//    m_tfEmail.text = @"";
//    m_tfCell.text = @"";
//    
//    m_tfFirstName.text = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
//    m_tfLastName.text = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    addresses = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonEmailProperty);
    NSString * emailAddress;
    if(ABMultiValueGetCount(addresses) > 0) {
        CFStringRef emailAddressRef = ABMultiValueCopyValueAtIndex(addresses, 0);
        emailAddress = (__bridge NSString *)ABAddressBookCopyLocalizedLabel(emailAddressRef);
    }
    
    
//    addresses = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonPhoneProperty);
//    CFStringRef phoneAddressRef = ABMultiValueCopyValueAtIndex(addresses, 0);
//    NSString *strPhone = (__bridge NSString *)ABAddressBookCopyLocalizedLabel(phoneAddressRef);
//    strPhone = [strPhone stringByReplacingOccurrencesOfString:@"+" withString:@""];
//    strPhone = [strPhone stringByReplacingOccurrencesOfString(angry)" " withString:@""];
//    m_tfCell.text = [self formatPhoneString:strPhone];
    
    [peoplePicker dismissModalViewControllerAnimated:NO];
    
    NSArray * emails = [[NSArray alloc] initWithObjects:emailAddress, nil];
    [self shareEmail:emails];

	return YES;
}


// Does not allow users to perform default actions such as dialing a phone number, when they select a person property.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	return NO;
}


// Dismisses the people picker and shows the application when users tap Cancel. 
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark ABPersonViewControllerDelegate methods
// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person 
					property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
	return NO;
}


#pragma mark ABNewPersonViewControllerDelegate methods
// Dismisses the new-person view controller. 
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark ABUnknownPersonViewControllerDelegate methods
// Dismisses the picker when users are done creating a contact or adding the displayed person properties to an existing contact. 
- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person
{
	[self dismissModalViewControllerAnimated:YES];
}


// Does not allow users to perform default actions such as emailing a contact, when they select a contact property.
- (BOOL)unknownPersonViewController:(ABUnknownPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person 
						   property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	return NO;
}
@end
