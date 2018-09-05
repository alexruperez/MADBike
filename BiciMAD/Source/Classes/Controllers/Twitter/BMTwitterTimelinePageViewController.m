//
//  BMTwitterTimelinePageViewController.m
//  BiciMAD
//
//  Created by alexruperez on 14/8/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMTwitterTimelinePageViewController.h"

@import RESideMenu;
@import FXNotifications;
@import DGRunkeeperSwitch;

#import "BMViewControllersAssembly.h"
#import "BMAnalyticsManager.h"
#import "BMDeepLinkingManager.h"
#import "BMTwitterTimelineViewController.h"
#import "MADBike-Swift.h"

@interface BMTwitterTimelinePageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, copy) NSArray *dataSources;
@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, strong) BMViewControllersAssembly *viewControllersAssembly;

@property (nonatomic, strong) NSMutableArray *cachedViewControllers;
@property (nonatomic, strong) DGRunkeeperSwitch *runkeeperSwitch;

@end

@implementation BMTwitterTimelinePageViewController

- (instancetype)initWithDataSources:(NSArray *)dataSources titles:(NSArray *)titles viewControllersAssembly:(BMViewControllersAssembly *)viewControllersAssembly
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    if (self)
    {
        self.dataSource = self;
        self.delegate = self;
        _viewControllersAssembly = viewControllersAssembly;
        if (dataSources.count && dataSources.count == titles.count)
        {
            _dataSources = dataSources;
            _titles = titles;
            _cachedViewControllers = NSMutableArray.new;
            [self setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController:)];
    self.navigationItem.leftBarButtonItem.accessibilityLabel = NSLocalizedString(@"Menu", @"Menu");
    
    self.runkeeperSwitch = [[DGRunkeeperSwitch alloc] initWithTitles:self.titles];
    self.runkeeperSwitch.backgroundColor = UIColor.bm_backgroundColor;
    self.runkeeperSwitch.selectedBackgroundColor = UIColor.whiteColor;
    self.runkeeperSwitch.titleColor = UIColor.whiteColor;
    self.runkeeperSwitch.selectedTitleColor = UIColor.bm_backgroundColor;
    self.runkeeperSwitch.frame = CGRectMake(50.f, 20.f, self.view.bounds.size.width - 90.f, 30.f);
    self.runkeeperSwitch.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.runkeeperSwitch.layer.borderWidth = 2.3f;
    self.runkeeperSwitch.layer.borderColor = UIColor.whiteColor.CGColor;
    self.runkeeperSwitch.animationDuration = 0.4f;
    [self.runkeeperSwitch addTarget:self action:@selector(runkeeperSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.runkeeperSwitch;
    
    self.view.backgroundColor = UIColor.bm_backgroundColor;

    [self setUserActivityWithActivityType:kBMMADBikeUserActivityNews title:NSLocalizedString(@"News", @"News") description:nil];

    @weakify(self)
    [self.notificationCenter addObserver:self forName:kBMMADBikeDeepLinkNewsNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        if ([note.object isKindOfClass:NSString.class])
        {
            [self.tweetPresenter presentTweetWithId:note.object view:self.view completion:nil];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [BMAnalyticsManager logContentViewWithName:self.bm_className contentType:NSStringFromClass(BMTwitterTimelineViewController.class) contentId:nil customAttributes:@{FBSDKAppEventParameterNameContentType: NSStringFromClass(BMTwitterTimelineViewController.class)}];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BMTwitterTimelineViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (self.dataSources.count == 0 || index >= self.dataSources.count)
    {
        return nil;
    }
    
    if (self.cachedViewControllers.count == 0 || index >= self.cachedViewControllers.count)
    {
        BMTwitterTimelineViewController *twitterTimelineViewController = nil;
        for (NSUInteger i = self.cachedViewControllers.count; i <= index; i++) {
            twitterTimelineViewController = [self.viewControllersAssembly twitterTimelineViewControllerWithDataSource:self.dataSources[i]];
            [self.cachedViewControllers addObject:twitterTimelineViewController];
        }
        return twitterTimelineViewController;
    }
    
    return self.cachedViewControllers[index];
}

- (NSUInteger)indexOfViewController:(BMTwitterTimelineViewController *)viewController
{
    return [self.dataSources indexOfObject:viewController.dataSource];
}

- (void)runkeeperSwitchValueChanged:(DGRunkeeperSwitch *)runkeeperSwitch
{
    NSUInteger currentIndex = [self indexOfViewController:self.viewControllers.firstObject];
    NSUInteger targetIndex = (NSUInteger)runkeeperSwitch.selectedIndex;
    if (currentIndex != targetIndex)
    {
        BMTwitterTimelineViewController *twitterTimelineViewController = [self viewControllerAtIndex:targetIndex];
        if (twitterTimelineViewController)
        {
            UIPageViewControllerNavigationDirection navigationDirection = targetIndex > currentIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
            @weakify(self)
            [self setViewControllers:@[twitterTimelineViewController] direction:navigationDirection animated:YES completion:^(BOOL finished) {
                if (finished)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        @strongify(self)
                        [self setViewControllers:@[twitterTimelineViewController] direction:navigationDirection animated:NO completion:nil];
                    });
                }
            }];
        }
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(BMTwitterTimelineViewController *)viewController];
    if (index == 0 || index == NSNotFound)
    {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(BMTwitterTimelineViewController *)viewController];
    if (index == NSNotFound)
    {
        return nil;
    }
    index++;
    if (index == self.dataSources.count)
    {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    NSInteger currentIndex = (NSInteger)[self indexOfViewController:self.viewControllers.firstObject];
    NSInteger targetIndex = self.runkeeperSwitch.selectedIndex;
    if (currentIndex != NSNotFound && currentIndex != targetIndex)
    {
        [self.runkeeperSwitch setSelectedIndex:currentIndex animated:YES];
    }
}

@end
