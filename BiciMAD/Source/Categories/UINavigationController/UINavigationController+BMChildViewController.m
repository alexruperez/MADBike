//
//  UINavigationController+BMChildViewController.m
//  BiciMAD
//
//  Created by alexruperez on 8/12/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "UINavigationController+BMChildViewController.h"

@implementation UINavigationController (BMChildViewController)

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.topViewController;
}

@end
