//
//  UIButton+ButtonFromImage.m
//  BabyName
//
//  Created by RamotionMac on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIButton+ButtonFromImage.h"


@implementation UIButton (ButtonFromImage)

+ (UIButton*)buttonFromImage:(UIImage*)image {
    UIButton* result = [UIButton buttonWithType:UIButtonTypeCustom];
    if (iPhone) {
        result.frame = CGRectMake(0, 0, image.size.width/2, image.size.height/2);
    } else {
        result.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    [result setImage:image forState:UIControlStateNormal];
    return result;
}

+ (UIButton*)buttonWithImage:(UIImage*)image highlightedImage:(UIImage*)highlightedImage target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    
    if (iPhone) {
        button.frame= CGRectMake(0.0, 0.0, image.size.width/2, image.size.height/2);
    } else {
        button.frame= CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    }
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}


@end
