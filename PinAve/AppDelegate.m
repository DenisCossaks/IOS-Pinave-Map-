//
//  AppDelegate.m
//  PinAve
//
//  Created by Gold Luo on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "DKTabBarViewController.h"
#import "DKTabBarItem.h"


#import "CategoryViewController.h"
#import "ChartViewController.h"
#import "NotificationsViewController.h"
#import "PlacePInViewController.h"
#import "RouteViewController.h"
#import "SettingViewController.h"
#import "ContactViewController.h"

#import "Notification.h"
#import "UserRoundPin.h"


#import "FilterSearch.h"
#import "SearchViewController.h"
#import "Notification.h"

#import "UserSession.h"



#define NOTI_ADVANCE    @"NOTI_ADVANCE"


@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController;
@synthesize categoryTabBarItem, chatTabBarItem;

// FBSample logic
// If we have a valid session at the time of openURL call, we handle Facebook transitions
// by passing the url argument to handleOpenURL; see the "Just Login" sample application for
// a more detailed discussion of handleOpenURL
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // FBSample logic
    // if the app is going away, we close the session object
    [FBSession.activeSession close];
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UserLocationManager sharedInstance];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.viewController = [[MainViewController alloc] init];
    
    
    // make custom tabbar
//    [self initTabBar];    
    //tabBarController.navigationItem.prompt = @"Here is some text to make the navBar big";
    
//    [self.window addSubview:tabBarController.view];
    [self.window setRootViewController:self.viewController];

    [self.window makeKeyAndVisible];
    
    
    // Register for alert notifications
//    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
//    application.applicationIconBadgeNumber = 0;
    
    return YES;
}


#pragma mark Push Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	// Convert the token to a hex string and make sure it's all caps
	NSMutableString *tokenString = [NSMutableString stringWithString:[[deviceToken description] uppercaseString]];  
	[tokenString replaceOccurrencesOfString:@"<" withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];  
	[tokenString replaceOccurrencesOfString:@">" withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];  
	[tokenString replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];  
	
    
    NSLog(@"%@", tokenString);
    
    
    //store the devicetoken for registering to coursemob
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:tokenString forKey:@"deviceToken"];
    [defaults synchronize];
    
/*    
    NSString *url = [NSString stringWithFormat:@"http://www.123app.co.uk/pushnotifications_admin/register.php?devicetoken=%@", tokenString];
	//	NSLog(@"%@", url);
	
	NSError * error;
	
	NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:&error];
	
	NSString *message = [NSString stringWithFormat:@"Registered for remote notifications.\n Device token: %@.\n Server response: %@", tokenString, result];
	NSLog(@"%@", message);
    
	NSLog(@"Resgistered, deviceToken=%@", tokenString);
 
*/ 
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString *string = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]; 
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"PinAve"  
													message:string delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];  
	[alert show];  
	
	application.applicationIconBadgeNumber = 0;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   
/*
    if (!m_bLogInDone) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kRelogin object:nil];
    } 
    
    if (!m_bLoadingDone && [[UserSession session] isLoggedIn]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloading object:nil];
    }
*/    
    
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification 
{
//    if (!m_bShowLocalMsg) {
//        NSString * msg = notification.alertBody;
//        [[[UIAlertView alloc] initWithTitle:@"Notification Active!" message:msg delegate:self 
//                          cancelButtonTitle:nil 
//                          otherButtonTitles:@"View", @"Settings", @"Ok",  nil] show];
//        m_bShowLocalMsg = YES;
//    }

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    m_bShowLocalMsg = NO;
    
    if (buttonIndex == 0) { // view
        [self showSearchView];
        
    } else if (buttonIndex == 1) { // setting
        [self showNotificationView];
    } else if (buttonIndex == 2) { // turn off
        
        [Notification setNotify:NO];
        
        [self stopScanThread];
        [self setNotifyTabbar : NO];

    }
    
}

-(void) showSearchView
{
    [tabBarController setSelectedItemWithIndex:0];
    
    
    SearchViewController *vc;
    
    if (iPad) {
        vc = [[SearchViewController alloc] initWithNibName:@"SearchViewController-ipad" bundle:nil];
    } else {
        vc = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    }

    vc.m_nSearchMode = NOTIFY_MODE;

    vc.arrSelectedCategory  = [[NSMutableArray alloc] initWithCapacity:10];
        
    [vc.arrSelectedCategory removeAllObjects];
    [vc.arrSelectedCategory addObjectsFromArray:[Notification getCategory]];
        
//          NSLog(@"selected arry = %@", vc.arrSelectedCategory);

    [FilterSearch setCategory:vc.arrSelectedCategory];
    
    vc.m_bUpdated = YES;

    [vc refreshMap];
    
    [categoryNavController pushViewController:vc animated:NO];
    
}

- (void) showNotificationView
{
    [tabBarController setSelectedItemWithIndex:0];
    
    NotificationsViewController * vc;
    
    if (iPad) {
        vc = [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController-ipad" bundle:nil];
    } else {
        vc = [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController" bundle:nil];
    }
    
    vc.m_bPresent = YES;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [categoryNavController presentModalViewController:nav animated:NO];
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarHidden:YES animated:YES];

}


#pragma mark ------- Tab BAR

- (void) initTabBar {
    tabBarController = [[DKTabBarViewController alloc] init];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    UIImageView *tabBarBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_bar_bg"]];
    tabBarController.tabBarBGImageView = tabBarBGImageView;
    
    
    // ---------------------------------------------------------------------------
    // Category screen 
    
//    CategoryViewController* categoryViewController = [[CategoryViewController alloc] init];
//    categoryNavController = [[UINavigationController alloc] init]; //[[[NSBundle mainBundle] loadNibNamed:@"CustomNavigationBar" owner:self options:nil] lastObject];
//    [categoryNavController pushViewController:categoryViewController animated:NO];
    CategoryViewController * categoryViewController = [[CategoryViewController alloc] init];
    categoryNavController = [[UINavigationController alloc] initWithRootViewController:categoryViewController];
    
    
//    DKTabBarItem* categoryTabBarItem = [[DKTabBarItem alloc] init];
    categoryTabBarItem = [[DKTabBarItem alloc] init];    
    
    [self setNotifyTabbar:[Notification getNotify]];
//    [categoryTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_category"] forState:UIControlStateNormal];
//    [categoryTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_category_tap"] forState:UIControlStateSelected];
//    [categoryTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_names_tap"] forState:UIControlStateHighlighted];
    
    categoryTabBarItem.controller = categoryNavController;
    [items addObject: categoryTabBarItem];
    
    
    // ---------------------------------------------------------------------------
    // Chart screen 

    
    
//    ChartViewController* chatViewController = [[ChartViewController alloc] init];
//    UINavigationController* chatNavController = [[UINavigationController alloc] init]; 
//    [chatNavController pushViewController:chatViewController animated:NO];
//
//    DKTabBarItem* chatTabBarItem = [[DKTabBarItem alloc] init];
//    [chatTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_chat"] forState:UIControlStateNormal];
//    [chatTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_chat_tap"] forState:UIControlStateSelected];
//    [chatTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_chat_tap"] forState:UIControlStateHighlighted];
//    
//    chatTabBarItem.controller = chatNavController;
//    [items addObject:chatTabBarItem];

    ContactViewController* chatViewController = [[ContactViewController alloc] init];
    UINavigationController* chatNavController = [[UINavigationController alloc] init]; 
    [chatNavController pushViewController:chatViewController animated:NO];
    
    chatTabBarItem = [[DKTabBarItem alloc] init];
    
    [self setChatTabbar:[Notification isChat]];
//    [chatTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_chat"] forState:UIControlStateNormal];
//    [chatTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_chat_tap"] forState:UIControlStateSelected];
//    [chatTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_chat_tap"] forState:UIControlStateHighlighted];
    
    chatTabBarItem.controller = chatNavController;
    [items addObject:chatTabBarItem];

/*
    // ---------------------------------------------------------------------------
    // Notification screen 
    
    NotificationsViewController* chatViewController = [[NotificationsViewController alloc] init];
    chatViewController.m_bPresent = NO;
    UINavigationController* chatNavController = [[UINavigationController alloc] init]; 
    [chatNavController pushViewController:chatViewController animated:NO];
    
    DKTabBarItem* chatTabBarItem = [[DKTabBarItem alloc] init];
    [chatTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_noti"] forState:UIControlStateNormal];
    [chatTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_noti_tap"] forState:UIControlStateSelected];
    [chatTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_noti_tap"] forState:UIControlStateHighlighted];
    
    chatTabBarItem.controller = chatNavController;
    [items addObject:chatTabBarItem];
*/
    
    // ---------------------------------------------------------------------------
    // Place pin screen 
    
    PlacePInViewController* placeViewController = [[PlacePInViewController alloc] init];
    UINavigationController* placeNavController = [[UINavigationController alloc] init]; //[[[NSBundle mainBundle] loadNibNamed:@"CustomNavigationBar" owner:self options:nil] 
    [placeNavController pushViewController:placeViewController animated:NO];
    
    DKTabBarItem* placeTabBarItem = [[DKTabBarItem alloc] init];
    [placeTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_placepin"] forState:UIControlStateNormal];
    [placeTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_placepin_tap"] forState:UIControlStateSelected];
    [placeTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_placepin_tap"] forState:UIControlStateHighlighted];
    
    placeTabBarItem.controller = placeNavController;
    [items addObject:placeTabBarItem];
    
    
    // ---------------------------------------------------------------------------
    // Route screen 
    
    RouteViewController* routeViewController = [[RouteViewController alloc] initWithNibName:@"RouteViewController" bundle:nil];
    UINavigationController* routeNavController = [[UINavigationController alloc] init]; //[[[NSBundle mainBundle] loadNibNamed:@"CustomNavigationBar" owner:self options:nil] 
    [routeNavController pushViewController:routeViewController animated:NO];
    
    DKTabBarItem* routeTabBarItem = [[DKTabBarItem alloc] init];
    [routeTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_route"] forState:UIControlStateNormal];
    [routeTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_route_tap"] forState:UIControlStateSelected];
    [routeTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_route_tap"] forState:UIControlStateHighlighted];
    
    routeTabBarItem.controller = routeNavController;
    [items addObject:routeTabBarItem];
    
    // ---------------------------------------------------------------------------
    // Settings screen 
    
    SettingViewController* settingsViewController = [[SettingViewController alloc] init];
    UINavigationController* settingsNavController = [[UINavigationController alloc] init]; //[[[NSBundle mainBundle] loadNibNamed:@"CustomNavigationBar" owner:self options:nil] 
    [settingsNavController pushViewController:settingsViewController animated:NO];
    
    DKTabBarItem* settingsTabBarItem = [[DKTabBarItem alloc] init];
    [settingsTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_setting"] forState:UIControlStateNormal];
    [settingsTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_setting_tap"] forState:UIControlStateSelected];
    [settingsTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_setting_tap"] forState:UIControlStateHighlighted];
    
    settingsTabBarItem.controller = settingsNavController;
    [items addObject:settingsTabBarItem];    
    
    tabBarController.tabBarItems = items;
    
    [tabBarController setSelectedItemWithIndex:0];
    
    [self.window setRootViewController:tabBarController];
    
    
    
    if ([Notification getNotify]) {
        [self startScanThread];
    } else {
        [self stopScanThread];
    }
}

- (void) setTabbarIndex:(int) _index 
{
    [tabBarController setSelectedItemWithIndex:_index];
}

- (void) setTabBarHidden:(BOOL) hidden animated:(BOOL) animated {
    if (animated) 
    {
        CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        
        UIView *tabBarContainer = self.tabBarController.tabBarContainer;
        if (hidden) 
        {
            [tabBarContainer setFrame:CGRectMake(
                                                 tabBarContainer.frame.origin.x, 
                                                 appFrame.size.height, 
                                                 tabBarContainer.frame.size.width, 
                                                 tabBarContainer.frame.size.height)];
        } 
        else 
        {
            [tabBarContainer setFrame:CGRectMake(
                                                 tabBarContainer.frame.origin.x, 
                                                 appFrame.size.height - tabBarContainer.frame.size.height, 
                                                 tabBarContainer.frame.size.width, 
                                                 tabBarContainer.frame.size.height)];
        }
        
        
        [UIView commitAnimations];
    }
    if(!animated)
    {
        
        CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
        
        
        UIView *tabBarContainer = self.tabBarController.tabBarContainer;
        if (hidden==1) 
        {
            [tabBarContainer setFrame:CGRectMake(
                                                 tabBarContainer.frame.origin.x, 
                                                 appFrame.size.height, 
                                                 tabBarContainer.frame.size.width, 
                                                 tabBarContainer.frame.size.height)];
        } 
        if(hidden==0)
        {
            [tabBarContainer setFrame:CGRectMake(
                                                 tabBarContainer.frame.origin.x, 
                                                 appFrame.size.height - tabBarContainer.frame.size.height, 
                                                 tabBarContainer.frame.size.width, 
                                                 tabBarContainer.frame.size.height)];
        }
        
    }
}

- (void) setNotifyTabbar:(BOOL) bEnable
{
    if (bEnable) {
        [categoryTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_explore_noti"] forState:UIControlStateNormal];
        [categoryTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_explore_noti_tap"] forState:UIControlStateSelected];
        [categoryTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_explore_noti_tap"] forState:UIControlStateHighlighted];
        
    } 
    else {
        [categoryTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_explore"] forState:UIControlStateNormal];
        [categoryTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_explore_tap"] forState:UIControlStateSelected];
        [categoryTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_explore_tap"] forState:UIControlStateHighlighted];
        
    }
}

- (void) setChatTabbar:(BOOL) bEnable
{
    if (bEnable) {
        [chatTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_avenue_noti"] forState:UIControlStateNormal];
        [chatTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_avenue_noti_tap"] forState:UIControlStateSelected];
        [chatTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_avenue_noti_tap"] forState:UIControlStateHighlighted];
        
    } 
    else {
        [chatTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_avenue"] forState:UIControlStateNormal];
        [chatTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_avenue_tap"] forState:UIControlStateSelected];
        [chatTabBarItem setBackgroundImage:[UIImage imageNamed:@"tab_bar_button_avenue_tap"] forState:UIControlStateHighlighted];
    }
}


#pragma mark ----------- Thread For Scan ---------------
- (BOOL) isScanThread
{
    if (_timerScan != nil) {
        return YES;
    }
    return NO;
}
- (void) stopScanThread
{
    if (_timerScan != nil) {
        [_timerScan invalidate];
        _timerScan = nil;
    }

    if (_timerScan1 != nil) {
        [_timerScan1 invalidate];
        _timerScan1 = nil;
    }

    return;
}

- (void) startScanThread 
{
//    if (![Notification getNotify]) {
        if (_timerScan != nil) {
            [_timerScan invalidate];
            _timerScan = nil;
        }
        if (_timerScan1 != nil) {
            [_timerScan1 invalidate];
            _timerScan1 = nil;
        }
//    }
    
//    if (_timerScan == nil) 
    {
        int scanMinute = [Notification getMinute];
        int noteHour   = [Notification getDuration];
        
        _timerScan = [NSTimer scheduledTimerWithTimeInterval:scanMinute * 60 target:self
                                                           selector:@selector(timerCategory) userInfo:nil repeats:YES];
        _timerScan1 = [NSTimer scheduledTimerWithTimeInterval:noteHour * 60 * 60 target:self
                                                    selector:@selector(timerNotification) userInfo:nil repeats:YES];

    }
    
}


- (BOOL) isSelectedAnySearch {
    for (NSMutableDictionary * itemCategory in [FilterSearch getCategory]) {
        BOOL isSelected = [[itemCategory objectForKey:@"selected"] boolValue];
        if (isSelected == YES) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) isSelectedAnyNoti {
    for (NSMutableDictionary * itemCategory in [Notification getCategory]) {
        BOOL isSelected = [[itemCategory objectForKey:@"selected"] boolValue];
        if (isSelected == YES) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) isEnable:(NSMutableDictionary*) _item
{
    int item_id = [[_item objectForKey:@"category_id"] intValue];
    
    for (NSMutableDictionary * pin in [Notification getCategory]) {
        int pin_id = [[pin objectForKey:@"category_id"] intValue];
        if (item_id == pin_id) {
            return [[pin objectForKey:@"selected"] boolValue];
        }
    }
    
    return NO;
}

- (void ) showMessage : (NSString*) _message 
{
//    NSLog(@"Message around User = %@", _message);
//    
//    
//    UILocalNotification *NotifyOne = [[UILocalNotification alloc] init];
//     if (NotifyOne) {
//         NotifyOne.alertBody = _message;
//         NotifyOne.alertAction = NSLocalizedString(@"OK", nil);
//         NotifyOne.fireDate = [NSDate date];
//         NotifyOne.soundName = nil;
//         NotifyOne.applicationIconBadgeNumber = 0;
//         
//         [[UIApplication sharedApplication] scheduleLocalNotification:NotifyOne];
//         NotifyOne = nil;
//        }    
    
    if (!m_bShowLocalMsg) {
        NSString * msg = _message;
        [[[UIAlertView alloc] initWithTitle:@"Notification Active!" message:msg delegate:self 
                          cancelButtonTitle:nil 
                          otherButtonTitles:@"View", @"Notification Settings", @"Turn Off", @"Ok",  nil] show];
        m_bShowLocalMsg = YES;
    }

}
- (void) timerNotification
{
    if (![Notification getNotify]) {
        return;
    }
    
    
    [Notification setNotify:NO];
    
    [self stopScanThread];
    [self setNotifyTabbar : NO];
}

- (void) timerCategory
{
    if (![Notification getNotify]) {
        return;
    }
    
    int _radius = [Notification getDistance];
//    NSMutableArray * arrayAll = [NSMutableArray array];
//    
//    for (NSMutableDictionary * item in [Share getInstance].arrayCategory) {
//        [arrayAll addObject:[item objectForKey:@"id"]];
//    }

    NSMutableArray * arrayAll = [Notification getCategory];
    
//    NSLog(@"notification category = %@", arrayAll);
    
    NSString *urlString = [Utils getPinForRealUser:arrayAll : _radius];
    [[UserRoundPin pool] start:urlString];
    
    while (![UserRoundPin pool].isGotAllPin) {
        [NSThread sleepForTimeInterval:0.01];
    }
    
    NSString * message = @"";
    
    NSMutableArray *allPins = [UserRoundPin pool].allPinListForUser;
/*    for (NSMutableDictionary *pinItem in allPins) 
    {
         message = [NSString stringWithFormat:@"%@%@\n", message, [pinItem objectForKey:@"title"]];
    }
    
    if (![message isEqualToString:@""]) {
        [self showMessage : message];
    }*/
    
    if (m_bShowLocalMsg == NO && [allPins count] > 0) {
        message = [NSString stringWithFormat:@"There are %d pins around", [allPins count]];
        [self showMessage:message];
    }
}


@end
