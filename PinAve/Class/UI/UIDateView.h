//
//  UIDateView.h
//  NEP
//
//  Created by Gold Luo on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIDateView;
@protocol DateViewDelegate

- (void) closeDateView;

@end


@interface UIDateView : UIView
{
    IBOutlet UIDatePicker * datePicker;
}

@property (nonatomic, strong) UITextField * textField;
@property (nonatomic, strong) id<DateViewDelegate> delegate;

- (void) setDateProperty : (UIDatePickerMode) mode;
- (void) setDate : (NSDate*) _date;


- (IBAction)dateChange:(id)sender;
- (IBAction)onDone:(id)sender;


@end
