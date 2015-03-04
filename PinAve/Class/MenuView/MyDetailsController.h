//
//  MyDetailsController.h
//  NEP
//
//  Created by Dandong3 Sam on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IAMultipartRequestGenerator.h"
#import "JsonReader.h"

typedef enum _GENDER{
    MALE,
    FOMALE,
}GENDER;

@interface MyDetailsController : UIViewController<IAMultipartRequestGeneratorDelegate, JsonReaderDelegate>
{
    IBOutlet UIView       * viewMain;
    IBOutlet UIScrollView * viewScroll;
    IBOutlet UITextField * tfFirstName;
    IBOutlet UITextField * tfLastName;
    IBOutlet UITextField * tfBirthday;
//    IBOutlet UISegmentedControl * scGender;
    IBOutlet UITextField * tfCountry;
    IBOutlet UITextField * tfCity;
    IBOutlet UITextField * tfState;
    IBOutlet UITextField * tfTimezone;
    IBOutlet UITextField * tfPhone;
    IBOutlet UITextField * tfPassword;
    IBOutlet UITextField * tfConfirm;
    IBOutlet UITextField * tfEmail;
    
    IBOutlet UIView* viewSubDate;
    IBOutlet UIDatePicker * pvDate;
    
    IBOutlet UIView* viewSubTimezone;
    IBOutlet UIPickerView * pvTimezone;
    
    IBOutlet UIButton   *btnMale;
    IBOutlet UIButton   *btnFemale;
    GENDER  curGender;
    
    NSTimeZone *prevTZ;
    NSMutableDictionary *timeZoneDic;
    NSArray *continentArray;
    NSArray *regionArray;

    
    BOOL timezone_visible;    
    BOOL date_visible;
    BOOL country_visible;
    
    BOOL keyboardVisible;
    CGPoint offset;
    CGRect originalFrame;
    
    
    UIPopoverController* popoverController;
    
    // country list
    IBOutlet UIView* viewSubCounty;
    IBOutlet UIPickerView * pvCountry;
    NSMutableArray * countriesArray;
}



-(IBAction) onBack:(id)sender;
-(IBAction) onUpdate:(id)sender;

-(IBAction) onTappedGender:(UISegmentedControl *) sender;
-(IBAction) onChangedBirthday:(id) sender;
-(IBAction) onDateDone:(id) sender;
-(IBAction) onTimeZoneDone:(id) sender;
-(IBAction) onCountryDone:(id) sender;

- (IBAction)next:(id)sender;

- (IBAction) onMale:(id)sender;
- (IBAction) onFemale:(id)sender;

- (void) setInterface;
- (void) getRequest;
- (void) setTimeZoneValue;


- (void)hideTimeView;
- (void)showTimeview;

- (void)hideDateView;
- (void)showDateview;

@end
