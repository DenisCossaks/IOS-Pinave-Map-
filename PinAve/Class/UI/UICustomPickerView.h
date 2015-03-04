//
//  UICustomPickerView.h
//  NEP
//
//  Created by Gold Luo on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICustomPickerView : UIView
{
    IBOutlet UIPickerView * picker;
}

@property (nonatomic, strong) UITextField * textField;
@property (nonatomic, strong) NSMutableArray *listPicker;


-(IBAction)onDone:(id)sender;

@end
