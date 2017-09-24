//
//  UIView+BMUtils.m
//  BiciMAD
//
//  Created by alexruperez on 14/8/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "UIView+BMUtils.h"

@import libextobjc;

@safecategory(UIView, BMUtils)

+ (NSBundle *)bm_mainBundle
{
    return NSBundle.mainBundle;
}

+ (UINib *)bm_nib
{
    return [UINib nibWithNibName:self.bm_className bundle:self.bm_mainBundle];
}

+ (instancetype)bm_loadFromNib
{
    return [self.bm_mainBundle loadNibNamed:self.bm_className owner:self options:nil].firstObject;
}

- (instancetype)bm_loadFromNib
{
    return self.class.bm_loadFromNib;
}

- (UIImage *)bm_snapshot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.f);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
