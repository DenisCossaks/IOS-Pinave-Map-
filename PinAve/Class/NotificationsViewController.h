//
//  NotificationsViewController.h
//  PinAve
//
//  Created by Gold Luo on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationsViewController : UIViewController
{
    IBOutlet UISwitch * switchSet;
    IBOutlet UIView * viewSubAll;
    
    IBOutlet UIButton * btnBack;
    IBOutlet UIButton * btnSet;
    
    // radius
    IBOutlet UILabel * lbRadius;
    IBOutlet UILabel * lbUnit;
    IBOutlet UISlider * slRadius;
    
    // scan every
    IBOutlet UILabel * lbMin;
    IBOutlet UISlider * slScan;
    
    // set
    IBOutlet UILabel * lbHour;
    IBOutlet UISlider * slNotify;
    
    
    
    NSString * _statusbarimage;
    BOOL    _responds;
}

@property (nonatomic, assign) BOOL m_bPresent;

- (void) setInterface;


- (IBAction)onBack:(id)sender;

- (IBAction)changeSwitchSet:(UISwitch*)sender;
- (IBAction)onWithCategory:(id)sender;
- (IBAction)changeRadius:(UISlider*)sender;
- (IBAction)changeScan:(UISlider*)sender;
- (IBAction)changeSet:(UISlider*)sender;
- (IBAction)onSet:(id)sender;

@end
