//
//  FriendViewController.h
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"


@interface FriendViewController : UIViewController
{
    IBOutlet UITableView * m_table;
    
    NSMutableArray * arrSearch;
    
    int m_nDeletedIndex;
}

-(IBAction)onBack:(id)sender;

@end
