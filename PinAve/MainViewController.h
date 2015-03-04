//
//  MainViewController.h
//  LocationWeather
//
//  Created by Yuan Luo on 4/24/13.
//  Copyright (c) 2013 Sun Zhe. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UserSession.h"


@interface MainViewController : UIViewController<UserSessionDelegate>
{
    UIImageView *m_SplashView;
    
    UIActivityIndicatorView * loadingView;
}

- (void) gotoHomePage;
- (void) gotoMainPage;

@end
