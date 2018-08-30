//
//  BMRootViewController.m
//  BiciMAD
//
//  Created by alexruperez on 7/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMRootViewController.h"

@import TwitterKit;
@import FXNotifications;
@import SVProgressHUD;

#import "BMDeepLinkingManager.h"
#import "BMAnalyticsManager.h"

@interface BMRootViewController () <RESideMenuDelegate>

@end

@implementation BMRootViewController

- (UINavigationController *)contentNavigationController
{
    if ([self.contentViewController isKindOfClass:UINavigationController.class])
    {
        return (UINavigationController *)self.contentViewController;
    }
    
    return nil;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (self.contentViewStoryboardID)
    {
        self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.contentViewStoryboardID];
    }
    if (self.leftMenuViewStoryboardID)
    {
        self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.leftMenuViewStoryboardID];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    
    [UIBarButtonItem.appearance setBackButtonTitlePositionAdjustment:UIOffsetMake(0.f, -60.f) forBarMetrics:UIBarMetricsDefault];
    
    UINavigationBar.appearance.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.whiteColor};
    UINavigationBar.appearance.translucent = NO;
    UINavigationBar.appearance.tintColor = UIColor.whiteColor;
    UINavigationBar.appearance.barTintColor = UIColor.bm_barTintColor;
    
    UIToolbar.appearance.translucent = NO;
    
    UISearchBar.appearance.translucent = NO;
    UISearchBar.appearance.tintColor = UIColor.whiteColor;
    UISearchBar.appearance.barTintColor = UIColor.bm_barTintColor;
    
    UITextField.appearance.tintColor = UIColor.bm_tintColor;
    
    UISwitch.appearance.onTintColor = UIColor.bm_tintColor;
    
    SVProgressHUD.appearance.defaultStyle = SVProgressHUDStyleCustom;
    SVProgressHUD.appearance.foregroundColor = UIColor.whiteColor;
    SVProgressHUD.appearance.backgroundColor = UIColor.bm_backgroundColor;
    
    TWTRTweetView.appearance.linkTextColor = UIColor.bm_tintColor;
    
    self.view.backgroundColor = UIColor.bm_backgroundColor;
    self.backgroundImage = [UIImage imageNamed:@"ic_background"];
    
    @weakify(self)
    [self.notificationCenter addObserver:self forName:kBMMADBikeDeepLinkNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        if (self.presentedViewController)
        {
            [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        }
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return gestureRecognizer.view == self.view;
}

@end
