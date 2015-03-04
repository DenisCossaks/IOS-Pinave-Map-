//
//  DateDetailController.h
//  NEP
//
//  Created by Gold Luo on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeteDetailController;
@protocol DateDetailDelegate

- (void) setDate :(NSDate*) _date ;

@end

@interface DateDetailController : UIViewController
{
    IBOutlet UIDatePicker * pickerDate;
}

@end
