//
//  PinDetailController.h
//  NEP
//
//  Created by Dandong3 Sam on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import <MessageUI/MFMailComposeViewController.h>//mail controller

#import "DLStarRatingControl.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"



enum _PIN_STATUE {
    PIN_USER,
    PIN_SYSTEM,
    PIN_OTHER,
    };


@class PinDetailController;

@protocol PinDetailControllerDelegate

- (void) closeDirectToHere:(NSMutableDictionary*) _info;
- (void) closeDirectFromHere:(NSMutableDictionary*) _info;
- (void) closeDeletePin;

@end


@interface PinDetailController : UIViewController<MFMailComposeViewControllerDelegate, DLStarRatingDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, ABPeoplePickerNavigationControllerDelegate,
ABPersonViewControllerDelegate, ABNewPersonViewControllerDelegate, ABUnknownPersonViewControllerDelegate, UIScrollViewDelegate>
{
    IBOutlet UIView  * viewTitle;
    IBOutlet UILabel * lbTitle;
    IBOutlet UILabel * lbPinBy;
    IBOutlet UILabel * lbExpire;
    IBOutlet UIButton * btnReview;
    
    IBOutlet UILabel *  lbVotes;
    IBOutlet UIImageView *pinImgViw;
    IBOutlet UILabel *titleLbl;
    IBOutlet UILabel *lbFullAddress;
    
    IBOutlet UIView  *viewAddress;
    IBOutlet UILabel *addressLbl;
    IBOutlet UILabel *cityLbl;
    IBOutlet UILabel *countryLbl;
    
    IBOutlet UILabel *lbBtnDicTo;
    IBOutlet UILabel *lbBtnDicFrom;
    
    IBOutlet UIButton * btnMyAvenue;
    IBOutlet UIButton * btnMessage;
    
//    IBOutlet UITextView * tvDescription;
    IBOutlet UIWebView * tvDescription;

    IBOutlet UIView * viewFullImage;
    IBOutlet UIImageView * ivFullImage;
    IBOutlet UIActivityIndicatorView * aiFullImage;
    
    
    NSString* m_strPinId;
    
    DLStarRatingControl * ratingControl;
    int     m_nRating;
    BOOL    m_bEnableRating;

    
    enum _PIN_STATUE    nPinStatue;
    
    int    bIsAddUser;
    int    bIsAddPin;
    
    BOOL    m_bRefreshed;
    BOOL    m_bLoadingDone;
    
    int m_nLoadingCount;
}

@property (strong, nonatomic) NSMutableDictionary *pinInfo;
@property (strong, nonatomic) id<PinDetailControllerDelegate> delegate;

- (IBAction)onBack:(id)sender;
- (IBAction)onReview:(id)sender;
- (IBAction)onDirectToHere:(id)sender;
- (IBAction)onDirectFromHere:(id)sender;
- (IBAction)onAddToContact:(id)sender;
- (IBAction)onReferToFriend:(id)sender;
- (IBAction)onSendMessage:(id)sender;


- (void) shareEmail;
- (void) shareFacebook;
- (void) shareTwitter;

- (void) submitRating;


- (IBAction) onBackFullImage:(id)sender;

@end
