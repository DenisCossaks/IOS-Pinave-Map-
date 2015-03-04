//
//  CustomNavigationController .m
//  BabyName
//
//  Created by RamotionMac on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomNavigationBar.h"


@implementation CustomNavigationBar

@synthesize skipResizing;

- (void)drawRect:(CGRect)rect {
	UIImage *img = [UIImage imageNamed: @"nav_bar_bg"];
	[img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    if (! skipResizing) {
        self.frame.size.height = kNavigationBarHeight;
    }
}

- (void)layoutSubviews {
    UINavigationItem* navigationItem = self.topItem;
    
    UIView* titleView = navigationItem.titleView;
    titleView.frameX = (self.frameWidth - titleView.frameWidth) / 2;
    titleView.frameY = (kNavigationBarHeight - titleView.frameHeight) / 2;
    
    UIView* leftView = navigationItem.leftBarButtonItem.customView;
    leftView.frameY = (kNavigationBarHeight - leftView.frameHeight) / 2;
    
    UIView* rightView = navigationItem.rightBarButtonItem.customView;
    rightView.frameY = (kNavigationBarHeight - rightView.frameHeight) / 2;
}

@end
