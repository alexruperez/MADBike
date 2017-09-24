//
//  BMManagersAssembly.h
//  BiciMAD
//
//  Created by alexruperez on 19/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import CoreLocation;
@import UserNotifications;
@import Typhoon;

@class BMApplicationAssembly;
@class BMViewControllersAssembly;
@class BMServicesAssembly;

@class BMUserDefaultsManager;
@class BMKeychainManager;
@class BMCoreDataManager;
@class BMSpotlightManager;
@class AFNetworkReachabilityManager;
@class BMFavoritesManager;
@class Crashlytics;
@class BMDraggableDialogManager;
@class BMPrePermissionManager;
@class ShareManager;

@interface BMManagersAssembly : TyphoonAssembly

@property (nonatomic, strong, readonly) BMApplicationAssembly *applicationAssembly;
@property (nonatomic, strong, readonly) BMViewControllersAssembly *viewControllersAssembly;
@property (nonatomic, strong, readonly) BMServicesAssembly *servicesAssembly;

- (NSNotificationCenter *)notificationCenter;

- (CLLocationManager *)locationManager;

- (CLGeocoder *)geocoderManager;

- (NSURLCache *)URLCache;

- (NSFileManager *)fileManager;

- (UNUserNotificationCenter *)userNotificationCenter;

- (BMUserDefaultsManager *)userDefaultsManager;

- (BMCoreDataManager *)coreDataManager;

- (BMSpotlightManager *)spotlightManager;

- (AFNetworkReachabilityManager *)reachabilityManager;

- (BMFavoritesManager *)favoritesManager;

- (Crashlytics *)crashlyticsManager;

- (BMDraggableDialogManager *)draggableDialogManager;

- (BMPrePermissionManager *)prePermissionManager;

- (ShareManager *)shareManager;

@end
