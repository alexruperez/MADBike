//
//  BMDeepLinkingManager.h
//  BiciMAD
//
//  Created by alexruperez on 19/1/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import UIKit;

extern NSString * const kBMMADBikeDeepLinkPrefix;
extern NSString * const kBMMADBikeDeepLinkNotification;
extern NSString * const kBMMADBikeDeepLinkStationNotification;
extern NSString * const kBMMADBikeDeepLinkWeatherNotification;
extern NSString * const kBMMADBikeDeepLinkAirQualityNotification;
extern NSString * const kBMMADBikeDeepLinkNewsNotification;
extern NSString * const kBMMADBikeDeepLinkReportNotification;
extern NSString * const kBMMADBikeDeepLinkSettingsNotification;
extern NSString * const kBMMADBikeDeepLinkShareNotification;
extern NSString * const kBMMADBikeDeepLinkDirectionsRequestNotification;
extern NSString * const kBMMADBikeDeepLinkSearchNotification;

@interface BMDeepLinkingManager : NSObject

+ (BOOL)handleOpenURL:(NSURL *)url application:(UIApplication *)application options:(NSDictionary *)options;

+ (BOOL)handleUserActivity:(NSUserActivity *)userActivity application:(UIApplication *)application restorationHandler:(void (^)(NSArray *))restorationHandler;

@end
