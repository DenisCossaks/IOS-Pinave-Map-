//
//  TermsServiceController.h
//  NEP
//
//  Created by  Yuan Luo on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TermsServiceController : UIViewController
{
    IBOutlet UIView         * viewBoard;
    IBOutlet UIScrollView * scrollView;
    IBOutlet UIView         * txtView;
    IBOutlet UIWebView   * m_webView;
    
}

@property (nonatomic, assign) BOOL m_bMode;


-(IBAction)onBack:(id)sender;

@end
