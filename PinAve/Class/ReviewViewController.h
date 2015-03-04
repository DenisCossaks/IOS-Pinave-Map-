//
//  ReviewViewController.h
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "JsonReader.h"
#import "IAMultipartRequestGenerator.h"


@interface ReviewViewController : UIViewController<EGORefreshTableHeaderDelegate, JsonReaderDelegate, IAMultipartRequestGeneratorDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UITableView * m_table;
    IBOutlet UITextField * m_tfCountry;
    IBOutlet UIView      * m_viewMsg;
    IBOutlet UITextView  * m_tvMsg;
    
    NSMutableArray * arrPublishChart;
    
    BOOL bIsReviewed;
    
    BOOL keyboardVisible;
    
    BOOL m_bFirstPass;
}

@property (nonatomic, assign) int nPinId;


-(IBAction) onBack:(id)sender;
-(IBAction) onSendMsg:(id)sender;

-(IBAction) onKeyboardDone:(id)sender;

@end
