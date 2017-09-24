//
//  BMViewControllersAssembly.m
//  BiciMAD
//
//  Created by alexruperez on 19/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMViewControllersAssembly.h"

#import "BMApplicationAssembly.h"
#import "BMServicesAssembly.h"
#import "BMManagersAssembly.h"
#import "BMStoragesAssembly.h"
#import "BMPresentersAssembly.h"

#import "BMRootViewController.h"
#import "BMLeftMenuViewController.h"
#import "BMTwitterTimelinePageViewController.h"
#import "BMStationsViewController.h"
#import "BMAnnotationsDetailViewController.h"
#import "BMPlacesTableViewController.h"
#import "BMWeatherViewController.h"
#import "BMSafariViewController.h"
#import "BMSettingsViewController.h"
#import "BMTwitterTimelineViewController.h"
#import "BMTwitterReportViewController.h"
#import "BMAirQualityViewController.h"
#import "BMShareViewController.h"

@implementation BMViewControllersAssembly

- (BMRootViewController *)rootViewController
{
    return [TyphoonDefinition withClass:[BMRootViewController class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(notificationCenter) with:[self.managersAssembly notificationCenter]];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMLeftMenuViewController *)leftMenuViewController
{
    return [TyphoonDefinition withClass:[BMLeftMenuViewController class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(viewControllersAssembly) with:self];
        [definition injectProperty:@selector(applicationAssembly) with:self.applicationAssembly];
        [definition injectProperty:@selector(servicesAssembly) with:self.servicesAssembly];
        [definition injectProperty:@selector(prePermissionManager) with:[self.managersAssembly prePermissionManager]];
        [definition injectProperty:@selector(notificationCenter) with:[self.managersAssembly notificationCenter]];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMStationsViewController *)stationsViewController
{
    return [TyphoonDefinition withClass:[BMStationsViewController class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(stationsService) with:[self.servicesAssembly stationsService]];
        [definition injectProperty:@selector(placesService) with:[self.servicesAssembly placesService]];
        [definition injectProperty:@selector(pointsService) with:[self.servicesAssembly pointsService]];
        [definition injectProperty:@selector(pointsStorage) with:[self.storagesAssembly pointsStorage]];
        [definition injectProperty:@selector(viewControllersAssembly) with:self];
        [definition injectProperty:@selector(applicationAssembly) with:self.applicationAssembly];
        [definition injectProperty:@selector(managersAssembly) with:self.managersAssembly];
        [definition injectProperty:@selector(presentersAssembly) with:self.presentersAssembly];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMAnnotationsDetailViewController *)annotationsDetailViewControllerWithAnnotations:(NSArray *)annotations titleString:(NSString *)titleString
{
    return [TyphoonDefinition withClass:[BMAnnotationsDetailViewController class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(managersAssembly) with:self.managersAssembly];
        [definition injectProperty:@selector(annotations) with:annotations];
        [definition injectProperty:@selector(titleString) with:titleString];
    }];
}

- (BMPlacesTableViewController *)placesTableViewControllerWithDelegate:(id<BMPlacesTableViewControllerDelegate>)delegate
{
    return [TyphoonDefinition withClass:[BMPlacesTableViewController class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(initWithDelegate:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:delegate];
        }];
        [definition injectProperty:@selector(managersAssembly) with:self.managersAssembly];
    }];
}

- (UIViewController *)safariViewControllerWithURLString:(NSString *)URLString onLoad:(void (^)(BOOL didLoad))load onFinish:(void (^)(void))finish
{
    return [TyphoonDefinition withClass:[BMSafariViewController class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(initWithURLString:onLoad:onFinish:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:URLString];
            [initializer injectParameterWith:load];
            [initializer injectParameterWith:finish];
        }];
    }];
}

- (BMWeatherViewController *)weatherViewController
{
    return [TyphoonDefinition withClass:[BMWeatherViewController class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(servicesAssembly) with:self.servicesAssembly];
        [definition injectProperty:@selector(managersAssembly) with:self.managersAssembly];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMSettingsViewController *)settingsViewController
{
    return [TyphoonDefinition withClass:[BMSettingsViewController class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(URLCache) with:[self.managersAssembly URLCache]];
        [definition injectProperty:@selector(fileManager) with:[self.managersAssembly fileManager]];
        [definition injectProperty:@selector(prePermissionManager) with:[self.managersAssembly prePermissionManager]];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMTwitterTimelineViewController *)twitterTimelineViewControllerWithDataSource:(id<TWTRTimelineDataSource>)dataSource
{
    return [TyphoonDefinition withClass:[BMTwitterTimelineViewController class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(initWithDataSource:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:dataSource];
        }];
    }];
}

- (BMTwitterTimelinePageViewController *)twitterTimelinePageViewControllerWithDataSources:(NSArray *)dataSources titles:(NSArray *)titles
{
    return [TyphoonDefinition withClass:[BMTwitterTimelinePageViewController class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(initWithDataSources:titles:viewControllersAssembly:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:dataSources];
            [initializer injectParameterWith:titles];
            [initializer injectParameterWith:self];
        }];
        [definition injectProperty:@selector(notificationCenter) with:[self.managersAssembly notificationCenter]];
        [definition injectProperty:@selector(tweetPresenter) with:[self.presentersAssembly tweetPresenter]];
    }];
}

- (BMTwitterReportViewController *)twitterReportViewController
{
    return [TyphoonDefinition withClass:[BMTwitterReportViewController class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(managersAssembly) with:self.managersAssembly];
        [definition injectProperty:@selector(tweetPresenter) with:[self.presentersAssembly tweetPresenter]];
    }];
}

- (BMAirQualityViewController *)airQualityViewController
{
    return [TyphoonDefinition withClass:[BMAirQualityViewController class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(airQualityService) with:[self.servicesAssembly airQualityService]];
        [definition injectProperty:@selector(managersAssembly) with:self.managersAssembly];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMShareViewController *)shareViewController
{
    return [TyphoonDefinition withClass:[BMShareViewController class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(application) with:[self.applicationAssembly application]];
        [definition injectProperty:@selector(viewControllersAssembly) with:self];
        [definition injectProperty:@selector(managersAssembly) with:self.managersAssembly];
        [definition injectProperty:@selector(pointsService) with:[self.servicesAssembly pointsService]];
        [definition injectProperty:@selector(pointsStorage) with:[self.storagesAssembly pointsStorage]];
        definition.scope = TyphoonScopeSingleton;
    }];
}

@end
