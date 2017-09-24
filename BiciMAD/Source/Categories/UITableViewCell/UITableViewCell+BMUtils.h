//
//  UITableViewCell+BMUtils.h
//  BiciMAD
//
//  Created by alexruperez on 8/9/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import UIKit;

@interface UITableViewCell (BMUtils)

+ (void)bm_registerNibOnTableView:(UITableView *)tableView;

+ (void)bm_registerClassOnTableView:(UITableView *)tableView;

+ (instancetype)bm_dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath fromTableView:(UITableView *)tableView;

@end
