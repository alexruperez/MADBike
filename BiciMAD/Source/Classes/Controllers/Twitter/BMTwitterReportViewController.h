//
//  BMTwitterReportViewController.h
//  BiciMAD
//
//  Created by alexruperez on 4/8/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import UIKit;

@class BMManagersAssembly;
@class TweetPresenter;

@interface BMTwitterReportViewController : UIImagePickerController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) BMManagersAssembly *managersAssembly;
@property (nonatomic, strong) TweetPresenter *tweetPresenter;

@end
