//
//  UIDateView.m
//  NEP
//
//  Created by Gold Luo on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIDateView.h"

@implementation UIDateView

@synthesize textField;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void) setDateProperty : (UIDatePickerMode) mode{
    datePicker.datePickerMode = mode;
}

- (void) setDate : (NSDate*) _date {
    datePicker.date = _date;
}


- (IBAction)dateChange:(id)sender{
    
    NSDate * date = datePicker.date;
    
    self.textField.text = [Utils getDateString:date :DATE_FULL];
}


- (IBAction)onDone:(id)sender{
    [delegate closeDateView];
    
    if (!iPad) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.4f];
        
        [self removeFromSuperview];
        
        [UIView commitAnimations];
    }
}

@end
