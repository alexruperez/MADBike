//
//  UITableViewCell+BMUtils.m
//  BiciMAD
//
//  Created by alexruperez on 8/9/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "UITableViewCell+BMUtils.h"

@import libextobjc;

@safecategory(UITableViewCell, BMUtils)

+ (void)bm_registerNibOnTableView:(UITableView *)tableView
{
    [tableView registerNib:self.bm_nib forCellReuseIdentifier:self.bm_className];
}

+ (void)bm_registerClassOnTableView:(UITableView *)tableView
{
    [tableView registerClass:self forCellReuseIdentifier:self.bm_className];
}

+ (instancetype)bm_dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath fromTableView:(UITableView *)tableView
{
    return [tableView dequeueReusableCellWithIdentifier:self.bm_className forIndexPath:indexPath];
}

@end
