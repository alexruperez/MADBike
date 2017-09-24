//
//  BMServicesAssembly.h
//  BiciMAD
//
//  Created by alexruperez on 13/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import Typhoon;

#import "BMServiceTask.h"

@class BMManagersAssembly;
@class BMViewControllersAssembly;
@class BMStoragesAssembly;

@class BMStationsService;
@class BMPlacesService;
@class BMAirQualityService;
@class BMPointsService;

@class BMWeatherDownloader;
@class CLLocation;
@class TWTRAPIClient;

@class BMPlacesTask;

@protocol TWTRTimelineDataSource;

@interface BMServicesAssembly : TyphoonAssembly

@property (nonatomic, strong, readonly) BMManagersAssembly *managersAssembly;
@property (nonatomic, strong, readonly) BMViewControllersAssembly *viewControllersAssembly;
@property (nonatomic, strong, readonly) BMStoragesAssembly *storagesAssembly;

- (TWTRAPIClient *)twitterAPIClient;

- (id<TWTRTimelineDataSource>)tipsTimelineDataSource;

- (id<TWTRTimelineDataSource>)newsTimelineDataSource;

- (id<TWTRTimelineDataSource>)greenTipsTimelineDataSource;

- (BMStationsService *)stationsService;

- (BMPlacesService *)placesService;

- (BMAirQualityService *)airQualityService;

- (BMPointsService *)pointsService;

- (BMWeatherDownloader *)weatherDownloader;

- (BMServiceTask *)allStationsEMTTask;

- (BMServiceTask *)singleStationEMTTaskWithStationId:(NSString *)stationId;

- (BMServiceTask *)incidencesEMTTaskWithPhonePreferred:(NSNumber *)phonePreferred phone:(NSString *)phone email:(NSString *)email lastName:(NSString *)lastName subject:(NSString *)subject text:(NSString *)text;

- (BMPlacesTask *)placesTaskWithInput:(NSString *)input sensor:(NSNumber *)sensor;

- (BMServiceTask *)airQualityTaskWithOnlyCurrentValues:(NSNumber *)currentValues onlyAverage:(NSNumber *)onlyAverage discardAverage:(NSNumber *)discardAverage;

- (BMServiceTask *)allPartnersTask;

@end
