//
//  BMSearchPresenterProtocol.h
//  BiciMAD
//
//  Created by alexruperez on 4/3/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import CoreLocation;

@class BMViewControllersAssembly;
@class BMPlacesService;
@class BMStationsService;

@protocol BMSearchPresenterDelegate <NSObject>

@property (nonatomic, readonly) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic, strong, readonly) CLLocation *location;

- (void)didSearch:(NSArray *)results addressString:(NSString *)addressString placemark:(CLPlacemark *)placemark;
- (void)handleError:(NSError *)error completion:(void (^)(void))completion;

@end

@protocol BMSearchPresenter <NSObject>

@property (nonatomic, strong) BMViewControllersAssembly *viewControllersAssembly;
@property (nonatomic, strong) BMPlacesService *placesService;
@property (nonatomic, strong) BMStationsService *stationsService;
@property (nonatomic, weak) UIViewController<BMSearchPresenterDelegate> *delegate;

- (instancetype)initWithDelegate:(UIViewController<BMSearchPresenterDelegate> *)delegate;

- (void)loadViewIfNeeded;
- (void)showSearch:(id)sender;

- (void)searchPlacesWithInput:(NSString *)input;

@end
