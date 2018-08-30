//
//  BMSettingsViewController.m
//  BiciMAD
//
//  Created by alexruperez on 26/1/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMSettingsViewController.h"

@import RESideMenu;
@import TwitterKit;

#import "BMAnalyticsManager.h"
#import "BMPrePermissionManager.h"

static NSString * const kBMCacheKey = @"cache";
static NSString * const kBMAppCacheKey = @"org.drunkcode.MADBike";

@interface BMSettingsViewController () <IASKSettingsDelegate, TWTRComposerViewControllerDelegate>

@property (nonatomic, strong, readonly) Twitter *twitter;

@end

@implementation BMSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    self.showCreditsFooter = NO;
    self.showDoneButton = NO;
    self.tableView.tintColor = UIColor.bm_tintColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (![self.file isEqualToString:@"Root"])
    {
        self.delegate = [(IASKAppSettingsViewController *)self.navigationController.viewControllers.firstObject delegate];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController:)];
        self.navigationItem.leftBarButtonItem.accessibilityLabel = NSLocalizedString(@"Menu", @"Menu");

        [BMAnalyticsManager logContentViewWithName:self.bm_className contentType:nil contentId:nil customAttributes:nil];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (Twitter *)twitter
{
    return Twitter.sharedInstance;
}

#pragma mark - IASKSettingsDelegate

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController *)sender
{
    
}

- (void)settingsViewController:(id<IASKViewController>)settingsViewController mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultFailed && error)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"Ok") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        alertController.view.tintColor = UIColor.bm_tintColor;
    }
}

- (void)settingsViewController:(IASKAppSettingsViewController *)sender buttonTappedForSpecifier:(IASKSpecifier *)specifier
{
    if ([specifier.key isEqualToString:@"clearCache"])
    {
        [BMAnalyticsManager logCustomEventWithName:kBMClearCacheKey customAttributes:nil];
        
        [self.URLCache removeAllCachedResponses];
        
        NSString *cacheDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSError *error = nil;
        if (cacheDirectory)
        {
            NSString *cachePath = [cacheDirectory stringByAppendingPathComponent:kBMCacheKey];
            if ([self.fileManager fileExistsAtPath:cachePath])
            {
                [self.fileManager removeItemAtPath:cachePath error:&error];
            }
            cachePath = [cacheDirectory stringByAppendingPathComponent:kBMAppCacheKey];
            if ([self.fileManager fileExistsAtPath:cachePath])
            {
                [self.fileManager removeItemAtPath:cachePath error:&error];
            }
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:!error ? NSLocalizedString(@"Succeed", @"Succeed") : NSLocalizedString(@"Error", @"Error") message:!error ? NSLocalizedString(@"Cache was successfully cleaned.", @"Cache was successfully cleaned.") : error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"Ok") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        alertController.view.tintColor = UIColor.bm_tintColor;
    }
    else if ([specifier.key isEqualToString:@"twitterLogout"])
    {
        [BMAnalyticsManager logLogoutWithMethod:kBMTwitterLoginMethodKey customAttributes:nil];
        
        for (id<TWTRAuthSession> session in self.twitter.sessionStore.existingUserSessions) {
            [self.twitter.sessionStore logOutUserID:session.userID];
        }

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Succeed", @"Succeed") message:NSLocalizedString(@"Twitter session was properly closed.", @"Twitter session was properly closed.") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"Ok") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        alertController.view.tintColor = UIColor.bm_tintColor;
    }
    else if ([specifier.key isEqualToString:@"enableNotifications"])
    {
        [BMAnalyticsManager logCustomEventWithName:kBMEnableNotificationsKey customAttributes:nil];
        
        [self.prePermissionManager push:nil];
    }
}

#pragma mark - TWTRComposerViewControllerDelegate

- (void)composerDidSucceed:(TWTRComposerViewController *)controller withTweet:(TWTRTweet *)tweet
{
    if (tweet)
    {
        [controller dismissViewControllerAnimated:YES completion:^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Succeed", @"Succeed") message:NSLocalizedString(@"Tweeted!", @"Tweeted!") preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"Ok") style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
            alertController.view.tintColor = UIColor.bm_tintColor;
        }];
    }
}

- (void)composerDidFail:(TWTRComposerViewController *)controller withError:(NSError *)error
{
    if (error)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"Ok") style:UIAlertActionStyleCancel handler:nil]];
        [controller presentViewController:alertController animated:YES completion:nil];
        alertController.view.tintColor = UIColor.bm_tintColor;
    }
}

@end
