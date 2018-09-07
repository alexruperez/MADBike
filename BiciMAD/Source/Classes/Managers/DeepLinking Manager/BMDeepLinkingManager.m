//
//  BMDeepLinkingManager.m
//  BiciMAD
//
//  Created by alexruperez on 19/1/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import CoreSpotlight;
@import MapKit;
@import StoreKit;
@import Branch;

#import "BMDeepLinkingManager.h"
#import "BMAnalyticsManager.h"
#import "MADBike-Swift.h"

static NSString * const kBMMADBikeDeepLinkStation = @"station";
static NSString * const kBMMADBikeDeepLinkAirQuality = @"quality";
static NSString * const kBMMADBikeDeepLinkNews = @"news";
static NSString * const kBMMADBikeDeepLinkReport = @"report";
static NSString * const kBMMADBikeDeepLinkSettings = @"settings";
static NSString * const kBMMADBikeDeepLinkShare = @"share";
static NSString * const kBMMADBikeDeepLinkSearch = @"search";
static NSString * const kBMMADBikeDeepLinkReview = @"review";
static NSString * const kBMMADBikeDeepLinkWeather = @"weather";
static NSString * const kBMBranchLinkIdentifier = @"app.link";

NSString * const kBMMADBikeDeepLinkIdentifier = @"id";
NSString * const kBMMADBikeUserActivityPrefix = @"org.drunkcode.MADBike.";
NSString * const kBMMADBikeUserActivityStation = @"org.drunkcode.MADBike.station";
NSString * const kBMMADBikeUserActivityAirQuality = @"org.drunkcode.MADBike.quality";
NSString * const kBMMADBikeUserActivityNews = @"org.drunkcode.MADBike.news";
NSString * const kBMMADBikeUserActivityReport = @"org.drunkcode.MADBike.report";
NSString * const kBMMADBikeUserActivitySettings = @"org.drunkcode.MADBike.settings";
NSString * const kBMMADBikeUserActivityShare = @"org.drunkcode.MADBike.share";
NSString * const kBMMADBikeUserActivitySearch = @"org.drunkcode.MADBike.search";
NSString * const kBMMADBikeUserActivityReview = @"org.drunkcode.MADBike.review";
NSString * const kBMMADBikeUserActivityWeather = @"org.drunkcode.MADBike.weather";

NSString * const kBMMADBikeDeepLinkPrefix = @"madbike";
NSString * const kBMMADBikeDeepLinkNotification = @"BMMADBikeDeepLinkNotification";
NSString * const kBMMADBikeDeepLinkStationNotification = @"BMMADBikeDeepLinkStationNotification";
NSString * const kBMMADBikeDeepLinkWeatherNotification = @"BMMADBikeDeepLinkWeatherNotification";
NSString * const kBMMADBikeDeepLinkAirQualityNotification = @"BMMADBikeDeepLinkAirQualityNotification";
NSString * const kBMMADBikeDeepLinkNewsNotification = @"BMMADBikeDeepLinkNewsNotification";
NSString * const kBMMADBikeDeepLinkReportNotification = @"BMMADBikeDeepLinkReportNotification";
NSString * const kBMMADBikeDeepLinkSettingsNotification = @"BMMADBikeDeepLinkSettingsNotification";
NSString * const kBMMADBikeDeepLinkShareNotification = @"BMMADBikeDeepLinkShareNotification";
NSString * const kBMMADBikeDeepLinkDirectionsRequestNotification = @"BMMADBikeDeepLinkDirectionsRequestNotification";
NSString * const kBMMADBikeDeepLinkSearchNotification = @"BMMADBikeDeepLinkSearchNotification";

@implementation BMDeepLinkingManager

+ (NSNotificationCenter *)notificationCenter
{
    return NSNotificationCenter.defaultCenter;
}

+ (NSString *)identifierForURL:(NSURL *)url
{
    NSString *query = url.fragment ? url.fragment : url.query;
    
    NSDictionary *params = [BNCEncodingUtils decodeQueryStringToDictionary:query];
    
    return params[kBMMADBikeDeepLinkIdentifier];
}

+ (BOOL)handleOpenURL:(NSURL *)url application:(UIApplication *)application options:(NSDictionary *)options
{
    if ([url isKindOfClass:NSURL.class])
    {
        [BMAnalyticsManager logCustomEventWithName:kBMDeepLinkKey customAttributes:@{kBMDeepLinkURLStringKey: url.absoluteString ? url.absoluteString : NSNull.null}];
        NSURL *deepLinkURL = url.deepLinkURL;
        if (deepLinkURL) {
            [BMAnalyticsManager logCustomEventWithName:kBMDeepLinkKey customAttributes:@{kBMDeepLinkURLStringKey: deepLinkURL.absoluteString ? deepLinkURL.absoluteString : NSNull.null}];
            url = deepLinkURL;
        }
        if ([url.absoluteString hasPrefix:kBMMADBikeDeepLinkPrefix])
        {
            NSString *identifier = [self identifierForURL:url];
            @weakify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkNotification object:identifier userInfo:options];
                if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"%@://%@", kBMMADBikeDeepLinkPrefix, kBMMADBikeDeepLinkStation]])
                {
                    [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkStationNotification object:identifier userInfo:options];
                }
                else if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"%@://%@", kBMMADBikeDeepLinkPrefix, kBMMADBikeDeepLinkWeather]])
                {
                    [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkWeatherNotification object:identifier userInfo:options];
                }
                else if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"%@://%@", kBMMADBikeDeepLinkPrefix, kBMMADBikeDeepLinkAirQuality]])
                {
                    [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkAirQualityNotification object:identifier userInfo:options];
                }
                else if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"%@://%@", kBMMADBikeDeepLinkPrefix, kBMMADBikeDeepLinkNews]])
                {
                    [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkNewsNotification object:identifier userInfo:options];
                }
                else if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"%@://%@", kBMMADBikeDeepLinkPrefix, kBMMADBikeDeepLinkReport]])
                {
                    [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkReportNotification object:identifier userInfo:options];
                }
                else if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"%@://%@", kBMMADBikeDeepLinkPrefix, kBMMADBikeDeepLinkSettings]])
                {
                    [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkSettingsNotification object:identifier userInfo:options];
                }
                else if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"%@://%@", kBMMADBikeDeepLinkPrefix, kBMMADBikeDeepLinkShare]])
                {
                    [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkShareNotification object:identifier userInfo:options];
                }
                else if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"%@://%@", kBMMADBikeDeepLinkPrefix, kBMMADBikeDeepLinkSearch]])
                {
                    [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkStationNotification object:nil userInfo:options];
                    [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkSearchNotification object:identifier userInfo:options];
                }
                else if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"%@://%@", kBMMADBikeDeepLinkPrefix, kBMMADBikeDeepLinkReview]])
                {
                    [BMAnalyticsManager logRating:@YES contentName:nil contentType:nil contentId:nil customAttributes:nil];
                    [SKStoreReviewController requestReview];
                }
            });
            return YES;
        }
        else if ([MKDirectionsRequest isDirectionsRequestURL:url])
        {
            MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] initWithContentsOfURL:url];
            @weakify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkNotification object:directionsRequest userInfo:options];
                [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkStationNotification object:directionsRequest userInfo:options];
                [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkDirectionsRequestNotification object:directionsRequest userInfo:options];
            });
            return YES;
        }
        else if ([application canOpenURL:url] && ![url.absoluteString containsString:kBMBranchLinkIdentifier])
        {
            [application openURL:url options:@{} completionHandler:nil];
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)handleUserActivity:(NSUserActivity *)userActivity application:(UIApplication *)application restorationHandler:(void (^)(NSArray *))restorationHandler
{
    if ([userActivity.activityType isEqualToString:CSSearchableItemActionType])
    {
        NSString *activityIdentifier = userActivity.userInfo[CSSearchableItemActivityIdentifier];
        
        if ([activityIdentifier isKindOfClass:NSString.class])
        {
            [BMAnalyticsManager logCustomEventWithName:kBMSpotlightKey customAttributes:@{kBMActionKey: userActivity.activityType ? userActivity.activityType : NSNull.null, kBMIdentifierKey: activityIdentifier ? activityIdentifier : NSNull.null}];
           return [self handleOpenURL:[NSURL URLWithString:activityIdentifier] application:application options:userActivity.userInfo];
        }
    }
    else if ([userActivity.activityType isEqualToString:@"com.apple.corespotlightquerycontinuation"])
    {
        NSString *searchQueryString = userActivity.userInfo[@"kCSSearchQueryString"];
        [BMAnalyticsManager logCustomEventWithName:kBMSpotlightKey customAttributes:@{kBMActionKey: userActivity.activityType ? userActivity.activityType : NSNull.null, kBMIdentifierKey: searchQueryString ? searchQueryString : NSNull.null}];
        @weakify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkNotification object:searchQueryString userInfo:userActivity.userInfo];
            [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkStationNotification object:nil userInfo:userActivity.userInfo];
            [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkSearchNotification object:searchQueryString userInfo:userActivity.userInfo];
        });
        return YES;
    }
    else if ([userActivity.activityType hasPrefix:kBMMADBikeUserActivityPrefix])
    {
        NSString *identifier = userActivity.userInfo[kBMMADBikeDeepLinkIdentifier];
        NSDictionary *options = userActivity.userInfo;
        [BMAnalyticsManager logCustomEventWithName:kBMSiriShortcutKey customAttributes:@{kBMActionKey: userActivity.activityType ? userActivity.activityType : NSNull.null, kBMIdentifierKey: identifier ? identifier : NSNull.null}];
        @weakify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkNotification object:identifier userInfo:options];
            if ([userActivity.activityType isEqualToString:kBMMADBikeUserActivityStation])
            {
                [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkStationNotification object:identifier userInfo:options];
            }
            else if ([userActivity.activityType isEqualToString:kBMMADBikeUserActivityWeather])
            {
                [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkWeatherNotification object:identifier userInfo:options];
            }
            else if ([userActivity.activityType isEqualToString:kBMMADBikeUserActivityAirQuality])
            {
                [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkAirQualityNotification object:identifier userInfo:options];
            }
            else if ([userActivity.activityType isEqualToString:kBMMADBikeUserActivityNews])
            {
                [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkNewsNotification object:identifier userInfo:options];
            }
            else if ([userActivity.activityType isEqualToString:kBMMADBikeUserActivityReport])
            {
                [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkReportNotification object:identifier userInfo:options];
            }
            else if ([userActivity.activityType isEqualToString:kBMMADBikeUserActivitySettings])
            {
                [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkSettingsNotification object:identifier userInfo:options];
            }
            else if ([userActivity.activityType isEqualToString:kBMMADBikeUserActivityShare])
            {
                [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkShareNotification object:identifier userInfo:options];
            }
            else if ([userActivity.activityType isEqualToString:kBMMADBikeUserActivitySearch])
            {
                [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkStationNotification object:nil userInfo:options];
                [self.notificationCenter postNotificationName:kBMMADBikeDeepLinkSearchNotification object:identifier userInfo:options];
            }
            else if ([userActivity.activityType isEqualToString:kBMMADBikeUserActivityReview])
            {
                [BMAnalyticsManager logRating:@YES contentName:nil contentType:nil contentId:nil customAttributes:nil];
                [SKStoreReviewController requestReview];
            }
        });
        return YES;
    }
    
    [BMAnalyticsManager logCustomEventWithName:kBMSpotlightKey customAttributes:@{kBMActionKey: userActivity.activityType ? userActivity.activityType : NSNull.null, kBMIdentifierKey: userActivity.webpageURL ? userActivity.webpageURL : NSNull.null}];
    return [userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb] && [self handleOpenURL:userActivity.webpageURL application:application options:userActivity.userInfo];

}

@end
