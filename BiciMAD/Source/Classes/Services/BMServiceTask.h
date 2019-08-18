//
//  BMServiceTask.h
//  BiciMAD
//
//  Created by alexruperez on 13/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import Foundation;

@class BMHTTPClient;
@class BMMutableURLRequest;
@class BMFavoritesManager;
@class BMCoreDataManager;
@class Crashlytics;
@class BMSpotlightManager;
@class BMUserDefaultsManager;

@interface BMServiceTask : NSObject

@property (nonatomic, strong) BMFavoritesManager *favoritesManager;
@property (nonatomic, strong) BMCoreDataManager *coreDataManager;
@property (nonatomic, strong) Crashlytics *crashlyticsManager;
@property (nonatomic, strong) BMSpotlightManager *spotlightManager;
@property (nonatomic, strong) BMUserDefaultsManager *userDefaultsManager;

@property (nonatomic, strong) BMHTTPClient *HTTPClient;
@property (nonatomic, copy) void (^successBlock)(id responseObject);
@property (nonatomic, copy) void (^failureBlock)(NSError *error);

+ (instancetype)taskWithHTTPClient:(BMHTTPClient *)HTTPClient;

- (void)execute;
- (void)executeInBackground:(BOOL)background;
- (void)cancel;

@end
