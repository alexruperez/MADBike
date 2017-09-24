//
//  BMPlacesSearchPresenter.h
//  BiciMAD
//
//  Created by alexruperez on 4/3/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import Foundation;

#import "BMSearchPresenterProtocol.h"

@class BMManagersAssembly;

@interface BMPlacesSearchPresenter : NSObject <BMSearchPresenter>

@property (nonatomic, strong) BMViewControllersAssembly *viewControllersAssembly;
@property (nonatomic, strong) BMManagersAssembly *managersAssembly;
@property (nonatomic, strong) BMPlacesService *placesService;
@property (nonatomic, strong) BMStationsService *stationsService;
@property (nonatomic, weak) UIViewController<BMSearchPresenterDelegate> *delegate;

@end
