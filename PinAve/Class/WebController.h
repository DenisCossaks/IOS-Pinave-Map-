//
//  WebController.h
//  GrouplyDeals
//
//  Created by champion on 11. 8. 3..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebController : UIViewController {
	IBOutlet UIView				*m_viwLoading;
	IBOutlet UIActivityIndicatorView	*m_actLoading;
	
    IBOutlet UIWebView	*m_viwWeb;
}

@property (nonatomic, strong) NSString		*m_urlPost;


- (IBAction)onBack:(id)sender;


@end
