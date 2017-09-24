//
//  BMPresentersAssembly.m
//  BiciMAD
//
//  Created by alexruperez on 3/3/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMPresentersAssembly.h"

#import "BMManagersAssembly.h"
#import "BMServicesAssembly.h"

#import "BMMapKitPresenter.h"
#import "BMGoogleMapsPresenter.h"
#import "BMPlacesSearchPresenter.h"
#import "MADBike-Swift.h"

@implementation BMPresentersAssembly

- (id<BMMapPresenter>)mapKitPresenterWithDelegate:(id<BMMapPresenterDelegate>)delegate mapView:(UIView *)mapView
{
    return [TyphoonDefinition withClass:[BMMapKitPresenter class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(initWithDelegate:mapView:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:delegate];
            [initializer injectParameterWith:mapView];
        }];
        [definition injectProperty:@selector(managersAssembly) with:self.managersAssembly];
    }];
}

- (id<BMMapPresenter>)googleMapsPresenterWithDelegate:(id<BMMapPresenterDelegate>)delegate mapView:(UIView *)mapView
{
    return [TyphoonDefinition withClass:[BMGoogleMapsPresenter class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(initWithDelegate:mapView:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:delegate];
            [initializer injectParameterWith:mapView];
        }];
        [definition injectProperty:@selector(managersAssembly) with:self.managersAssembly];
    }];
}

- (id<BMSearchPresenter>)placesSearchPresenterWithDelegate:(UIViewController<BMSearchPresenterDelegate> *)delegate
{
    return [TyphoonDefinition withClass:[BMPlacesSearchPresenter class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(initWithDelegate:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:delegate];
        }];
        [definition injectProperty:@selector(viewControllersAssembly) with:self.viewControllersAssembly];
        [definition injectProperty:@selector(managersAssembly) with:self.managersAssembly];
        [definition injectProperty:@selector(placesService) with:[self.servicesAssembly placesService]];
        [definition injectProperty:@selector(stationsService) with:[self.servicesAssembly stationsService]];
    }];
}

- (TweetPresenter *)tweetPresenter
{
    return [TyphoonDefinition withClass:[TweetPresenter class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(initWithClient:draggableDialogManager:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:[self.servicesAssembly twitterAPIClient]];
            [initializer injectParameterWith:[self.managersAssembly draggableDialogManager]];
        }];
        definition.scope = TyphoonScopeLazySingleton;
    }];
}

@end
