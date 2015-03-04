//
//  SendMessageController.h
//  PinAve
//
//  Created by Optiplex790 on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAMultipartRequestGenerator.h"

@interface SendMessageController : UIViewController<IAMultipartRequestGeneratorDelegate>
{
    IBOutlet UILabel * lbName;
    IBOutlet UITextView * tvMessage;
}

@property (strong, nonatomic) NSMutableDictionary *pinInfo;

-(IBAction) onBack:(id)sender;
-(IBAction) onSend:(id)sender;

@end
