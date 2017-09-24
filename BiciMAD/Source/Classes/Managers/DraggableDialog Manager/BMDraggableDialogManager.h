//
//  BMDraggableDialogManager.h
//  BiciMAD
//
//  Created by alexruperez on 12/8/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import Foundation;

typedef void (^BMDraggableDialogCompletionHandler)(NSUInteger buttonIndex);

@interface BMDraggableDialogManager : NSObject

@property (nonatomic, strong) UIWindow *window;

- (void)presentCustomView:(UIView *)customView inView:(UIView *)view completionHandler:(BMDraggableDialogCompletionHandler)completionHandler;

- (void)presentCustomView:(UIView *)customView firstButton:(NSString *)firstButton cancelButton:(NSString *)cancelButton inView:(UIView *)view completionHandler:(BMDraggableDialogCompletionHandler)completionHandler;

- (void)presentDialogWithPhoto:(UIImage *)photo title:(NSString *)title message:(NSString *)message inView:(UIView *)view completionHandler:(BMDraggableDialogCompletionHandler)completionHandler;

@end
