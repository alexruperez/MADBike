//
//  BMLeftMenuViewController.m
//  BiciMAD
//
//  Created by alexruperez on 4/11/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMLeftMenuViewController.h"

@import FXNotifications;

#import "BMViewControllersAssembly.h"
#import "BMApplicationAssembly.h"
#import "BMServicesAssembly.h"
#import "BMRootViewController.h"
#import "BMTwitterTimelinePageViewController.h"
#import "BMStationsViewController.h"
#import "BMAnalyticsManager.h"
#import "BMDeepLinkingManager.h"
#import "BMPrePermissionManager.h"
#import "BMSettingsViewController.h"
#import "BMTwitterTimelineViewController.h"
#import "BMTwitterReportViewController.h"
#import "BMAirQualityViewController.h"
#import "BMShareViewController.h"
#import "BMHTTPClientConstants.h"

static NSString * const kBMLeftMenuCellIdentifier = @"BMLeftMenuCell";

@interface BMLeftMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) BMStationsViewController *stationsViewController;
@property (nonatomic, strong) BMSettingsViewController *settingsViewController;
@property (nonatomic, strong) BMTwitterTimelinePageViewController *twitterTimelinePageViewController;
@property (nonatomic, strong) BMTwitterReportViewController *twitterReportViewController;
@property (nonatomic, strong) BMAirQualityViewController *airQualityViewController;
@property (nonatomic, strong) BMShareViewController *shareViewController;
@property (nonatomic, strong) UIApplication *application;

@end

@implementation BMLeftMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = UIView.new;
    self.tableView.scrollEnabled = NO;
    
    @weakify(self)
    [self.notificationCenter addObserver:self forName:kBMMADBikeDeepLinkStationNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self showMapAnimated:NO];
    }];
    [self.notificationCenter addObserver:self forName:kBMMADBikeDeepLinkWeatherNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self showMapAnimated:NO];
    }];
    [self.notificationCenter addObserver:self forName:kBMMADBikeDeepLinkAirQualityNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self showAirQualityAnimated:NO];
    }];
    [self.notificationCenter addObserver:self forName:kBMMADBikeDeepLinkNewsNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self.twitterTimelinePageViewController loadViewIfNeeded];
        [self showTwitterTimelineAnimated:NO];
    }];
    [self.notificationCenter addObserver:self forName:kBMMADBikeDeepLinkReportNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self showTwitterReportAnimated:NO];
    }];
    [self.notificationCenter addObserver:self forName:kBMMADBikeDeepLinkSettingsNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self showSettingsAnimated:NO];
    }];
    [self.notificationCenter addObserver:self forName:kBMMADBikeDeepLinkShareNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self showShareAnimated:NO];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [BMAnalyticsManager logContentViewWithName:self.bm_className contentType:nil contentId:nil customAttributes:nil];
}

- (BMStationsViewController *)stationsViewController
{
    if (!_stationsViewController)
    {
        _stationsViewController = self.viewControllersAssembly.stationsViewController;
    }
    
    return _stationsViewController;
}

- (BMSettingsViewController *)settingsViewController
{
    if (!_settingsViewController)
    {
        _settingsViewController = self.viewControllersAssembly.settingsViewController;
    }
    
    return _settingsViewController;
}

- (BMTwitterTimelinePageViewController *)twitterTimelinePageViewController
{
    if (!_twitterTimelinePageViewController)
    {
        _twitterTimelinePageViewController = [self.viewControllersAssembly twitterTimelinePageViewControllerWithDataSources:@[self.servicesAssembly.newsTimelineDataSource, self.servicesAssembly.tipsTimelineDataSource, self.servicesAssembly.greenTipsTimelineDataSource] titles:@[NSLocalizedString(@"News", @"News"), NSLocalizedString(@"Tips", @"Tips"), NSLocalizedString(@"Green Tips", @"Green Tips")]];
    }
    
    return _twitterTimelinePageViewController;
}

- (BMTwitterReportViewController *)twitterReportViewController
{
    if (!_twitterReportViewController)
    {
        _twitterReportViewController = self.viewControllersAssembly.twitterReportViewController;
        _twitterReportViewController.delegate = _twitterReportViewController;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            _twitterReportViewController.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
    }
    
    return _twitterReportViewController;
}

- (BMAirQualityViewController *)airQualityViewController
{
    if (!_airQualityViewController)
    {
        _airQualityViewController = self.viewControllersAssembly.airQualityViewController;
    }
    
    return _airQualityViewController;
}

- (BMShareViewController *)shareViewController
{
    if (!_shareViewController)
    {
        _shareViewController = [self.viewControllersAssembly shareViewController];
    }
    
    return _shareViewController;
}

- (UIApplication *)application
{
    if (!_application)
    {
        _application = self.applicationAssembly.application;
    }

    return _application;
}

- (void)showMapAnimated:(BOOL)animated
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.stationsViewController];
    [self.sideMenuViewController setContentViewController:navigationController animated:animated];
    [self.sideMenuViewController hideMenuViewController];
}

- (void)showSettingsAnimated:(BOOL)animated
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.settingsViewController];
    navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.sideMenuViewController setContentViewController:navigationController animated:animated];
    [self.sideMenuViewController hideMenuViewController];
}

- (void)showTwitterTimelineAnimated:(BOOL)animated
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.twitterTimelinePageViewController];
    navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.sideMenuViewController setContentViewController:navigationController animated:animated];
    [self.sideMenuViewController hideMenuViewController];
}

- (void)showTwitterReportAnimated:(BOOL)animated
{
    [self.sideMenuViewController hideMenuViewController];
    
    @weakify(self)
    [self.prePermissionManager camera:^(BOOL cameraSuccess) {
        if (cameraSuccess)
        {
            @strongify(self)
            [self.prePermissionManager location:^(BOOL locationSuccess) {
                if (locationSuccess)
                {
                    @strongify(self)
                    [self.prePermissionManager twitterWithViewController:self.sideMenuViewController completion:^(BOOL twitterSuccess) {
                        if (twitterSuccess)
                        {
                            @strongify(self)
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                @strongify(self)
                                self.twitterReportViewController = nil;
                                [self.sideMenuViewController showViewController:self.twitterReportViewController sender:self];
                            });
                        }
                    }];
                }
            }];
        }
    }];
}

- (void)showAirQualityAnimated:(BOOL)animated
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.airQualityViewController];
    navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.sideMenuViewController setContentViewController:navigationController animated:animated];
    [self.sideMenuViewController hideMenuViewController];
}

- (void)showShareAnimated:(BOOL)animated
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.shareViewController];
    navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.sideMenuViewController setContentViewController:navigationController animated:animated];
    [self.sideMenuViewController hideMenuViewController];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBMLeftMenuCellIdentifier forIndexPath:indexPath];
    
    cell.tintColor = UIColor.whiteColor;
    cell.textLabel.textColor = UIColor.whiteColor;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:18.f];
    cell.textLabel.shadowColor = [UIColor.blackColor colorWithAlphaComponent:0.5f];
    cell.textLabel.shadowOffset = CGSizeMake(1.f, 1.f);
    cell.imageView.layer.shadowColor = UIColor.blackColor.CGColor;
    cell.imageView.layer.shadowOffset = CGSizeMake(1.f, 1.f);
    cell.imageView.layer.shadowOpacity = 0.5f;
    cell.imageView.layer.shadowRadius = 0.f;
    cell.imageView.clipsToBounds = NO;

    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"Stations", @"Stations");
            cell.imageView.image = [UIImage imageNamed:@"ic_map"];
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"Air Quality", @"Air Quality");
            cell.imageView.image = [UIImage imageNamed:@"ic_wb_cloudy"];
            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"News", @"News");
            cell.imageView.image = [UIImage imageNamed:@"ic_new_releases"];
            break;
        case 3:
            cell.textLabel.text = NSLocalizedString(@"Report", @"Report");
            cell.imageView.image = [UIImage imageNamed:@"ic_linked_camera"];
            break;
        case 4:
            cell.textLabel.text = NSLocalizedString(@"Settings", @"Settings");
            cell.imageView.image = [UIImage imageNamed:@"ic_settings"];
            break;
        case 5:
            cell.textLabel.text = NSLocalizedString(@"MADPoints", @"MADPoints");
            cell.imageView.image = [UIImage imageNamed:@"ic_share"];
            break;
        default:
            cell.textLabel.text = @"";
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = UIColor.clearColor;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    cell.layoutMargins = UIEdgeInsetsZero;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.row)
    {
        case 0:
            [self showMapAnimated:YES];
            break;
        case 1:
            [self showAirQualityAnimated:YES];
            break;
        case 2:
            [self showTwitterTimelineAnimated:YES];
            break;
        case 3:
            [self showTwitterReportAnimated:YES];
            break;
        case 4:
            [self showSettingsAnimated:YES];
            break;
        case 5:
            [self showShareAnimated:YES];
            break;
        default:
            break;
    }
}

@end
