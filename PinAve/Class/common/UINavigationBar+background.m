//
//  UINavigationBar+background.m
//  BabyName
//
//  Created by RamotionMac on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UINavigationBar+background.h"


@implementation UINavigationBar (background)

- (void)drawRect:(CGRect)rect {
	UIImage *img = [UIImage imageNamed: @"nav_bar_bg"];
	[img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    if (self.tag == kResizableNavigationBarTag) {
        
//        self.frameHeight = kNavigationBarHeight;
    }
}

@end