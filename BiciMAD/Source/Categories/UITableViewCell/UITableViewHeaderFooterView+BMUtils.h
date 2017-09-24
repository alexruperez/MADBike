//
//  UITableViewHeaderFooterView+BMUtils.h
//  BiciMAD
//
//  Created by alexruperez on 8/9/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import UIKit;

@interface UITableViewHeaderFooterView (BMUtils)

+ (void)bm_registerNibOnTableView:(UITableView *)tableView;

+ (void)bm_registerClassOnTableView:(UITableView *)tableView;

+ (instancetype)bm_dequeueReusableCellFromTableView:(UITableView *)tableView;

@end
