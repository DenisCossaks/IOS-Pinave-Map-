//
//  UITimezoneView.h
//  NEP
//
//  Created by Gold Luo on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UITimezoneView;
@protocol TimezoneViewDelegate

- (void) closeTimezoneView;

@end

@interface UITimezoneView : UIView
{
    IBOutlet UIPickerView * picker;

    NSMutableArray * listFirst;
    NSMutableArray * listSecond;    
    NSMutableDictionary *timeZoneDic;

}

@property (nonatomic, strong) UITextField * textField;
@property (nonatomic, strong) id<TimezoneViewDelegate> delegate;


-(IBAction)onDone:(id)sender;
-(void) setTimezonePicker;

@end
