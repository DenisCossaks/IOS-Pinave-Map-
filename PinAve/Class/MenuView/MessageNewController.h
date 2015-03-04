//
//  MessageNewController.h
//  NEP
//
//  Created by Dandong3 Sam on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JsonReader.h"

@interface MessageNewController : UIViewController <JsonReaderDelegate>

@property (strong, nonatomic) IBOutlet UITextField *toAddressFld;
@property (strong, nonatomic) IBOutlet UITextView *messageTxt;

- (IBAction)onCancel:(id)sender;
- (IBAction)onSend:(id)sender;

@end
