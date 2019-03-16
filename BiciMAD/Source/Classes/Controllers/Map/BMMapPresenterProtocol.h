//
//  BMMapPresenterProtocol.h
//  BiciMAD
//
//  Created by alexruperez on 3/3/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import CoreLocation;

@class BMManagersAssembly;

@protocol BMMapPresenterDelegate <NSObject>

- (void)presentAnnotationsDetail:(NSArray *)annotations titleString:(NSString *)titleString animated:(BOOL)animated;

- (void)didUpdateUserLocation:(CLLocation *)location;

- (void)didFinishRenderingMap:(BOOL)fullyRendered;

- (void)locationPermissionsNeeded:(void (^)(BOOL success))completionHandler;

@end

@protocol BMMapPresenter <NSObject>

@property (nonatomic, strong) BMManagersAssembly *managersAssembly;
@property (nonatomic, weak) id<BMMapPresenterDelegate> delegate;
@property (nonatomic, weak) UIView *mapView;
@property (nonatomic, copy, readonly) NSSet *annotations;
@property (nonatomic, copy, readonly) NSSet *selectedAnnotations;
@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) CLLocationCoordinate2D centerCoordinate;

- (instancetype)initWithDelegate:(id<BMMapPresenterDelegate>)delegate mapView:(UIView *)mapView;

- (void)mapViewLoaded;
- (void)updateMapOptions;
- (void)showUserLocation:(id)sender;
- (void)showCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;

- (void)setVisibleMapAnnotations:(id)annotations animated:(BOOL)animated;
- (void)setVisibleCircularRegion:(CLCircularRegion *)circularRegion animated:(BOOL)animated;

- (void)addAnnotations:(NSArray *)annotations withCompletionHandler:(void (^)(void))completionHandler;
- (void)clearAllAnnotations:(void (^)(void))completionHandler;
- (void)selectAnnotation:(id)annotation andZoomToRegionWithLatitudinalMeters:(CLLocationDistance)latitudinalMeters longitudinalMeters:(CLLocationDistance)longitudinalMeters;
- (id)uniqueLocationAnnotation:(id)annotation;

@end
