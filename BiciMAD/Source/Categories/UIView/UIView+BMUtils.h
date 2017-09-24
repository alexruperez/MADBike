//
//  UIView+BMUtils.h
//  BiciMAD
//
//  Created by alexruperez on 14/8/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import UIKit;

@interface UIView (BMUtils)

+ (UINib *)bm_nib;

+ (instancetype)bm_loadFromNib;

- (instancetype)bm_loadFromNib;

- (UIImage *)bm_snapshot;

@end
