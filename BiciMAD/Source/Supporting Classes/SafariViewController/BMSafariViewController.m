//
//  BMSafariViewController.m
//  BiciMAD
//
//  Created by alexruperez on 6/1/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMSafariViewController.h"

@interface BMSafariViewController () <SFSafariViewControllerDelegate>

@property (nonatomic, assign) BOOL isSwipingBack;
@property (nonatomic, strong) NSUserActivity *userActivity;
@property (nonatomic, copy) BMLoadCompletionHandler loadCompletionHandler;
@property (nonatomic, copy) BMFinishCompletionHandler finishCompletionHandler;

@end

@implementation BMSafariViewController

- (instancetype)initWithURLString:(NSString *)URLString onLoad:(BMLoadCompletionHandler)load onFinish:(BMFinishCompletionHandler)finish
{
    NSURL *url = [NSURL URLWithString:URLString];

    if (url)
    {
        self = [self initWithURL:url];
        
        if (self)
        {
            self.loadCompletionHandler = load;
            self.finishCompletionHandler = finish;
        }
    }

    return self;
}

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super initWithURL:URL];
    
    if (self)
    {
        self.delegate = self;

        self.userActivity = [[NSUserActivity alloc] initWithActivityType:NSUserActivityTypeBrowsingWeb];
        self.userActivity.title = self.title;
        self.userActivity.webpageURL = URL;
        self.userActivity.eligibleForHandoff = YES;
        
        if ([self respondsToSelector:@selector(preferredControlTintColor)])
        {
            self.preferredControlTintColor = UIColor.bm_tintColor;
        }
    }
    
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.isSwipingBack)
    {
        return [self.presentingViewController preferredStatusBarStyle];
    }
    
    return [super preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
    if (self.isSwipingBack)
    {
        return [self.presentingViewController prefersStatusBarHidden];
    }
    
    return [super prefersStatusBarHidden];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.isSwipingBack = YES;

    [self.transitionCoordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.isSwipingBack = NO;
    }];
    
    [super viewWillDisappear:animated];
}

- (void)setIsSwipingBack:(BOOL)isSwipingBack
{
    _isSwipingBack = isSwipingBack;
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - SFSafariViewControllerDelegate

- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully
{
    [self.userActivity becomeCurrent];
    if (self.loadCompletionHandler)
    {
        self.loadCompletionHandler(didLoadSuccessfully);
    }
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    [self.userActivity resignCurrent];
    if (self.finishCompletionHandler)
    {
        self.finishCompletionHandler();
    }
}

@end
