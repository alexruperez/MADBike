//
//  BMApplicationAssembly.h
//  BiciMAD
//
//  Created by alexruperez on 8/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import UIKit;
@import Typhoon;

@class BMServicesAssembly;
@class BMManagersAssembly;
@class BMViewControllersAssembly;
@class iRate;
@class BMAppDelegate;

@interface BMApplicationAssembly : TyphoonAssembly

@property (nonatomic, strong, readonly) BMServicesAssembly *servicesAssembly;
@property (nonatomic, strong, readonly) BMManagersAssembly *managersAssembly;
@property (nonatomic, strong, readonly) BMViewControllersAssembly *viewControllersAssembly;

- (BMAppDelegate *)appDelegate;

- (UIApplication *)application;

- (UIWindow *)window;

@end
