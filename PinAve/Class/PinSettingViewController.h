//
//  PinSettingViewController.h
//  NEP
//
//  Created by Gold Luo on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITimezoneView.h"


@interface SettingCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *iconImg;
@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) IBOutlet UIImageView *selectedImg;

@end


@class PinSettingViewController;
@protocol SettingDelegate
- (void) closeForUpdate;
@end

@interface PinSettingViewController : UIViewController<TimezoneViewDelegate>
{
    IBOutlet UITextField        * tfStartDate;
    IBOutlet UITextField        * tfEndDate;    
    
    IBOutlet UISlider           * slRadius;
    IBOutlet UILabel            * lbRadius;
    IBOutlet UILabel            * lbUnit;
    
//    IBOutlet UISegmentedControl * scRadius;
    IBOutlet UISegmentedControl * scPins;
    IBOutlet UITextField        * tfTimezone;
    IBOutlet UISegmentedControl * scMapmode;
    
    IBOutlet UIScrollView       * scrollView;
    
    IBOutlet UITableView        * tvCategory;
    
    IBOutlet UIView             * viewDateFrame;
    IBOutlet UIDatePicker       * pickerDate;
    BOOL    pickerDateVisible;
    
    BOOL pickerTimeZoneVisible;
    UITimezoneView * timezonePicker;
    

    
    SettingCell *creatingCell;
    
    UIPopoverController * popoverController;
    IBOutlet UIPickerView *    pickerTiemzone;
    
}

@property (assign) id<SettingDelegate> delegate;
@property (strong, nonatomic) NSArray *categoryList;


- (void) setInterface;

-(IBAction)next:(id)sender;

-(IBAction)onCancel:(id)sender;
-(IBAction)onUpdate:(id)sender;
-(IBAction)onTappedRadius:(UISegmentedControl*)sender;
-(IBAction)onTappedPins:(UISegmentedControl*)sender;
-(IBAction)onTappedView:(UISegmentedControl*)sender;
-(IBAction)changeRadius:(UISlider*)sender   ;

-(IBAction)onDone:(id)sender;



-(IBAction)dateChange:(id)sender;


@end
