//
//  BMStationsViewController.h
//  BiciMAD
//
//  Created by alexruperez on 20/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMBaseViewController.h"

@class BMViewControllersAssembly;
@class BMApplicationAssembly;
@class BMManagersAssembly;
@class BMPresentersAssembly;
@class BMStationsService;
@class BMPlacesService;
@class BMPointsService;
@class BMPointsStorage;

@interface BMStationsViewController : BMBaseViewController

@property (nonatomic, strong) BMViewControllersAssembly *viewControllersAssembly;
@property (nonatomic, strong) BMApplicationAssembly *applicationAssembly;
@property (nonatomic, strong) BMManagersAssembly *managersAssembly;
@property (nonatomic, strong) BMPresentersAssembly *presentersAssembly;
@property (nonatomic, strong) BMPointsStorage *pointsStorage;
@property (nonatomic, strong) BMStationsService *stationsService;
@property (nonatomic, strong) BMPlacesService *placesService;
@property (nonatomic, strong) BMPointsService *pointsService;

@end
