//
//  BMPresentersAssembly.h
//  BiciMAD
//
//  Created by alexruperez on 3/3/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import Typhoon;

@class BMManagersAssembly;
@class BMViewControllersAssembly;
@class BMServicesAssembly;
@class TweetPresenter;

@protocol BMMapPresenter;
@protocol BMMapPresenterDelegate;
@protocol BMSearchPresenter;
@protocol BMSearchPresenterDelegate;

@interface BMPresentersAssembly : TyphoonAssembly

@property (nonatomic, strong, readonly) BMManagersAssembly *managersAssembly;
@property (nonatomic, strong, readonly) BMViewControllersAssembly *viewControllersAssembly;
@property (nonatomic, strong, readonly) BMServicesAssembly *servicesAssembly;

- (id<BMMapPresenter>)mapKitPresenterWithDelegate:(id<BMMapPresenterDelegate>)delegate mapView:(UIView *)mapView;

- (id<BMMapPresenter>)googleMapsPresenterWithDelegate:(id<BMMapPresenterDelegate>)delegate mapView:(UIView *)mapView;

- (id<BMSearchPresenter>)placesSearchPresenterWithDelegate:(UIViewController<BMSearchPresenterDelegate> *)delegate;

- (TweetPresenter *)tweetPresenter;

@end
