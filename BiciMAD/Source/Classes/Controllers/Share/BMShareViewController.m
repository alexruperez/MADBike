//
//  BMShareViewController.m
//  BiciMAD
//
//  Created by alexruperez on 14/3/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMShareViewController.h"

@import RESideMenu;
@import AFNetworking;
@import FXNotifications;

#import "BMViewControllersAssembly.h"
#import "BMManagersAssembly.h"
#import "BMPrePermissionManager.h"
#import "BMAnalyticsManager.h"
#import "BMDeepLinkingManager.h"
#import "BMPointsService.h"
#import "BMPointsStorage.h"
#import "BMAnnotationsDetailViewController.h"
#import "MADBike-Swift.h"

@interface BMShareViewController ()

@property (nonatomic, weak) IBOutlet UILabel *creditsLabel;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, weak) IBOutlet UIButton *promotionsButton;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation BMShareViewController

@synthesize deepLinkingCompletionDelegate;

- (instancetype)init
{
    self = [super initWithNibName:self.nibName bundle:self.bundle];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MADPoints", @"MADPoints");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController:)];
    self.navigationItem.leftBarButtonItem.accessibilityLabel = NSLocalizedString(@"Menu", @"Menu");
    
    self.view.backgroundColor = UIColor.bm_backgroundColor;
    
    self.creditsLabel.textColor = UIColor.whiteColor;
    self.creditsLabel.layer.borderColor = UIColor.whiteColor.CGColor;
    self.creditsLabel.layer.borderWidth = 3.f;
    self.creditsLabel.layer.cornerRadius = 50.f;
    
    [self.shareButton setTitle:NSLocalizedString(@"Share", @"Share") forState:UIControlStateNormal];
    [self.shareButton setTitleColor:UIColor.bm_tintColor forState:UIControlStateNormal];
    self.shareButton.backgroundColor = UIColor.whiteColor;
    self.shareButton.layer.cornerRadius = 15.f;
    
    [self.promotionsButton setTitle:NSLocalizedString(@"Rewards", @"Rewards") forState:UIControlStateNormal];
    [self.promotionsButton setTitleColor:UIColor.bm_tintColor forState:UIControlStateNormal];
    self.promotionsButton.backgroundColor = UIColor.whiteColor;
    self.promotionsButton.layer.cornerRadius = 15.f;
    self.promotionsButton.alpha = 0.f;
    
    self.descriptionLabel.textColor = UIColor.whiteColor;
    self.descriptionLabel.text = NSLocalizedString(@"Share MADBike with friends and earn MADPoints that you can redeem for sweet prizes!", @"Share MADBike with friends and earn MADPoints that you can redeem for sweet prizes!");

    [self setUserActivityWithActivityType:kBMMADBikeUserActivityShare title:NSLocalizedString(@"Share", @"Share") description:NSLocalizedString(@"Share MADBike with friends and earn MADPoints that you can redeem for sweet prizes!", @"Share MADBike with friends and earn MADPoints that you can redeem for sweet prizes!")];
    
    @weakify(self)
    [self.managersAssembly.notificationCenter addObserver:self forName:AFNetworkingReachabilityDidChangeNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self reachabilityDidChange:note];
    }];
    [self.managersAssembly.notificationCenter addObserver:self forName:kBMMADBikeDeepLinkShareNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self configureControlWithData:note.object];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view becomeFirstResponder];
    
    [super viewWillAppear:animated];
    
    [self loadRewards:self];
    
    if (![self checkPromotionsAnimated:NO])
    {
        @weakify(self)
        [self.pointsService allPartnersWithSuccessBlock:^(NSArray *partners) {
            @strongify(self)
            [self checkPromotionsAnimated:YES];
        } failureBlock:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [BMAnalyticsManager logContentViewWithName:self.bm_className contentType:nil contentId:nil customAttributes:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view resignFirstResponder];
    
    [super viewWillDisappear:animated];
}

- (void)reachabilityDidChange:(id)sender
{
    [self loadRewards:sender];
}

- (void)loadRewards:(id)sender
{
    @weakify(self)
    [BMAnalyticsManager loadRewardsWithCompletion:^(BOOL changed, NSInteger credits, NSError *error) {
        @strongify(self)
        if (!error)
        {
            [self.activityIndicatorView stopAnimating];
            self.creditsLabel.text = [NSString stringWithFormat:@"%zd", credits];
        }
        else
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"Ok") style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
            alertController.view.tintColor = UIColor.bm_tintColor;
        }
    }];
}

- (BOOL)checkPromotionsAnimated:(BOOL)animated
{
    self.promotionsButton.alpha = 0.f;
    
    if (self.pointsStorage.promotions.count > 0)
    {
        if (animated)
        {
            @weakify(self)
            [UIView animateWithDuration:(NSTimeInterval)0.3f animations:^{
                @strongify(self)
                self.promotionsButton.alpha = 1.f;
            }];
        }
        else
        {
            self.promotionsButton.alpha = 1.f;
        }
        
        return YES;
    }
    
    return NO;
}

- (IBAction)showPromotions:(id)sender
{
    BMAnnotationsDetailViewController *annotationsDetailViewController = [self.viewControllersAssembly annotationsDetailViewControllerWithAnnotations:self.pointsStorage.promotions titleString:NSLocalizedString(@"Rewards", @"Rewards")];
    [annotationsDetailViewController view];
    annotationsDetailViewController.shouldHighlightContent = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:annotationsDetailViewController];
    navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    if (self.presentedViewController)
    {
        @weakify(self)
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            @strongify(self)
            [self presentViewController:navigationController animated:YES completion:nil];
        }];
    }
    else
    {
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

- (IBAction)shareAction:(id)sender
{
    [self.managersAssembly.shareManager shareMADBike:self barButtonItem:sender handler:^(NSString *activityType, BOOL completed) {
        if (completed)
        {
            [self.managersAssembly.prePermissionManager push:nil];
        }
    }];
}

#pragma mark - BranchDeepLinkingController

- (void)configureControlWithData:(NSDictionary *)data
{
    @weakify(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self)
        if ([data[BRANCH_INIT_KEY_CLICKED_BRANCH_LINK] boolValue])
        {
            [BMAnalyticsManager logCustomEventWithName:kBMInstallAfterReferralKey customAttributes:nil];
            
            if ([data[BRANCH_INIT_KEY_FEATURE] isEqualToString:BRANCH_FEATURE_TAG_REFERRAL] && [data[BRANCH_INIT_KEY_IS_FIRST_SESSION] boolValue])
            {
                self.descriptionLabel.text = NSLocalizedString(@"Seems like a friend has recommended MADBike to you and with that, you've won a MADPoint.\n\nShare MADBike with friends and earn even more MADPoints that you can redeem for sweet prizes!", @"Seems like a friend has recommended MADBike to you and with that, you've won a MADPoint.\n\nShare MADBike with friends and earn even more MADPoints that you can redeem for sweet prizes!");
            }
        }
    });
}

@end
