//
//  BMWeatherViewController.h
//  BiciMAD
//
//  Created by alexruperez on 19/11/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import SmileWeather;

@class BMServicesAssembly;
@class BMManagersAssembly;

@interface BMWeatherViewController : SmileWeatherDemoVC

@property (nonatomic, strong) BMServicesAssembly *servicesAssembly;
@property (nonatomic, strong) BMManagersAssembly *managersAssembly;
@property (nonatomic, strong) CLPlacemark *placemark;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) BOOL shouldHighlightContent;

- (void)setSuccessBlock:(void (^)(SmileWeatherData *data))successBlock;
- (void)setFailureBlock:(void (^)(NSError *error))failureBlock;
- (void)setTempUnitsBlock:(void (^)(SmileWeatherData *data, BOOL fahrenheit))tempUnitsBlock;

@end
