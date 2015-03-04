//
//  ShareController.h
//  ChrismasBubble
//
//  Created by Kim SongIl on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TwitterManager.h"
//#import "FacebookManager.h"
#import <FacebookSDK/FacebookSDK.h>

typedef enum _tagShareMode {

    SHARE_TWITTER,
    SHARE_FACEBOOK,
    
} ShareMode;


@interface ShareController : UIViewController<TwitterManagerDelegate>
{
    
    NSDictionary *twitterMessage;
    
    IBOutlet UILabel * laTitle;
    
    IBOutlet UIView* roundBorderView;
    IBOutlet UITextView* descriptionView;
    IBOutlet UILabel*   characterLabel;
    IBOutlet UIImageView* characterBG;

    
    ShareMode shareMode;
    
    UIImage * imgShare;

}

@property (nonatomic, assign) ShareMode shareMode;


- (void)initWithMode:(int)mode;

- (IBAction)actionCancel:(id)sender;
- (IBAction)actionShare:(id)sender;


@end
