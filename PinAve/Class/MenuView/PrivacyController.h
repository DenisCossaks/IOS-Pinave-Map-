//
//  PrivacyController.h
//  NEP
//
//  Created by Dandong3 Sam on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivacyController : UIViewController
{
    IBOutlet UIView         * viewBoard;
    IBOutlet UIScrollView * scrollView;
    IBOutlet UIView         * txtView;
}

@property (nonatomic, assign) BOOL m_bMode;


-(IBAction)onBack:(id)sender;

@end
