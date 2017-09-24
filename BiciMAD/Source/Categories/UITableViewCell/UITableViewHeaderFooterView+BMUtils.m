//
//  UITableViewHeaderFooterView+BMUtils.m
//  BiciMAD
//
//  Created by alexruperez on 8/9/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "UITableViewHeaderFooterView+BMUtils.h"

@import libextobjc;

@safecategory(UITableViewHeaderFooterView, BMUtils)

+ (void)bm_registerNibOnTableView:(UITableView *)tableView
{
    [tableView registerNib:self.bm_nib forHeaderFooterViewReuseIdentifier:self.bm_className];
}

+ (void)bm_registerClassOnTableView:(UITableView *)tableView
{
    [tableView registerClass:self forHeaderFooterViewReuseIdentifier:self.bm_className];
}

+ (instancetype)bm_dequeueReusableCellFromTableView:(UITableView *)tableView
{
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:self.bm_className];
}

@end
