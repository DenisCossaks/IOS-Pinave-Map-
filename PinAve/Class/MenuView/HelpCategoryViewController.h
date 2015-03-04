//
//  CategoryViewController.h
//  NEP
//
//  Created by Gold Luo on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpCategoryViewController : UIViewController
{
    IBOutlet UIView     * viewBoard;
    IBOutlet UIScrollView * scrollView;
}

- (IBAction) onBack:(id)sender;

@end
