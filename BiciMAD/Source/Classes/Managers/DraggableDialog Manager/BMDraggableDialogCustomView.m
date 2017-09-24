//
//  BMDraggableDialogCustomView.m
//  BiciMAD
//
//  Created by alexruperez on 23/8/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMDraggableDialogCustomView.h"

@interface BMDraggableDialogCustomView ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation BMDraggableDialogCustomView

- (instancetype)init
{
    self = self.bm_loadFromNib;
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.photoImageView.layer.cornerRadius = self.photoImageView.frame.size.width / 2.f;
}

- (void)setPhoto:(UIImage *)photo
{
    _photo = photo;
    self.photoImageView.image = photo;
    self.photoImageView.layer.masksToBounds = YES;
}

- (void)setTitleText:(NSString *)titleText
{
    _titleText = titleText;
    _titleLabel.text = titleText;
}

- (void)setMessageText:(NSString *)messageText
{
    _messageText = messageText;
    _messageLabel.text = messageText;
}

@end
