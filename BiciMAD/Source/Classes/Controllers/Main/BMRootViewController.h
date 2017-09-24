//
//  BMRootViewController.h
//  BiciMAD
//
//  Created by alexruperez on 7/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import RESideMenu;

@interface BMRootViewController : RESideMenu

@property (nonatomic, strong) NSNotificationCenter *notificationCenter;

@property (nonatomic, strong, readonly) UINavigationController *contentNavigationController;

@end

