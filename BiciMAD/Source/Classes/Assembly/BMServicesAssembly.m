//
//  BMServicesAssembly.m
//  BiciMAD
//
//  Created by alexruperez on 13/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMServicesAssembly.h"

#import "BMManagersAssembly.h"
#import "BMViewControllersAssembly.h"
#import "BMStoragesAssembly.h"

#import "BMAnalyticsManager.h"

#import "BMHTTPClient.h"

#import "BMTipsTimelineDataSource.h"
#import "BMNewsTimelineDataSource.h"
#import "BMGreenTipsTimelineDataSource.h"

#import "BMStationsService.h"
#import "BMPlacesService.h"
#import "BMAirQualityService.h"
#import "BMPointsService.h"
#import "BMWeatherDownloader.h"

#import "BMAllStationsTask.h"
#import "BMSingleStationTask.h"
#import "BMAirQualityTask.h"
#import "BMAllPartnersTask.h"
#import "BMEMTIncidencesTask.h"

@import GooglePlaces;

@implementation BMServicesAssembly

- (BMHTTPClient *)httpClientEMT
{
    return [TyphoonDefinition withClass:[BMHTTPClient class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(clientWithBaseURLString:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:kBMHTTPClientEMTURLString];
        }];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMHTTPClient *)httpClientDrunkcode
{
    return [TyphoonDefinition withClass:[BMHTTPClient class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(clientWithBaseURLString:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:kBMHTTPClientDrunkcodeProductionURLString];
        }];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (TWTRAPIClient *)twitterAPIClient
{
    return [TyphoonDefinition withClass:[TWTRAPIClient class] configuration:^(TyphoonDefinition *definition) {
        definition.scope = TyphoonScopeLazySingleton;
    }];
}

- (id<TWTRTimelineDataSource>)tipsTimelineDataSource
{
    return [TyphoonDefinition withClass:[BMTipsTimelineDataSource class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(initWithAPIClient:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:[self twitterAPIClient]];
        }];
        definition.scope = TyphoonScopeLazySingleton;
    }];
}

- (id<TWTRTimelineDataSource>)newsTimelineDataSource
{
    return [TyphoonDefinition withClass:[BMNewsTimelineDataSource class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(initWithAPIClient:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:[self twitterAPIClient]];
        }];
        definition.scope = TyphoonScopeLazySingleton;
    }];
}

- (id<TWTRTimelineDataSource>)greenTipsTimelineDataSource
{
    return [TyphoonDefinition withClass:[BMGreenTipsTimelineDataSource class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(initWithAPIClient:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:[self twitterAPIClient]];
        }];
        definition.scope = TyphoonScopeLazySingleton;
    }];
}

- (BMStationsService *)stationsService
{
    return [TyphoonDefinition withClass:[BMStationsService class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(servicesAssembly) with:self];
        [definition injectProperty:@selector(coreDataManager) with:[self.managersAssembly coreDataManager]];
        [definition injectProperty:@selector(favoritesManager) with:[self.managersAssembly favoritesManager]];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMPlacesService *)placesService
{
    return [TyphoonDefinition withClass:[BMPlacesService class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(servicesAssembly) with:self];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMAirQualityService *)airQualityService
{
    return [TyphoonDefinition withClass:[BMAirQualityService class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(servicesAssembly) with:self];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMPointsService *)pointsService
{
    return [TyphoonDefinition withClass:[BMPointsService class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(servicesAssembly) with:self];
        [definition injectProperty:@selector(coreDataManager) with:[self.managersAssembly coreDataManager]];
        [definition injectProperty:@selector(favoritesManager) with:[self.managersAssembly favoritesManager]];
        [definition injectProperty:@selector(pointsStorage) with:[self.storagesAssembly pointsStorage]];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMWeatherDownloader *)weatherDownloader
{
    return [TyphoonDefinition withClass:[BMWeatherDownloader class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(sharedDownloader)];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMServiceTask *)allStationsTask
{
    return [TyphoonDefinition withClass:[BMAllStationsTask class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(taskWithHTTPClient:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:[self httpClientEMT]];
        }];
        [definition injectProperty:@selector(favoritesManager) with:[self.managersAssembly favoritesManager]];
        [definition injectProperty:@selector(coreDataManager) with:[self.managersAssembly coreDataManager]];
        [definition injectProperty:@selector(crashlyticsManager) with:[self.managersAssembly crashlyticsManager]];
        [definition injectProperty:@selector(spotlightManager) with:[self.managersAssembly spotlightManager]];
        [definition injectProperty:@selector(userDefaultsManager) with:[self.managersAssembly userDefaultsManager]];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMServiceTask *)singleStationTaskWithStationId:(NSString *)stationId
{
    return [TyphoonDefinition withClass:[BMSingleStationTask class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(taskWithHTTPClient:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:[self httpClientEMT]];
        }];
        [definition injectProperty:@selector(favoritesManager) with:[self.managersAssembly favoritesManager]];
        [definition injectProperty:@selector(coreDataManager) with:[self.managersAssembly coreDataManager]];
        [definition injectProperty:@selector(crashlyticsManager) with:[self.managersAssembly crashlyticsManager]];
        [definition injectProperty:@selector(spotlightManager) with:[self.managersAssembly spotlightManager]];
        [definition injectProperty:@selector(userDefaultsManager) with:[self.managersAssembly userDefaultsManager]];
        [definition injectProperty:@selector(stationId) with:stationId];
    }];
}

- (BMServiceTask *)incidencesEMTTaskWithPhonePreferred:(NSNumber *)phonePreferred phone:(NSString *)phone email:(NSString *)email lastName:(NSString *)lastName subject:(NSString *)subject text:(NSString *)text
{
    return [TyphoonDefinition withClass:[BMEMTIncidencesTask class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(taskWithHTTPClient:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:[self httpClientEMT]];
        }];
        [definition injectProperty:@selector(favoritesManager) with:[self.managersAssembly favoritesManager]];
        [definition injectProperty:@selector(coreDataManager) with:[self.managersAssembly coreDataManager]];
        [definition injectProperty:@selector(crashlyticsManager) with:[self.managersAssembly crashlyticsManager]];
        [definition injectProperty:@selector(spotlightManager) with:[self.managersAssembly spotlightManager]];
        [definition injectProperty:@selector(userDefaultsManager) with:[self.managersAssembly userDefaultsManager]];
        [definition injectProperty:@selector(phonePreferred) with:phonePreferred];
        [definition injectProperty:@selector(phone) with:phone];
        [definition injectProperty:@selector(email) with:email];
        [definition injectProperty:@selector(lastName) with:lastName];
        [definition injectProperty:@selector(subject) with:subject];
        [definition injectProperty:@selector(text) with:text];
    }];
}

- (BMPlacesTask *)placesTaskWithInput:(NSString *)input sessionToken:(GMSAutocompleteSessionToken *)sessionToken filter:(GMSAutocompleteFilter *)filter
{
    return [TyphoonDefinition withClass:[BMPlacesTask class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(taskWithInput:sessionToken:filter:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:input];
            [initializer injectParameterWith:sessionToken];
            [initializer injectParameterWith:filter];
        }];
        [definition injectProperty:@selector(favoritesManager) with:[self.managersAssembly favoritesManager]];
        [definition injectProperty:@selector(coreDataManager) with:[self.managersAssembly coreDataManager]];
        [definition injectProperty:@selector(crashlyticsManager) with:[self.managersAssembly crashlyticsManager]];
        [definition injectProperty:@selector(spotlightManager) with:[self.managersAssembly spotlightManager]];
        [definition injectProperty:@selector(userDefaultsManager) with:[self.managersAssembly userDefaultsManager]];
    }];
}

- (BMServiceTask *)airQualityTaskWithOnlyCurrentValues:(NSNumber *)currentValues onlyAverage:(NSNumber *)onlyAverage discardAverage:(NSNumber *)discardAverage
{
    return [TyphoonDefinition withClass:[BMAirQualityTask class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(taskWithHTTPClient:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:[self httpClientDrunkcode]];
        }];
        [definition injectProperty:@selector(favoritesManager) with:[self.managersAssembly favoritesManager]];
        [definition injectProperty:@selector(coreDataManager) with:[self.managersAssembly coreDataManager]];
        [definition injectProperty:@selector(crashlyticsManager) with:[self.managersAssembly crashlyticsManager]];
        [definition injectProperty:@selector(spotlightManager) with:[self.managersAssembly spotlightManager]];
        [definition injectProperty:@selector(userDefaultsManager) with:[self.managersAssembly userDefaultsManager]];
        [definition injectProperty:@selector(currentValues) with:currentValues];
        [definition injectProperty:@selector(onlyAverage) with:onlyAverage];
        [definition injectProperty:@selector(discardAverage) with:discardAverage];
    }];
}

- (BMServiceTask *)allPartnersTask
{
    return [TyphoonDefinition withClass:[BMAllPartnersTask class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(taskWithHTTPClient:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:[self httpClientDrunkcode]];
        }];
        [definition injectProperty:@selector(favoritesManager) with:[self.managersAssembly favoritesManager]];
        [definition injectProperty:@selector(coreDataManager) with:[self.managersAssembly coreDataManager]];
        [definition injectProperty:@selector(crashlyticsManager) with:[self.managersAssembly crashlyticsManager]];
        [definition injectProperty:@selector(spotlightManager) with:[self.managersAssembly spotlightManager]];
        [definition injectProperty:@selector(userDefaultsManager) with:[self.managersAssembly userDefaultsManager]];
        definition.scope = TyphoonScopeSingleton;
    }];
}

@end
