//
//  ChartViewController.h
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "JsonReader.h"
#import "IAMultipartRequestGenerator.h"


@interface ChartViewController : UIViewController<EGORefreshTableHeaderDelegate, JsonReaderDelegate, IAMultipartRequestGeneratorDelegate>
{
    IBOutlet UITableView * m_table;
    IBOutlet UITextField * m_tfCountry;
    IBOutlet UIView      * m_viewMsg;
    IBOutlet UITextView  * m_tvMsg;
    
    NSMutableArray * arrPublishChart;
    
    
    BOOL keyboardVisible;

    
    BOOL m_bFirstPass;
}


-(IBAction) onMyAvenue:(id)sender;
-(IBAction) onUsers:(id)sender;
-(IBAction) onChangeLocation:(id)sender;

-(IBAction) onSendMsg:(id)sender;

-(IBAction) onKeyboardDone:(id)sender;

@end
