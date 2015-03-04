//
//  SettingViewController.h
//  PinAve
//
//  Created by Gold Luo on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UserSession.h"

@interface SettingViewController : UIViewController<UserSessionDelegate>
{
    IBOutlet UITableView * table;
    
    NSArray *sectionAry;
    
}

- (IBAction) onAbout:(id)sender;

@end
