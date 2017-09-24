//
//  BMViewControllersAssembly.h
//  BiciMAD
//
//  Created by alexruperez on 19/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import UIKit;
@import Typhoon;

@class BMApplicationAssembly;
@class BMServicesAssembly;
@class BMManagersAssembly;
@class BMPresentersAssembly;
@class BMStoragesAssembly;
@class BMRootViewController;
@class BMTwitterTimelinePageViewController;
@class BMStation;
@class BMStationsViewController;
@class BMAnnotationsDetailViewController;
@class BMPlacesTableViewController;
@class BMWeatherViewController;
@class BMSettingsViewController;
@class BMTwitterTimelineViewController;
@class BMTwitterReportViewController;
@class BMAirQualityViewController;
@class BMShareViewController;

@protocol TWTRTimelineDataSource;
@protocol BMPlacesTableViewControllerDelegate;

@interface BMViewControllersAssembly : TyphoonAssembly

@property (nonatomic, strong, readonly) BMApplicationAssembly *applicationAssembly;
@property (nonatomic, strong, readonly) BMServicesAssembly *servicesAssembly;
@property (nonatomic, strong, readonly) BMManagersAssembly *managersAssembly;
@property (nonatomic, strong, readonly) BMPresentersAssembly *presentersAssembly;
@property (nonatomic, strong, readonly) BMStoragesAssembly *storagesAssembly;

- (BMRootViewController *)rootViewController;

- (BMStationsViewController *)stationsViewController;

- (BMAnnotationsDetailViewController *)annotationsDetailViewControllerWithAnnotations:(NSArray *)annotations titleString:(NSString *)titleString;

- (BMPlacesTableViewController *)placesTableViewControllerWithDelegate:(id<BMPlacesTableViewControllerDelegate>)delegate;

- (UIViewController *)safariViewControllerWithURLString:(NSString *)URLString onLoad:(void (^)(BOOL didLoad))load onFinish:(void (^)(void))finish;

- (BMWeatherViewController *)weatherViewController;

- (BMSettingsViewController *)settingsViewController;

- (BMTwitterTimelineViewController *)twitterTimelineViewControllerWithDataSource:(id<TWTRTimelineDataSource>)dataSource;

- (BMTwitterTimelinePageViewController *)twitterTimelinePageViewControllerWithDataSources:(NSArray *)dataSources titles:(NSArray *)titles;

- (BMTwitterReportViewController *)twitterReportViewController;

- (BMAirQualityViewController *)airQualityViewController;

- (BMShareViewController *)shareViewController;

@end
