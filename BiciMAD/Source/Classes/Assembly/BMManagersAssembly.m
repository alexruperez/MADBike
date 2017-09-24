//
//  BMManagersAssembly.m
//  BiciMAD
//
//  Created by alexruperez on 19/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMManagersAssembly.h"

@import AFNetworking;
@import Crashlytics;

#import "BMApplicationAssembly.h"
#import "BMServicesAssembly.h"
#import "BMUserDefaultsManager.h"
#import "BMCoreDataManager.h"
#import "BMSpotlightManager.h"
#import "BMFavoritesManager.h"
#import "BMDraggableDialogManager.h"
#import "BMPrePermissionManager.h"
#import "MADBike-Swift.h"

@implementation BMManagersAssembly

- (NSNotificationCenter *)notificationCenter
{
    return [TyphoonDefinition withClass:[NSNotificationCenter class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(defaultCenter)];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (CLLocationManager *)locationManager
{
    return [TyphoonDefinition withClass:[CLLocationManager class] configuration:^(TyphoonDefinition *definition) {
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (CLGeocoder *)geocoderManager
{
    return [TyphoonDefinition withClass:[CLGeocoder class] configuration:^(TyphoonDefinition *definition) {
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (NSUserDefaults *)userDefaults
{
    return [TyphoonDefinition withClass:[NSUserDefaults class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(standardUserDefaults)];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (NSURLCache *)URLCache
{
    return [TyphoonDefinition withClass:[NSURLCache class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(sharedURLCache)];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (NSFileManager *)fileManager
{
    return [TyphoonDefinition withClass:[NSFileManager class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(defaultManager)];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (UNUserNotificationCenter *)userNotificationCenter
{
    return [TyphoonDefinition withClass:[UNUserNotificationCenter class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(currentNotificationCenter)];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMUserDefaultsManager *)userDefaultsManager
{
    return [TyphoonDefinition withClass:[BMUserDefaultsManager class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(managerWithUserDefaults:notificationCenter:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:[self userDefaults]];
            [initializer injectParameterWith:[self notificationCenter]];
        }];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMCoreDataManager *)coreDataManager
{
    return [TyphoonDefinition withClass:[BMCoreDataManager class] configuration:^(TyphoonDefinition *definition) {
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMSpotlightManager *)spotlightManager
{
    return [TyphoonDefinition withClass:[BMSpotlightManager class] configuration:^(TyphoonDefinition *definition) {
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (AFNetworkReachabilityManager *)reachabilityManager
{
    return [TyphoonDefinition withClass:[AFNetworkReachabilityManager class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(sharedManager)];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMFavoritesManager *)favoritesManager
{
    return [TyphoonDefinition withClass:[BMFavoritesManager class] configuration:^(TyphoonDefinition *definition) {
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (Crashlytics *)crashlyticsManager
{
    return [TyphoonDefinition withClass:[Crashlytics class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(sharedInstance)];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMDraggableDialogManager *)draggableDialogManager
{
    return [TyphoonDefinition withClass:[BMDraggableDialogManager class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(window) with:[self.applicationAssembly window]];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMPrePermissionManager *)prePermissionManager
{
    return [TyphoonDefinition withClass:[BMPrePermissionManager class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(draggableDialogManager) with:[self draggableDialogManager]];
        [definition injectProperty:@selector(locationManager) with:[self locationManager]];
        [definition injectProperty:@selector(application) with:[self.applicationAssembly application]];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (ShareManager *)shareManager
{
    return [TyphoonDefinition withClass:[ShareManager class] configuration:^(TyphoonDefinition *definition) {
        definition.scope = TyphoonScopeSingleton;
    }];
}

@end
