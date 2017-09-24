//
//  BMTwitterTimelineViewController.m
//  BiciMAD
//
//  Created by alexruperez on 23/2/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMTwitterTimelineViewController.h"

@import RESideMenu;
@import FXNotifications;
@import GearRefreshControl;

#import "BMNewsTimelineDataSource.h"
#import "BMTipsTimelineDataSource.h"
#import "BMGreenTipsTimelineDataSource.h"
#import "BMAnalyticsManager.h"

@interface BMTwitterTimelineViewController () <TWTRTimelineDelegate, TWTRTweetViewDelegate>

@property (nonatomic, strong) GearRefreshControl *gearRefreshControl;

@end

@implementation BMTwitterTimelineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.timelineDelegate = self;
    self.tweetViewDelegate = self;
    self.showTweetActions = YES;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController:)];
    self.navigationItem.leftBarButtonItem.accessibilityLabel = NSLocalizedString(@"Menu", @"Menu");
    
    self.view.backgroundColor = UIColor.bm_backgroundColor;
    self.tableView.tableFooterView = UIView.new;
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_logo"]];
    backgroundView.tintColor = UIColor.whiteColor;
    backgroundView.contentMode = UIViewContentModeCenter;
    self.tableView.backgroundView = backgroundView;

    self.refreshControl = self.gearRefreshControl;
    self.tableView.contentOffset = CGPointMake(0.f, -self.gearRefreshControl.frame.size.height);
    [self.gearRefreshControl beginRefreshing];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSString *contentType = (NSString *)NSNull.null;

    if ([self.dataSource isKindOfClass:BMNewsTimelineDataSource.class])
    {
        contentType = kBMNewsKey;
    }
    else if ([self.dataSource isKindOfClass:BMTipsTimelineDataSource.class])
    {
        contentType = kBMTipsKey;
    }
    else if ([self.dataSource isKindOfClass:BMGreenTipsTimelineDataSource.class])
    {
        contentType = kBMGreenTipsKey;
    }

    [BMAnalyticsManager logContentViewWithName:self.bm_className contentType:contentType contentId:nil customAttributes:@{FBSDKAppEventParameterNameContentType: contentType}];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (GearRefreshControl *)gearRefreshControl
{
    if (!_gearRefreshControl)
    {
        _gearRefreshControl = [[GearRefreshControl alloc] initWithFrame:self.view.bounds];
        _gearRefreshControl.tintColor = UIColor.whiteColor;
        _gearRefreshControl.gearTintColor = UIColor.bm_tintColor;
        [_gearRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    }

    return _gearRefreshControl;
}

- (void)handleError:(NSError *)error completion:(void (^)(void))completion
{
    if (!self.presentedViewController && [error.domain isEqualToString:NSURLErrorDomain] && error.code != NSURLErrorCancelled)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"Ok") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (completion)
            {
                completion();
            }
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        alertController.view.tintColor = UIColor.bm_tintColor;
    }
    else if (completion)
    {
        completion();
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.gearRefreshControl scrollViewDidScroll:scrollView];
}

#pragma mark - TWTRTimelineDelegate

- (void)timeline:(TWTRTimelineViewController *)timeline didFinishLoadingTweets:(NSArray *)tweets error:(NSError *)error
{
    if (self.gearRefreshControl.isRefreshControlAnimating)
    {
        [self.gearRefreshControl endRefreshing];
    }
    if (error)
    {
        [self handleError:error completion:nil];
    }
}

@end
