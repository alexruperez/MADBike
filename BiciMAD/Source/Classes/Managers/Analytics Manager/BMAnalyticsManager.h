//
//  BMAnalyticsManager.h
//  BiciMAD
//
//  Created by alexruperez on 10/12/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import UIKit;

@import FBSDKCoreKit;
@import UserNotifications;
@import Keys;

extern NSString * const kBMAppStoreId;
extern NSString * const kBMGooglePlayId;
extern NSString * const kBMSourceKey;
extern NSString * const kBMSignUpMethodKey;
extern NSString * const kBMLoginMethodKey;
extern NSString * const kBMSilentLoginMethodKey;
extern NSString * const kBMTwitterLoginMethodKey;
extern NSString * const kBMLoginIDKey;
extern NSString * const kBMLoginNameKey;
extern NSString * const kBMLoginMailKey;
extern NSString * const kBMMapEngineKey;
extern NSString * const kBMNewsKey;
extern NSString * const kBMTipsKey;
extern NSString * const kBMGreenTipsKey;
extern NSString * const kBMIncidenceKey;
extern NSString * const kBMChangePasswordKey;
extern NSString * const kBMClearCacheKey;
extern NSString * const kBMEnableNotificationsKey;
extern NSString * const kBMInstallAfterReferralKey;
extern NSString * const kBMDeepLinkKey;
extern NSString * const kBMDeepLinkURLStringKey;
extern NSString * const kBMMADBikeLinkKey;
extern NSString * const kBMSpotlightKey;
extern NSString * const kBMSpotlightActionKey;
extern NSString * const kBMSpotlightIdentifierKey;

typedef void (^BMRewardsCompletionHandler)(BOOL changed, NSInteger credits, NSError *error);

@interface BMAnalyticsManager : NSObject

+ (BiciMADKeys *)keys;

+ (void)takeOffWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions;

+ (BOOL)handleOpenURL:(NSURL *)url application:(UIApplication *)application options:(NSDictionary *)options;

+ (BOOL)handleUserActivity:(NSUserActivity *)userActivity application:(UIApplication *)application restorationHandler:(void (^)(NSArray *))restorationHandler;

+ (void)handleApplicationDidBecomeActive;

+ (void)registerForRemoteNotifications;

+ (void)handleDeviceToken:(NSData *)deviceToken;

+ (void)handleRemoteNotification:(NSDictionary *)userInfo action:(NSString *)action application:(UIApplication *)application fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

+ (void)willPresentNotification:(UNNotification *)notification center:(UNUserNotificationCenter *)center completionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler;

+ (void)didReceiveNotificationResponse:(UNNotificationResponse *)response center:(UNUserNotificationCenter *)center completionHandler:(void(^)(void))completionHandler;

+ (void)handleFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler application:(UIApplication *)application;

+ (void)handleAction:(NSString *)action remoteNotification:(NSDictionary *)userInfo responseInfo:(NSDictionary *)responseInfo application:(UIApplication *)application completionHandler:(void (^)(void))completionHandler;

+ (void)performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem application:(UIApplication *)application completionHandler:(void (^)(BOOL))completionHandler;

+ (void)logSignUpWithMethod:(NSString *)signUpMethod success:(NSNumber *)signUpSucceeded customAttributes:(NSDictionary *)customAttributes;

+ (void)logLoginWithMethod:(NSString *)loginMethod success:(NSNumber *)loginSucceeded customAttributes:(NSDictionary *)customAttributes;

+ (void)logUserProperties:(NSDictionary *)parameters;

+ (void)logLogoutWithMethod:(NSString *)loginMethod customAttributes:(NSDictionary *)customAttributes;

+ (void)logShareWithMethod:(NSString *)shareMethod contentName:(NSString *)contentName contentType:(NSString *)contentType contentId:(NSString *)contentId customAttributes:(NSDictionary *)customAttributes;

+ (void)logInviteWithMethod:(NSString *)inviteMethod customAttributes:(NSDictionary *)customAttributes;

+ (void)logRating:(NSNumber *)rating contentName:(NSString *)contentName contentType:(NSString *)contentType contentId:(NSString *)contentId customAttributes:(NSDictionary *)customAttributes;

+ (void)logContentViewWithName:(NSString *)contentName contentType:(NSString *)contentType contentId:(NSString *)contentId customAttributes:(NSDictionary *)customAttributes;

+ (void)logSearchWithQuery:(NSString *)query customAttributes:(NSDictionary *)customAttributes;

+ (void)logFilterGreen:(BOOL)green red:(BOOL)red yellow:(BOOL)yellow gray:(BOOL)gray;

+ (void)logFavorites:(NSDictionary *)customAttributes;

+ (void)logNotificationTags:(NSDictionary *)tags;

+ (void)logCustomEventWithName:(NSString *)eventName customAttributes:(NSDictionary *)customAttributes;

+ (void)loadRewardsWithCompletion:(BMRewardsCompletionHandler)rewardsCompletionHandler;

@end
