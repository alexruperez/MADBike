//
//  BMShareViewController.h
//  BiciMAD
//
//  Created by alexruperez on 14/3/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMBaseViewController.h"

@import Branch;

@class BMViewControllersAssembly;
@class BMManagersAssembly;
@class BMPointsService;
@class BMPointsStorage;

@interface BMShareViewController : BMBaseViewController <BranchDeepLinkingController>

@property (nonatomic, strong) BMViewControllersAssembly *viewControllersAssembly;
@property (nonatomic, strong) BMManagersAssembly *managersAssembly;
@property (nonatomic, strong) BMPointsService *pointsService;
@property (nonatomic, strong) BMPointsStorage *pointsStorage;
@property (nonatomic, strong) UIApplication *application;

@end
