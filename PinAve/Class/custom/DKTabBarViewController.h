//
//  DKTabBarViewController.h
//  iQuickChecks
//
//  Created by macuser on 08.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DKTabBarViewController : UIViewController {

	NSMutableArray *tabBarItems;
	UIView         *tabBarContainer;
	UIView         *tabBarItemsContainer;
	UIImageView    *tabBarBGImageView;
	
	UIViewController *selectedViewController;
}

@property (nonatomic, retain)   NSMutableArray   *tabBarItems;
@property (nonatomic, readonly) UIView           *tabBarContainer;
@property (nonatomic, retain)   UIImageView      *tabBarBGImageView;
@property (nonatomic, readonly) UIViewController *selectedViewController;

- (void) setSelectedItemWithIndex:(NSInteger) index;

@end
