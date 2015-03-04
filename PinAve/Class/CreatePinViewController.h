//
//  CreatePinViewController.h
//  NEP
//
//  Created by Gold Luo on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SelectCategoryController.h"
#import "AdvancedScheduleViewController.h"
#import "IAMultipartRequestGenerator.h"

#import <MessageUI/MFMailComposeViewController.h>//mail controller

#import <MapKit/MapKit.h>

@interface CreatePinViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate,
                                        SelectCategoryDelegate, AdvancedScheduleDelegate, IAMultipartRequestGeneratorDelegate, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate>
{
//    IBOutlet UIButton    * btnUpdate;
    IBOutlet UIImageView * imgUpdate;
    
    IBOutlet UITextField * tfTitle;
    IBOutlet UIImageView * ivIcon;
    IBOutlet UILabel     * lbFullAddress;
    IBOutlet UITextView  * tvDiscription;
    IBOutlet UIButton    * btnDptDone;
    IBOutlet UIButton    * btnDptDone1;

    IBOutlet UIView      * viewEditAddress;
    IBOutlet UITextField * tfAddress;
    IBOutlet UITextField * tfCity;
    IBOutlet UITextField * tfState;
    IBOutlet UITextField * tfCountry;

    IBOutlet MKMapView *  m_mapPin;

    IBOutlet UITableView * m_tableView;
    
    NSData* imgData;
    
    UIPopoverController * m_popoverController;
    
    BOOL    keyboardVisible;
    CGPoint offset;
    CGRect  originalFrame;
    
    
#pragma mark ---- Pin Information ------
    int m_nCategoryId;
    
    NSString * m_strAddress;
    NSString * m_strCity;
    NSString * m_strState;
    NSString * m_strCountry;
    
    int        m_nDays;
    int        m_nSimple;
    
    NSString * m_strStartDate;
    NSString * m_strEndDate;
    NSString * m_strFrequency;
    int        m_nRepet;
    int        m_nEvery;
  
    
    UIPopoverController* popoverController;

}

@property (strong, nonatomic) NSDictionary *pinInfo;

- (IBAction) onCancel:(id)sender;
- (IBAction) onActivePin:(id) sender;
- (IBAction) onUploadImage :(id) sender;
- (IBAction) onClickedAddress:(id)sender;
- (IBAction) onNext;
- (IBAction) onPinSchedule;
- (IBAction) onSelectCategory;

- (IBAction) onEditSave:(id) sender;

- (IBAction) onDptDone:(id)sender;

@end
