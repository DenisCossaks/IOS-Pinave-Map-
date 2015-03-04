//
//  AdvancedScheduleViewController.h
//  NEP
//
//  Created by Gold Luo on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AdvancedScheduleViewController;

@protocol AdvancedScheduleDelegate

-(void) setAdvancedSchedule:(int) _simple : (int) _days : (NSString *)_startDate :(NSString *)_endDate :(NSString *)_frequecy :(int)_repeat :(int)_every;

@end

@interface AdvancedScheduleViewController : UIViewController
{
    BOOL                       m_bSimple;
    
    IBOutlet UIView          * viewSimpleDark;
    IBOutlet UILabel         * lbDays;
    IBOutlet UISlider        * slDays;
    
    IBOutlet UIView          * viewSchedule;
    IBOutlet UIView          * viewAdvanceDark;
    
    IBOutlet UIView          * viewDate;
    IBOutlet UITextField     * tfStartDate;
    IBOutlet UITextField     * tfEndDate;
    
    IBOutlet UIView          * viewFrequency;
    IBOutlet UITextField     * tfFrequency;
    
    IBOutlet UIView          * viewRepetition;
    IBOutlet UITextField     * tfRepetition;
    IBOutlet UISlider        * slRepetition;
    
    IBOutlet UIView          * viewEvery;
    IBOutlet UITextField     * tfEvery;
    IBOutlet UISlider        * slEvery;
    IBOutlet UILabel         * lbEvery_days;
    
    IBOutlet UIView  * viewDatePicker;
    IBOutlet UIDatePicker * pkDate;
    BOOL    pickerDateVisible;

    IBOutlet UIView  * viewMultiPicker;
    IBOutlet UIPickerView * pkMulti;
    BOOL    pickerVisible;
    
    
    NSMutableArray * arrayPicker;
    
    UIPopoverController* popoverController;
    
}

@property (nonatomic, strong) id<AdvancedScheduleDelegate> delegate;

- (void) setInterface :(int) _days : (NSString*) _startDate : (NSString*) _endDate : (NSString*) _frequence : (int) _repeat : (int) _every;

- (IBAction) chagneSliderDays;

- (IBAction) changeTextRepetition;
- (IBAction) changeSliderRepetition;

- (IBAction) changeTextEvery;
- (IBAction) changeSliderEvery;

- (IBAction) onSimple:(id)sender;
- (IBAction) onAdvanced:(id)sender;
- (IBAction) next;
- (IBAction) onSaveSchedule : (id) sender;

- (IBAction) changeDate:(id)sender;
- (IBAction) onDateDone:(id)sender;

- (IBAction) onPickerDone:(id)sender;


-(NSMutableArray*) getType : (NSDate*) start : (NSDate*) end;

@end
