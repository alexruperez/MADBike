//
//  BMAppDelegate.m
//  BiciMAD
//
//  Created by alexruperez on 7/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMAppDelegate.h"

@import AFNetworking;
@import AFNetworkActivityLogger;
@import CocoaLumberjack;
@import iRate;
@import InAppSettingsKit;
@import Bolts;
@import FXNotifications;
@import OneSignal;
@import UserNotifications;

#import "BMManagersAssembly.h"
#import "BMAnalyticsManager.h"
#import "BMRootViewController.h"
#import "BMCoreDataManager.h"
#import "BMFavoritesManager.h"
#import "BMUserDefaultsManager.h"
#import "DDCLSLogger.h"
#import "BMStation.h"
#import "BMPlace.h"

@interface BMAppDelegate () <UNUserNotificationCenterDelegate, iRateDelegate>

@property (nonatomic, strong) BFAppLink *appLinkReferer;

@end

@implementation BMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [DDLog addLogger:self.aslLogger];
    [DDLog addLogger:self.ttyLogger];
    [self.ttyLogger setColorsEnabled:YES];
    
#ifndef DEBUG
    [DDLog addLogger:self.clsLogger];
    [self.networkActivityLogger.loggers.anyObject setLevel:AFLoggerLevelError];
#endif
    [self.networkActivityLogger startLogging];

    self.iRate.delegate = self;
    self.iRate.verboseLogging = NO;
    
    [BMAnalyticsManager takeOffWithApplication:application options:launchOptions];
    
    [self.managersAssembly.userDefaultsManager takeOff];
    
    [self.managersAssembly.coreDataManager takeOff];
    
    @weakify(self)
    @try {
        [self.managersAssembly.coreDataManager findAll:BMStation.class completion:^(NSArray *results, NSError *error) {
            @strongify(self)
            [self.managersAssembly.favoritesManager save:results];
        }];
        
        [self.managersAssembly.coreDataManager findAll:BMPartner.class completion:^(NSArray *results, NSError *error) {
            @strongify(self)
            for (BMPartner *partner in results)
            {
                [self.managersAssembly.favoritesManager save:partner.places];
                [self.managersAssembly.favoritesManager save:partner.promotions];
            }
        }];
    }
    @catch (NSException *exception)
    {
        DDLogInfo(@"%@", exception.reason);
        [self.managersAssembly.coreDataManager truncateDatabaseWithCompletion:nil];
    }
    
    [self.managersAssembly.reachabilityManager startMonitoring];
    
    [self.managersAssembly.notificationCenter addObserver:self forName:kIASKAppSettingChanged object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self updateIdleTimerDisabled:note];
    }];
    [self.managersAssembly.notificationCenter addObserver:self forName:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        DDLogInfo(@"Ubiquitous reason: %@", note.userInfo[NSUbiquitousKeyValueStoreChangeReasonKey]);
        DDLogInfo(@"Ubiquitous keys: %@", note.userInfo[NSUbiquitousKeyValueStoreChangedKeysKey]);
        @strongify(self)
        [self updateIdleTimerDisabled:note];
    }];
    [self.managersAssembly.notificationCenter addObserver:self forName:UIWindowDidResignKeyNotification object:nil queue:NSOperationQueue.new usingBlock:^(NSNotification * _Nonnull note, id  _Nonnull observer) {
        DDLogInfo(@"Window did resign: %@", note.object);
    }];

    self.managersAssembly.userNotificationCenter.delegate = self;
    
    return YES;
}

- (void)updateIdleTimerDisabled:(id)sender
{
    self.application.idleTimerDisabled = [self.managersAssembly.userDefaultsManager storedBoolForKey:kBMUserDefaultsIdleTimerDisabledKey];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    DDLogWarn(@"Received memory warning.");
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options
{
    self.appLinkReferer = [BFURL URLWithURL:url].appLinkReferer;
    return [BMAnalyticsManager handleOpenURL:url application:app options:options];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler
{
    return [BMAnalyticsManager handleUserActivity:userActivity application:application restorationHandler:restorationHandler];
}

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame
{
    for (UIWindow *window in application.windows)
    {
        if ([window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")])
        {
            [window removeConstraints:window.constraints];
        }
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [BMAnalyticsManager handleDeviceToken:deviceToken];
    [self.managersAssembly.userDefaultsManager refreshNotificationTags:application];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DDLogWarn(@"Fail to register for remote notifications: %@", error.localizedDescription);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [BMAnalyticsManager handleRemoteNotification:userInfo action:nil application:application fetchCompletionHandler:completionHandler];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [BMAnalyticsManager handleFetchCompletionHandler:completionHandler application:application];
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    [BMAnalyticsManager performActionForShortcutItem:shortcutItem application:application completionHandler:completionHandler];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self updateIdleTimerDisabled:application];
    [BMAnalyticsManager handleApplicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    [BMAnalyticsManager willPresentNotification:notification center:center completionHandler:completionHandler];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response withCompletionHandler:(nonnull void (^)(void))completionHandler
{
    [BMAnalyticsManager didReceiveNotificationResponse:response center:center completionHandler:completionHandler];
}

#pragma mark - iRateDelegate

- (void)iRateDidDetectAppUpdate
{
    [BMAnalyticsManager logRating:@NO contentName:nil contentType:nil contentId:nil customAttributes:nil];
}

- (void)iRateDidOpenAppStore
{
    [BMAnalyticsManager logRating:@YES contentName:nil contentType:nil contentId:nil customAttributes:nil];
}

@end
