//
//  BMAppDelegate.h
//  BiciMAD
//
//  Created by alexruperez on 7/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import UIKit;

@class BMManagersAssembly;
@class BMRootViewController;
@class iRate;
@class DDASLLogger;
@class DDTTYLogger;
@class DDCLSLogger;
@class AFNetworkActivityLogger;

@interface BMAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIApplication *application;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) BMRootViewController *rootViewController;
@property (nonatomic, strong) BMManagersAssembly *managersAssembly;
@property (nonatomic, strong) iRate *iRate;
@property (nonatomic, strong) DDASLLogger *aslLogger;
@property (nonatomic, strong) DDTTYLogger *ttyLogger;
@property (nonatomic, strong) DDCLSLogger *clsLogger;
@property (nonatomic, strong) AFNetworkActivityLogger *networkActivityLogger;

@end
