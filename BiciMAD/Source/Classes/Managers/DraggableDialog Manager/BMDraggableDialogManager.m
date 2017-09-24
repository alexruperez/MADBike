//
//  BMDraggableDialogManager.m
//  BiciMAD
//
//  Created by alexruperez on 12/8/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMDraggableDialogManager.h"

@import SFDraggableDialogView;

#import "BMDraggableDialogCustomView.h"

static NSString * const kSFDraggableDialogViewBundleIdentifier = @"org.cocoapods.SFDraggableDialogView";

@interface BMDraggableDialogManager () <SFDraggableDialogViewDelegate>

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, assign) NSUInteger lastButtonIndex;
@property (nonatomic, copy) BMDraggableDialogCompletionHandler completionHandler;

@end

@implementation BMDraggableDialogManager

- (NSBundle *)bundle
{
    if (!_bundle)
    {
        _bundle = [NSBundle bundleWithIdentifier:kSFDraggableDialogViewBundleIdentifier];
    }

    return _bundle;
}

- (void)presentCustomView:(UIView *)customView inView:(UIView *)view completionHandler:(BMDraggableDialogCompletionHandler)completionHandler
{
    [self presentCustomView:customView firstButton:NSLocalizedString(@"Ok", @"Ok") cancelButton:NSLocalizedString(@"Cancel", @"Cancel") inView:view completionHandler:completionHandler];
}

- (void)presentCustomView:(UIView *)customView firstButton:(NSString *)firstButton cancelButton:(NSString *)cancelButton inView:(UIView *)view completionHandler:(BMDraggableDialogCompletionHandler)completionHandler
{
    [self presentDialogWithPhoto:nil title:nil message:nil firstButton:firstButton secondButton:nil cancelButton:cancelButton customView:customView inView:view completionHandler:completionHandler];
}

- (void)presentDialogWithPhoto:(UIImage *)photo title:(NSString *)title message:(NSString *)message inView:(UIView *)view completionHandler:(BMDraggableDialogCompletionHandler)completionHandler
{
    [self presentDialogWithPhoto:photo title:title message:message firstButton:NSLocalizedString(@"Ok", @"Ok") cancelButton:NSLocalizedString(@"Cancel", @"Cancel") inView:view completionHandler:completionHandler];
}

- (void)presentDialogWithPhoto:(UIImage *)photo title:(NSString *)title message:(NSString *)message firstButton:(NSString *)firstButton cancelButton:(NSString *)cancelButton inView:(UIView *)view completionHandler:(BMDraggableDialogCompletionHandler)completionHandler
{
    [self presentDialogWithPhoto:photo title:title message:message firstButton:firstButton secondButton:nil cancelButton:cancelButton customView:nil inView:view completionHandler:completionHandler];
}

- (void)presentDialogWithPhoto:(UIImage *)photo title:(NSString *)title message:(NSString *)message firstButton:(NSString *)firstButton secondButton:(NSString *)secondButton cancelButton:(NSString *)cancelButton customView:(UIView *)customView inView:(UIView *)view completionHandler:(BMDraggableDialogCompletionHandler)completionHandler
{
    __block UIView *blockCustomView = customView;

    @weakify(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self)
        UIView *presentationView = view ? view : self.window;
        SFDraggableDialogView *dialogView = [self.bundle loadNibNamed:NSStringFromClass(SFDraggableDialogView.class) owner:self options:nil].firstObject;

        dialogView.frame = presentationView.bounds;
        dialogView.delegate = self;
        dialogView.contentViewType = SFContentViewTypeCustom;
        dialogView.firstBtnBackgroundColor = dialogView.secondBtnBackgroundColor = UIColor.bm_backgroundColor;
        dialogView.hideCloseButton = YES;
        dialogView.firstBtnText = firstButton;
        dialogView.showSecondBtn = secondButton;
        dialogView.secondBtnText = secondButton;

        if (cancelButton)
        {
            dialogView.cancelArrowText = [[NSMutableAttributedString alloc] initWithString:cancelButton];
        }

        CGFloat buttonMargin = 50.f;

        if (!blockCustomView)
        {
            BMDraggableDialogCustomView *draggableDialogCustomView = BMDraggableDialogCustomView.new;
            draggableDialogCustomView.photo = photo;
            draggableDialogCustomView.titleText = title;
            draggableDialogCustomView.messageText = message;
            blockCustomView = draggableDialogCustomView;
            buttonMargin = 100.f;
        }

        CGSize size = [blockCustomView sizeThatFits:presentationView.bounds.size];
        blockCustomView.frame = CGRectMake(0.f, 0.f, size.width, size.height);
        dialogView.size = CGSizeMake(size.width, size.height + buttonMargin);
        [dialogView.customView addSubview:blockCustomView];
        [dialogView createBlurBackgroundWithImage:presentationView.bm_snapshot tintColor:[UIColor.blackColor colorWithAlphaComponent:0.35f] blurRadius:10.f];
        self.lastButtonIndex = NSNotFound;
        self.completionHandler = completionHandler;
        [presentationView addSubview:dialogView];
    });
}

#pragma mark - SFDraggableDialogViewDelegate

- (void)draggableDialogView:(SFDraggableDialogView *)dialogView didPressFirstButton:(UIButton *)firstButton
{
    self.lastButtonIndex = 0;
    [dialogView dismissWithDrop:YES];
}

- (void)draggableDialogView:(SFDraggableDialogView *)dialogView didPressSecondButton:(UIButton *)secondButton
{
    self.lastButtonIndex = 1;
    [dialogView dismissWithDrop:YES];
}

- (void)draggableDialogViewWillDismiss:(SFDraggableDialogView *)dialogView
{
    if (self.completionHandler)
    {
        self.completionHandler(self.lastButtonIndex);
    }
    self.lastButtonIndex = NSNotFound;
    self.completionHandler = nil;
}

@end
