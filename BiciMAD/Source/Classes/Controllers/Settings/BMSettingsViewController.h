//
//  BMSettingsViewController.h
//  BiciMAD
//
//  Created by alexruperez on 26/1/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import InAppSettingsKit;

@class BMPrePermissionManager;

@interface BMSettingsViewController : IASKAppSettingsViewController

@property (nonatomic, strong) NSURLCache *URLCache;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) BMPrePermissionManager *prePermissionManager;

@end
