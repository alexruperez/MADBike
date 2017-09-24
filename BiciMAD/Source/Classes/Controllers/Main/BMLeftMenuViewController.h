//
//  BMLeftMenuViewController.h
//  BiciMAD
//
//  Created by alexruperez on 4/11/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMBaseViewController.h"

@class BMViewControllersAssembly;
@class BMApplicationAssembly;
@class BMServicesAssembly;
@class BMPrePermissionManager;

@interface BMLeftMenuViewController : BMBaseViewController

@property (nonatomic, strong) BMApplicationAssembly *applicationAssembly;
@property (nonatomic, strong) BMViewControllersAssembly *viewControllersAssembly;
@property (nonatomic, strong) BMServicesAssembly *servicesAssembly;
@property (nonatomic, strong) BMPrePermissionManager *prePermissionManager;
@property (nonatomic, strong) NSNotificationCenter *notificationCenter;

@end
