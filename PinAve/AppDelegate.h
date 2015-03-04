//
//  AppDelegate.h
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

#import <FacebookSDK/FacebookSDK.h>

@class DKTabBarViewController;
@class DKTabBarItem;


@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, CLLocationManagerDelegate>
{
    DKTabBarViewController *tabBarController;
    UINavigationController* categoryNavController;

    NSTimer * _timerScan;
    NSTimer * _timerScan1;
    
    BOOL m_bShowLocalMsg;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController * viewController;
@property (nonatomic, retain) DKTabBarViewController *tabBarController;
@property (nonatomic, strong)     DKTabBarItem* categoryTabBarItem;
@property (nonatomic, strong)     DKTabBarItem* chatTabBarItem;

- (void) initTabBar;
- (void) setTabbarIndex:(int) _index;
- (void) setTabBarHidden: (BOOL)hidden animated: (BOOL)animated;
- (void) setNotifyTabbar:(BOOL) bEnable;
- (void) setChatTabbar:(BOOL) bEnable;

- (BOOL) isScanThread;
- (void) stopScanThread;
- (void) startScanThread;

- (BOOL) isSelectedAnyNoti;
- (BOOL) isSelectedAnySearch;

@end
