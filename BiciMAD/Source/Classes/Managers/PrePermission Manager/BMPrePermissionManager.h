//
//  BMPrePermissionManager.h
//  BiciMAD
//
//  Created by alexruperez on 12/8/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import CoreLocation;

#import "BMDraggableDialogManager.h"

typedef void (^BMPrePermissionCompletionHandler)(BOOL success);

@interface BMPrePermissionManager : NSObject

@property (nonatomic, strong) BMDraggableDialogManager *draggableDialogManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UIApplication *application;

+ (void)openSettings:(UIApplication *)application completionHandler:(BMPrePermissionCompletionHandler)completionHandler;

- (void)location:(BMPrePermissionCompletionHandler)completionHandler;

- (void)camera:(BMPrePermissionCompletionHandler)completionHandler;

- (void)twitterWithViewController:(nullable UIViewController *)viewController completion:(BMPrePermissionCompletionHandler)completionHandler;

- (void)push:(BMPrePermissionCompletionHandler)completionHandler;

@end
