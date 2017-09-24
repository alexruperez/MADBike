//
//  BMGoogleMapsPresenter.h
//  BiciMAD
//
//  Created by alexruperez on 3/3/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import GoogleMaps;

#import "BMMapPresenterProtocol.h"

@interface BMGoogleMapsPresenter : NSObject <BMMapPresenter>

@property (nonatomic, strong) BMManagersAssembly *managersAssembly;
@property (nonatomic, weak) id<BMMapPresenterDelegate> delegate;
@property (nonatomic, weak) GMSMapView *mapView;
@property (nonatomic, copy, readonly) NSSet *annotations;
@property (nonatomic, copy, readonly) NSSet *selectedAnnotations;
@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) CLLocationCoordinate2D centerCoordinate;

@end
