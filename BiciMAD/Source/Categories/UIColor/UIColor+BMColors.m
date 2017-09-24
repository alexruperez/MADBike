//
//  UIColor+BMColors.m
//  BiciMAD
//
//  Created by alexruperez on 17/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "UIColor+BMColors.h"

@import libextobjc;

@safecategory(UIColor, BMColors)

+ (UIColor *)bm_colorWithHex:(UInt32)hex alpha:(CGFloat)alpha
{
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:alpha];
}

+ (UIColor *)bm_colorWithHex:(UInt32)hex
{
    return [self bm_colorWithHex:hex alpha:1.f];
}

+ (UIColor *)bm_mainColor
{
    return [self bm_colorWithHex:0x009688];
}

+ (UIColor *)bm_backgroundColor
{
    return self.bm_mainColor;
}

+ (UIColor *)bm_tintColor
{
    return self.bm_mainColor;
}

+ (UIColor *)bm_barTintColor
{
    return self.bm_mainColor;
}

+ (UIColor *)bm_green
{
    return [self bm_colorWithHex:0x81C784];
}

+ (UIColor *)bm_red
{
    return [self bm_colorWithHex:0xFF5252];
}

+ (UIColor *)bm_yellow
{
    return [self bm_colorWithHex:0xFFEB3B];
}

+ (UIColor *)bm_gray
{
    return [self bm_colorWithHex:0xF5F5F5];
}

+ (UIColor *)bm_blue
{
    return [self bm_colorWithHex:0x2196F3];
}

@end
