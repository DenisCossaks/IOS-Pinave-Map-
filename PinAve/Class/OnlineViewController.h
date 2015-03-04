//
//  OnlineViewController.h
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface OnlineViewController : UIViewController<EGORefreshTableHeaderDelegate>
{
    IBOutlet UISearchBar * m_search;
    IBOutlet UITableView * m_table;
    
    
    NSMutableArray * arrChart;
    NSMutableArray * arrSearch;
    
}

@property (nonatomic, strong) NSMutableDictionary * userInfo;


- (IBAction)onGroupChart:(id)sender;
- (IBAction)onBack:(id)sender;

@end
