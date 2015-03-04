//
//  UIButton+ButtonFromImage.h
//  BabyName
//
//  Created by RamotionMac on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIButton (ButtonFromImage)

+ (UIButton*)buttonFromImage:(UIImage*)image;
+ (UIButton*)buttonWithImage:(UIImage*)image highlightedImage:(UIImage*)highlightedImage target:(id)target action:(SEL)action;

@end
