//
//  BMAnnotationsDetailViewController.h
//  BiciMAD
//
//  Created by alexruperez on 21/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMBaseViewController.h"

@class BMManagersAssembly;
@class BMStation;

@interface BMAnnotationsDetailViewController : BMBaseViewController

@property (nonatomic, strong) BMManagersAssembly *managersAssembly;

@property (nonatomic, copy) NSArray *annotations;

@property (nonatomic, copy) NSString *titleString;

@property (nonatomic, assign) BOOL shouldHighlightContent;

@end
