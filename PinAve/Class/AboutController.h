//
//  AboutController.h
//  PinAve
//
//  Created by Gold Luo on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MFMailComposeViewController.h>//mail controller

@interface AboutController : UIViewController<MFMailComposeViewControllerDelegate>
{
    IBOutlet UITableView * m_tableView;
    
    NSMutableArray *sectionAry;

}

- (IBAction)onBack:(id)sender;

@end
