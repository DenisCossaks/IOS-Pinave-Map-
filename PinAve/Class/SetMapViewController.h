//
//  SetMapViewController.h
//  PinAve
//
//  Created by Gold Luo on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetMapViewController : UIViewController
{
    IBOutlet UITableView * m_tableView;
    
    int nSelect;
}

-(IBAction) onBack:(id)sender;

@end
