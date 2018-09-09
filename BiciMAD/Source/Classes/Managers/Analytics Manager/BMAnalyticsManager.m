//
//  BMAnalyticsManager.m
//  BiciMAD
//
//  Created by alexruperez on 10/12/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMAnalyticsManager.h"

@import Fabric;
@import Crashlytics;
@import Branch;
@import GoogleMaps;
@import OneSignal;
@import TwitterKit;

#import "BMDeepLinkingManager.h"
#import "BMPrePermissionManager.h"

static NSString * const kBMSearchKey = @"Search";
static NSString * const kBMFilterKey = @"Filter";
static NSString * const kBMFavoritesKey = @"Favorites";
static NSString * const kBMNotificationsKey = @"Notifications";
static NSString * const kBMGreenFilterKey = @"GreenFilter";
static NSString * const kBMRedFilterKey = @"RedFilter";
static NSString * const kBMYellowFilterKey = @"YellowFilter";
static NSString * const kBMGrayFilterKey = @"GrayFilter";
static NSString * const kBMLogoutKey = @"Logout";
static NSString * const kBMShortcutKey = @"Shortcut";
static NSString * const kBMShortcutTypeKey = @"Type";
static NSString * const kBMRateKey = @"Rate";
static NSString * const kBMBranchMatchKey = @"+match_guaranteed";
static NSString * const kBMNonBranchLinkKey = @"+non_branch_link";
static NSString * const kBMViewControllerSuffix = @"ViewController";
static NSString * const kBMUserDefaultsMADPointsFriendsKey = @"MADPointsFriends";
NSString * const kBMSourceKey = @"Source";
NSString * const kBMSignUpMethodKey = @"SignUp";
NSString * const kBMLoginMethodKey = @"Login";
NSString * const kBMSilentLoginMethodKey = @"SilentLogin";
NSString * const kBMTwitterLoginMethodKey = @"Twitter";
NSString * const kBMLoginIDKey = @"UserID";
NSString * const kBMLoginNameKey = @"UserName";
NSString * const kBMLoginMailKey = @"UserMail";
NSString * const kBMMapEngineKey = @"MapEngine";
NSString * const kBMNewsKey = @"News";
NSString * const kBMTipsKey = @"Tips";
NSString * const kBMGreenTipsKey = @"GreenTips";
NSString * const kBMIncidenceKey = @"Incidence";
NSString * const kBMChangePasswordKey = @"ChangePassword";
NSString * const kBMClearCacheKey = @"ClearCache";
NSString * const kBMEnableNotificationsKey = @"EnableNotifications";
NSString * const kBMInstallAfterReferralKey = @"InstallAfterReferral";
NSString * const kBMDeepLinkKey = @"DeepLink";
NSString * const kBMDeepLinkURLStringKey = @"URLString";
NSString * const kBMMADBikeLinkKey = @"madbike_link";
NSString * const kBMSpotlightKey = @"Spotlight";
NSString * const kBMSiriShortcutKey = @"SiriShortcut";
NSString * const kBMActionKey = @"Action";
NSString * const kBMIdentifierKey = @"Identifier";

@implementation BMAnalyticsManager

static NSDictionary *_oneSignalTags = nil;

+ (FBSDKApplicationDelegate *)facebookApplicationDelegate
{
    return FBSDKApplicationDelegate.sharedInstance;
}

+ (Branch *)branch
{
#ifdef DEBUG
    Branch.useTestBranchKey = YES;
#endif
    return Branch.getInstance;
}

+ (Twitter *)twitter
{
    return Twitter.sharedInstance;
}

+ (NSNotificationCenter *)notificationCenter
{
    return NSNotificationCenter.defaultCenter;
}

+ (BiciMADKeys *)keys
{
    return BiciMADKeys.new;
}

+ (void)takeOffWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
#ifdef DEBUG
    [Fabric with:@[Branch.class]];
    [OneSignal setLogLevel:ONE_S_LL_FATAL visualLevel:ONE_S_LL_FATAL];
    //[self.branch setDebug];
#else
    [Fabric with:@[Crashlytics.class, Branch.class]];
    [OneSignal setLogLevel:ONE_S_LL_FATAL visualLevel:ONE_S_LL_NONE];
#endif

    [self.twitter startWithConsumerKey:self.keys.twitterConsumerKey consumerSecret:self.keys.twitterConsumerSecret];
    
    [self.facebookApplicationDelegate application:application didFinishLaunchingWithOptions:launchOptions];
    if (application.applicationState != UIApplicationStateBackground)
    {
        [self handleRemoteNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] action:nil application:application fetchCompletionHandler:nil];
    }
    if (launchOptions[UIApplicationLaunchOptionsURLKey] != nil)
    {
        [FBSDKAppLinkUtility fetchDeferredAppLink:^(NSURL *url, NSError *error) {
            if (!error)
            {
                [BMDeepLinkingManager handleOpenURL:url application:application options:launchOptions];
            }
        }];
    }
    
    @weakify(self)
    [self.branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        @strongify(self)
        NSString *linkURLString = params[kBMMADBikeLinkKey];
        NSString *nonBranchLinkURLString = params[kBMNonBranchLinkKey];
        if ([linkURLString isKindOfClass:NSString.class] && [params[kBMBranchMatchKey] boolValue])
        {
            [self handleOpenURL:[NSURL URLWithString:linkURLString] application:application options:params];
        }
        else if (nonBranchLinkURLString)
        {
            [self handleOpenURL:[NSURL URLWithString:nonBranchLinkURLString] application:application options:params];
        }
    }];

    [GMSServices provideAPIKey:self.keys.googleMapsAPIKey];

    [self configureOneSignalWithApplication:application options:launchOptions];
}

+ (NSDictionary *)oneSignalTags
{
    return _oneSignalTags;
}

+ (void)setOneSignalTags:(NSDictionary *)oneSignalTags shouldDelete:(BOOL)shouldDelete
{
    __block NSMutableDictionary *tags = NSMutableDictionary.new;

    for (id<NSCopying> key in self.oneSignalTags.allKeys) {
        NSString *newValue = oneSignalTags[key];
        if (![self.oneSignalTags[key] isEqualToString:newValue]) {
            tags[key] = newValue;
        }
    }

    _oneSignalTags = oneSignalTags;
    if (tags.count > 0) {
        [self sendOneSignalTags:tags shouldDelete:shouldDelete];
    }
}

+ (void)configureOneSignalWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    @weakify(self)
    [OneSignal initWithLaunchOptions:launchOptions appId:self.keys.oneSignalAppID handleNotificationReceived:^(OSNotification *notification) {
        DDLogInfo(@"Notification received: %@", notification.payload.notificationID);
    } handleNotificationAction:^(OSNotificationOpenedResult *result) {
        DDLogInfo(@"Notification action: %@", result.action.actionID);
        NSDictionary *params = result.notification.payload.additionalData;
        if ([params isKindOfClass:NSDictionary.class])
        {
            NSString *linkURLString = params[kBMMADBikeLinkKey];
            if ([linkURLString isKindOfClass:NSString.class])
            {
                @strongify(self)
                [self handleOpenURL:[NSURL URLWithString:linkURLString] application:application options:params];
            }
        }
    } settings:@{kOSSettingsKeyAutoPrompt: @NO, kOSSettingsKeyInAppLaunchURL: @NO, kOSSettingsKeyInAppAlerts: @NO}];
    [OneSignal setInFocusDisplayType:OSNotificationDisplayTypeNotification];
    [OneSignal getTags:^(NSDictionary *result) {
        _oneSignalTags = result;
    }];
}

+ (BOOL)increaseTag:(NSString *)tag shouldDelete:(BOOL)shouldDelete
{
    if ([tag isKindOfClass:NSString.class])
    {
        if ([tag hasSuffix:kBMViewControllerSuffix])
        {
            tag = [tag stringByReplacingCharactersInRange:NSMakeRange(tag.length-kBMViewControllerSuffix.length, kBMViewControllerSuffix.length) withString:@""];
        }
        NSString *value = self.oneSignalTags[tag];
        return [self sendTags:@{tag: value ? @(value.integerValue + 1).stringValue : FBSDKAppEventParameterValueYes} force:NO shouldDelete:shouldDelete];
    }
    return NO;
}

+ (BOOL)sendTag:(NSString *)tag value:(NSString *)value shouldDelete:(BOOL)shouldDelete
{
    if ([tag isKindOfClass:NSString.class] && [value isKindOfClass:NSString.class])
    {
        if ([value isKindOfClass:NSString.class] && [value isEqualToString:FBSDKAppEventParameterValueNo]) {
            [OneSignal deleteTag:tag];
        }
        else
        {
            [OneSignal sendTag:tag value:value];
        }
        return [self sendTags:@{tag: value} force:YES shouldDelete:shouldDelete];
    }
    return NO;
}

+ (BOOL)sendTags:(NSDictionary *)tags force:(BOOL)force shouldDelete:(BOOL)shouldDelete
{
    if ([tags isKindOfClass:NSDictionary.class])
    {
        __block NSMutableDictionary *oneSignalTags = self.oneSignalTags.mutableCopy;
        if (oneSignalTags)
        {
            [oneSignalTags addEntriesFromDictionary:tags];
            [self setOneSignalTags:oneSignalTags.copy shouldDelete:shouldDelete];
            return YES;
        }
        else if (force)
        {
            [self sendOneSignalTags:oneSignalTags.copy shouldDelete:shouldDelete];
            return YES;
        }
        else
        {
            @weakify(self)
            [OneSignal getTags:^(NSDictionary *result) {
                @strongify(self)
                oneSignalTags = tags.mutableCopy;
                [oneSignalTags addEntriesFromDictionary:result];
                [self setOneSignalTags:oneSignalTags.copy shouldDelete:shouldDelete];
            }];
        }
    }
    return NO;
}

+ (void)sendOneSignalTags:(NSDictionary *)tags shouldDelete:(BOOL)shouldDelete
{
    NSMutableDictionary *sendOneSignalTags = [[NSMutableDictionary alloc] initWithCapacity:100];
    [sendOneSignalTags addEntriesFromDictionary:tags];

    if (shouldDelete) {
        NSMutableArray *deleteOneSignalTags = NSMutableArray.new;

        for (id<NSCopying> key in tags.allKeys) {
            NSString *value = tags[key];
            if ([value isKindOfClass:NSString.class] && [value isEqualToString:FBSDKAppEventParameterValueNo]) {
                [sendOneSignalTags removeObjectForKey:key];
                [deleteOneSignalTags addObject:key];
            }
        }

        if (deleteOneSignalTags.count > 0) {
            [OneSignal deleteTags:[deleteOneSignalTags subarrayWithRange:NSMakeRange(0, MIN(100, deleteOneSignalTags.count))]];
        }
    }

    if (sendOneSignalTags.count > 0) {
        [OneSignal sendTags:sendOneSignalTags.copy];
    }
}

+ (BOOL)handleOpenURL:(NSURL *)url application:(UIApplication *)application options:(NSDictionary *)options
{
    return [self.facebookApplicationDelegate application:application openURL:url options:options] || [self.twitter application:application openURL:url options:options] || [BMDeepLinkingManager handleOpenURL:url application:application options:options] || [self.branch application:application openURL:url options:options];
}

+ (BOOL)handleUserActivity:(NSUserActivity *)userActivity application:(UIApplication *)application restorationHandler:(void (^)(NSArray *))restorationHandler
{
    return [BMDeepLinkingManager handleUserActivity:userActivity application:application restorationHandler:restorationHandler] || [self.branch continueUserActivity:userActivity];
}

+ (void)handleApplicationDidBecomeActive
{
    [FBSDKAppEvents activateApp];
}

+ (void)registerForRemoteNotifications
{
    [OneSignal promptForPushNotificationsWithUserResponse:nil];
}

+ (void)handleDeviceToken:(NSData *)deviceToken
{
    [FBSDKAppEvents setPushNotificationsDeviceToken:deviceToken];
}

+ (void)handleRemoteNotification:(NSDictionary *)userInfo action:(NSString *)action application:(UIApplication *)application fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [FBSDKAppEvents logPushNotificationOpen:userInfo action:action];
    [self.branch handlePushNotification:userInfo];
    if (completionHandler)
    {
        [self handleFetchCompletionHandler:completionHandler application:application];
    }
}

+ (void)willPresentNotification:(UNNotification *)notification center:(UNUserNotificationCenter *)center completionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    if (completionHandler)
    {
        UNNotificationPresentationOptions notificationPresentationOptions = (UNNotificationPresentationOptions)(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
        completionHandler(notificationPresentationOptions);
    }
}

+ (void)didReceiveNotificationResponse:(UNNotificationResponse *)response center:(UNUserNotificationCenter *)center completionHandler:(void(^)(void))completionHandler
{
    if (completionHandler)
    {
        completionHandler();
    }
}

+ (void)handleFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler application:(UIApplication *)application
{
    if (!NSProcessInfo.processInfo.isLowPowerModeEnabled && [NSUserDefaults.standardUserDefaults boolForKey:kBMUserDefaultsMADPointsFriendsKey])
    {
        [self loadRewardsWithCompletion:^(BOOL changed, NSInteger credits, NSError *error) {
            if (!error)
            {
                if (changed)
                {
                    if (completionHandler)
                    {
                        completionHandler(UIBackgroundFetchResultNewData);
                    }
                }
                else if (completionHandler)
                {
                    completionHandler(UIBackgroundFetchResultNoData);
                }
            }
            else if (completionHandler)
            {
                completionHandler(UIBackgroundFetchResultFailed);
            }
        }];
    }
    else if (completionHandler)
    {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

+ (void)handleAction:(NSString *)action remoteNotification:(NSDictionary *)userInfo responseInfo:(NSDictionary *)responseInfo application:(UIApplication *)application completionHandler:(void (^)(void))completionHandler
{
    [self handleRemoteNotification:userInfo action:action application:application fetchCompletionHandler:nil];
    if (completionHandler)
    {
        completionHandler();
    }
}

+ (void)performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem application:(UIApplication *)application completionHandler:(void (^)(BOOL))completionHandler
{
    [self logCustomEventWithName:kBMShortcutKey customAttributes:@{kBMShortcutTypeKey: shortcutItem.type ? shortcutItem.type : NSNull.null}];
    BOOL result = NO;
    NSString *shortcutURLString = (NSString *)shortcutItem.userInfo[NSUserActivityTypeBrowsingWeb];
    if ([shortcutURLString isKindOfClass:NSString.class])
    {
        NSURL *shortcutURL = [NSURL URLWithString:shortcutURLString];
        if (shortcutURL)
        {
            result = [BMDeepLinkingManager handleOpenURL:shortcutURL application:application options:shortcutItem.userInfo];
        }
    }
    if (completionHandler)
    {
        completionHandler(result);
    }
}

+ (void)logSignUpWithMethod:(NSString *)signUpMethod
                    success:(NSNumber *)signUpSucceeded
           customAttributes:(NSDictionary *)customAttributes
{
    [Answers logSignUpWithMethod:signUpMethod success:signUpSucceeded customAttributes:customAttributes];
    [self sendTag:signUpMethod value:signUpSucceeded.boolValue ? FBSDKAppEventParameterValueYes : FBSDKAppEventParameterValueNo shouldDelete:NO];
    [self trackEvent:signUpMethod parameters:customAttributes];
}

+ (void)logLoginWithMethod:(NSString *)loginMethod
                   success:(NSNumber *)loginSucceeded
          customAttributes:(NSDictionary *)customAttributes
{
    if (![loginMethod isEqualToString:kBMTwitterLoginMethodKey])
    {
        NSString *loginMail = customAttributes[kBMLoginMailKey];
        NSString *loginID = customAttributes[kBMLoginIDKey];
        [FBSDKAppEvents setUserID:loginID];
        [OneSignal setEmail:loginMail withEmailAuthHashToken:loginID];
        [self.branch setIdentity:loginID];
    }
    [Answers logLoginWithMethod:loginMethod success:loginSucceeded customAttributes:customAttributes];
    [self sendTag:loginMethod value:loginSucceeded.boolValue ? FBSDKAppEventParameterValueYes : FBSDKAppEventParameterValueNo shouldDelete:NO];
    [self trackEvent:loginMethod parameters:customAttributes];
}

+ (void)logUserProperties:(NSDictionary *)parameters
{
    NSMutableDictionary *userProperties = parameters.mutableCopy;

    NSString *feature = self.branch.getFirstReferringParams[BRANCH_INIT_KEY_FEATURE];
    if (feature)
    {
        userProperties[@"$install_source"] = feature;
    }

    [FBSDKAppEvents updateUserProperties:userProperties.copy handler:nil];
}

+ (void)logLogoutWithMethod:(NSString *)loginMethod customAttributes:(NSDictionary *)customAttributes
{
    if (![loginMethod isEqualToString:kBMTwitterLoginMethodKey])
    {
        [FBSDKAppEvents setUserID:nil];
        [self.branch logout];
    }
    [self sendTag:loginMethod value:FBSDKAppEventParameterValueNo shouldDelete:NO];
    [self logCustomEventWithName:kBMLogoutKey customAttributes:customAttributes];
}

+ (void)logShareWithMethod:(NSString *)shareMethod
               contentName:(NSString *)contentName
               contentType:(NSString *)contentType
                 contentId:(NSString *)contentId
          customAttributes:(NSDictionary *)customAttributes
{
    [Answers logShareWithMethod:shareMethod contentName:contentName contentType:contentType contentId:contentId customAttributes:customAttributes];
    [self trackEvent:shareMethod parameters:customAttributes];
}

+ (void)logInviteWithMethod:(NSString *)inviteMethod
           customAttributes:(NSDictionary *)customAttributes
{
    [Answers logInviteWithMethod:inviteMethod customAttributes:customAttributes];
    [self sendTag:inviteMethod value:customAttributes[FBSDKAppEventParameterNameSuccess] shouldDelete:NO];
    [self trackEvent:inviteMethod parameters:customAttributes];
}

+ (void)logPurchaseWithPrice:(NSDecimalNumber *)itemPrice
                    currency:(NSString *)currency
                     success:(NSNumber *)purchaseSucceeded
                    itemName:(NSString *)itemName
                    itemType:(NSString *)itemType
                      itemId:(NSString *)itemId
            customAttributes:(NSDictionary *)customAttributes
{
    [Answers logPurchaseWithPrice:itemPrice currency:currency success:purchaseSucceeded itemName:itemName itemType:itemType itemId:itemId customAttributes:customAttributes];
    [self trackRevenue:itemPrice.doubleValue withCurrency:currency parameters:customAttributes];
}

+ (void)logLevelStart:(NSString *)levelName
     customAttributes:(NSDictionary *)customAttributes
{
    [Answers logLevelStart:levelName customAttributes:customAttributes];
    [self trackEvent:levelName parameters:customAttributes];
}

+ (void)logLevelEnd:(NSString *)levelName
              score:(NSNumber *)score
            success:(NSNumber *)levelCompletedSuccesfully
   customAttributes:(NSDictionary *)customAttributes
{
    [Answers logLevelEnd:levelName score:score success:levelCompletedSuccesfully customAttributes:customAttributes];
    [self trackEvent:FBSDKAppEventNameAchievedLevel parameters:customAttributes];
}

+ (void)logAddToCartWithPrice:(NSDecimalNumber *)itemPrice
                     currency:(NSString *)currency
                     itemName:(NSString *)itemName
                     itemType:(NSString *)itemType
                       itemId:(NSString *)itemId
             customAttributes:(NSDictionary *)customAttributes
{
    [Answers logAddToCartWithPrice:itemPrice currency:currency itemName:itemName itemType:itemType itemId:itemId customAttributes:customAttributes];
    [self trackEvent:FBSDKAppEventNameAddedToCart parameters:customAttributes];
}

+ (void)logStartCheckoutWithPrice:(NSDecimalNumber *)totalPrice
                         currency:(NSString *)currency
                        itemCount:(NSNumber *)itemCount
                 customAttributes:(NSDictionary *)customAttributes
{
    [Answers logStartCheckoutWithPrice:totalPrice currency:currency itemCount:itemCount customAttributes:customAttributes];
    [self trackEvent:FBSDKAppEventNameInitiatedCheckout parameters:customAttributes];
}

+ (void)logRating:(NSNumber *)rating
      contentName:(NSString *)contentName
      contentType:(NSString *)contentType
        contentId:(NSString *)contentId
 customAttributes:(NSDictionary *)customAttributes
{
    [Answers logRating:rating contentName:contentName contentType:contentType contentId:contentId customAttributes:customAttributes];
    [self sendTag:kBMRateKey value:rating.boolValue ? FBSDKAppEventParameterValueYes : FBSDKAppEventParameterValueNo shouldDelete:NO];
    [self trackEvent:FBSDKAppEventNameRated parameters:customAttributes];
}

+ (void)logContentViewWithName:(NSString *)contentName
                   contentType:(NSString *)contentType
                     contentId:(NSString *)contentId
              customAttributes:(NSDictionary *)customAttributes
{
    DDLogInfo(@"Content view: %@ - %@ - %@", contentName, contentType, contentId);
    [Answers logContentViewWithName:contentName contentType:contentType contentId:contentId customAttributes:customAttributes];
    BranchEvent *event = [BranchEvent standardEvent:BranchStandardEventViewItem];
    event.customData = customAttributes.mutableCopy;
    [event logEvent];
    [self increaseTag:contentName shouldDelete:NO];
    [self trackEvent:contentName parameters:customAttributes];
    [self trackEvent:FBSDKAppEventNameViewedContent parameters:customAttributes];
}

+ (void)logSearchWithQuery:(NSString *)query
          customAttributes:(NSDictionary *)customAttributes
{
    [Answers logSearchWithQuery:query customAttributes:customAttributes];
    [self trackEvent:kBMSearchKey parameters:customAttributes];
    [self trackEvent:FBSDKAppEventNameSearched parameters:customAttributes];
}

+ (void)logFilterGreen:(BOOL)green red:(BOOL)red yellow:(BOOL)yellow gray:(BOOL)gray
{
    NSDictionary *customAttributes = @{kBMGreenFilterKey: green ? FBSDKAppEventParameterValueYes : FBSDKAppEventParameterValueNo, kBMRedFilterKey: red ? FBSDKAppEventParameterValueYes : FBSDKAppEventParameterValueNo, kBMYellowFilterKey: yellow ? FBSDKAppEventParameterValueYes : FBSDKAppEventParameterValueNo, kBMGrayFilterKey: gray ? FBSDKAppEventParameterValueYes : FBSDKAppEventParameterValueNo};
    [self sendTags:customAttributes force:YES shouldDelete:NO];
    [self logCustomEventWithName:kBMFilterKey customAttributes:customAttributes];
}

+ (void)logFavorites:(NSDictionary *)customAttributes
{
    [self sendTags:customAttributes force:YES shouldDelete:YES];
    [self trackEvent:kBMFavoritesKey parameters:customAttributes];
}

+ (void)logNotificationTags:(NSDictionary *)tags
{
    [self sendTags:tags force:YES shouldDelete:NO];
    [self logCustomEventWithName:kBMNotificationsKey customAttributes:tags];
}

+ (void)logCustomEventWithName:(NSString *)eventName
              customAttributes:(NSDictionary *)customAttributes
{
    [Answers logCustomEventWithName:eventName customAttributes:customAttributes];
    [self trackEvent:eventName parameters:customAttributes];
}

+ (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    [FBSDKAppEvents logEvent:eventName parameters:parameters];
    [self.branch userCompletedAction:eventName withState:parameters];
}

+ (void)trackRevenue:(double)revenueAmount withCurrency:(NSString *)currency parameters:(NSDictionary *)parameters
{
    [FBSDKAppEvents logPurchase:revenueAmount currency:currency parameters:parameters];
}

+ (void)loadRewardsWithCompletion:(BMRewardsCompletionHandler)rewardsCompletionHandler
{
    [self.branch loadRewardsWithCallback:^(BOOL changed, NSError *error) {
        if (rewardsCompletionHandler)
        {
            rewardsCompletionHandler(changed, self.branch.getCredits, error);
        }
    }];
}

+ (NSURL *)getOnboardingURL:(NSString *)redirectUrl
{
    return [self.branch getUrlForOnboardingWithRedirectUrl:redirectUrl];
}

@end
