//
//  MessageDetailController.h
//  NEP
//
//  Created by Dandong3 Sam on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JsonReader.h"

@interface MessageDetailController : UIViewController <JsonReaderDelegate>

@property (strong, nonatomic) NSDictionary *messageInfo;
@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) IBOutlet UILabel *fromLbl;
@property (strong, nonatomic) IBOutlet UILabel *toLbl;
@property (strong, nonatomic) IBOutlet UILabel *dateLbl;
@property (strong, nonatomic) IBOutlet UIWebView *messageViw;
@property (strong, nonatomic) IBOutlet UIScrollView *frameScrl;
@property (strong, nonatomic) IBOutlet UITextField *replyFld;
@property (strong, nonatomic) IBOutlet UIView *replyFrame;

- (IBAction)onSend:(id)sender;

@end
