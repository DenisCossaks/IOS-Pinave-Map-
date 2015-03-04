//
//  EveryDayController.h
//  NEP
//
//  Created by Gold Luo on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class EveryDayController;
@protocol EveryDayDelegate

- (void) setEveryDay:(int) _day;

@end


@interface EveryDayController : UIViewController
{
    UIPickerView * picker;
    
    NSArray * arrayDays; 
    
    int nSelect;
}

@end
