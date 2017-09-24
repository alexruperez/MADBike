//
//  BMAirQualityViewController.h
//  BiciMAD
//
//  Created by alexruperez on 5/6/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMBaseViewController.h"

@class BMAirQualityService;
@class BMManagersAssembly;

@interface BMAirQualityViewController : BMBaseViewController

@property (nonatomic, strong) BMAirQualityService *airQualityService;
@property (nonatomic, strong) BMManagersAssembly *managersAssembly;

@end
