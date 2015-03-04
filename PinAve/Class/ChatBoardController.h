//
//  ChatBoardController.h
//  PinAve
//
//  Created by Gold Luo on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAMultipartRequestGenerator.h"
#import "JsonReader.h"

@interface ChatBoardController : UIViewController<IAMultipartRequestGeneratorDelegate, JsonReaderDelegate>
{
    IBOutlet UILabel * lbReceiveName;
    IBOutlet UITableView * m_table;
    
    IBOutlet UIView * viewSend;
    IBOutlet UITextField * tfSend;
    

    //////////////////////////////    //////////////////////////////
    
    NSMutableArray * arrayMsg;
    
    NSString    * strReceiveChatId;
    
    
    
    BOOL    keyboardVisible;
}

@property (nonatomic, strong) NSMutableDictionary * receiveInfo;
@property (nonatomic, strong) NSMutableDictionary * userInfo;

-(IBAction) onBack;
-(IBAction) onSend;
-(IBAction) next;

@end
