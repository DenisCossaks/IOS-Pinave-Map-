//
//  NotificationsController.h
//  NEP
//
//  Created by Dandong3 Sam on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationsController : UIViewController
{
    IBOutlet UITableView * table;
    
    
    NSMutableArray * arrSelectedCategory;
    
    UIScrollView * scroll;
 
    UILabel * labelTitle;
    UILabel * labelContent;
    
    // IPad
    UIPopoverController * popoverController;
    IBOutlet UISegmentedControl * scDistance;
    IBOutlet UIDatePicker       * datePicker;
    IBOutlet UISegmentedControl * scMinute;
}

@property (nonatomic, strong) NSArray * listCategory;


// IPad
- (IBAction) changeDistance : (UISegmentedControl*) sender ;
- (IBAction) changeDate: (UIDatePicker* ) sender;
- (IBAction) changeMinute:(UISegmentedControl*) sender;


@end
