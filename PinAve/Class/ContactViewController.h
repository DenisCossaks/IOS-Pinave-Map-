//
//  ContactViewController.h
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "JsonReader.h"

@interface ContactViewController : UIViewController<EGORefreshTableHeaderDelegate, JsonReaderDelegate>
{
    IBOutlet UISearchBar * m_search;
    IBOutlet UITableView * m_table;
    
    NSMutableArray * arrSearch;
    
}

- (IBAction)onUsers:(id)sender;

@end
