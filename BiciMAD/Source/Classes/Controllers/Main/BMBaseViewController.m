//
//  BMBaseViewController.m
//  BiciMAD
//
//  Created by alexruperez on 8/12/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMBaseViewController.h"

@implementation BMBaseViewController

- (NSBundle *)bundle
{
    if (!_bundle)
    {
        _bundle = NSBundle.mainBundle;
    }

    return _bundle;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)branchViewVisible:(NSString *)actionName withID:(NSString *)branchViewID
{
    
}

- (void)branchViewAccepted:(NSString *)actionName withID:(NSString *)branchViewID
{
    
}

- (void)branchViewCancelled:(NSString *)actionName withID:(NSString *)branchViewID
{
    
}

- (void)branchViewErrorCode:(NSInteger)errorCode message:(NSString *)errorMsg actionName:(NSString *)actionName withID:(NSString *)branchViewID
{
    DDLogError(@"Branch error: %@", errorMsg);
}

@end
