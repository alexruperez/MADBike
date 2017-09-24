//
//  MFMailComposeViewController+BMChildViewController.m
//  BiciMAD
//
//  Created by alexruperez on 8/12/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "MFMailComposeViewController+BMChildViewController.h"

@implementation MFMailComposeViewController (BMChildViewController)

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return nil;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}

@end
