//
//  AvenueDetailViewController.h
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JsonReader.h"

@interface AvenueDetailViewController : UIViewController<JsonReaderDelegate>
{
    IBOutlet UILabel     * lbTitle;
    IBOutlet UILabel     * lbLocation;
    IBOutlet UILabel     * lbTimezone;
    IBOutlet UILabel     * lbLogin;
    
    IBOutlet UITableView * m_table;
    
    NSMutableDictionary * userInfo;
    NSMutableArray      * userPins;
    
}

@property (nonatomic, strong) NSDictionary * user;

- (IBAction)onBack:(id)sender;

@end
