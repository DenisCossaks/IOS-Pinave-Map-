//
//  UIBarButtonItem+highlighted.m
//  Pocket Pics
//
//  Created by RamotionMac on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIBarButtonItem+highlighted.h"

@implementation UIBarButtonItem(highlighted)

+ (UIBarButtonItem*)barItemWithImage:(UIImage*)image highlightedImage:(UIImage*)highlightedImage target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    
    if (iPhone) {
        button.frame= CGRectMake(0.0, 0.0, image.size.width/2, image.size.height/2);
    } else {
        button.frame= CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    }
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIView* buttonView=[[UIView alloc] initWithFrame:button.frame];
    [buttonView addSubview:button];
    
    UIBarButtonItem* result = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    
    return result;
}

@end