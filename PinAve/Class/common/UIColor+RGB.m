//
//  UIColor+RGB.m
//  BabyName
//
//  Created by RamotionMac on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIColor+RGB.h"

@implementation UIColor(RGB)

// helper function
+(CGColorRef)createRGBValue:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[4] = {red, green, blue, alpha};
    CGColorRef color = CGColorCreate(colorspace, components);
    CGColorSpaceRelease(colorspace);
    return color;
}

// create and return the new UIColor
+(UIColor *)colorFromRGBIntegers:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    CGFloat redF    = red/255;
    CGFloat greenF    = green/255;
    CGFloat blueF    = blue/255;
    CGFloat alphaF    = alpha/1.0;
    
    CGColorRef    color = [UIColor createRGBValue:redF green:greenF blue:blueF alpha:alphaF];
    
    return [UIColor colorWithCGColor:color];
}

@end