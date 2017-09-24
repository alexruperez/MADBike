//
//  BMMapKitPresenter.h
//  BiciMAD
//
//  Created by alexruperez on 3/3/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import MapKit;

#import "BMMapPresenterProtocol.h"

@interface BMMapKitPresenter : NSObject <BMMapPresenter>

@property (nonatomic, strong) BMManagersAssembly *managersAssembly;
@property (nonatomic, weak) id<BMMapPresenterDelegate> delegate;
@property (nonatomic, weak) MKMapView *mapView;
@property (nonatomic, copy, readonly) NSSet *annotations;
@property (nonatomic, copy, readonly) NSSet *selectedAnnotations;
@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) CLLocationCoordinate2D centerCoordinate;

@end
