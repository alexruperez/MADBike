//
//  BMPromotionDetailTableViewCell.m
//  BiciMAD
//
//  Created by alexruperez on 5/5/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMPromotionDetailTableViewCell.h"

@import DOFavoriteButton;

#import "BMPromotion.h"

@interface BMPromotionDetailTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet DOFavoriteButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIImageView *promotionImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation BMPromotionDetailTableViewCell

@synthesize delegate;

- (instancetype)init
{
    self = self.bm_loadFromNib;
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:19.f];
    
    self.favoriteButton.accessibilityLabel = NSLocalizedString(@"Favorite", @"Favorite");
    
    self.promotionImageView.layer.shadowOffset = CGSizeMake(0.f, 0.f);
    self.promotionImageView.layer.shadowRadius = 0.f;
    self.promotionImageView.layer.shadowOpacity = 0.f;
}

- (void)setShouldHighlightContent:(BOOL)shouldHighlightContent
{
    _shouldHighlightContent = shouldHighlightContent;
    
    UIColor *titleColor = _shouldHighlightContent ? UIColor.whiteColor : UIColor.blackColor;
    UIColor *subtitleColor = _shouldHighlightContent ? UIColor.lightTextColor : UIColor.lightGrayColor;
    
    self.titleLabel.textColor = titleColor;
    self.subtitleLabel.textColor = subtitleColor;
    self.favoriteButton.imageColorOff = subtitleColor;
    self.descriptionLabel.textColor = titleColor;
    self.promotionImageView.layer.shadowColor = titleColor.CGColor;
}

- (void)setAnnotation:(BMPromotion *)annotation
{
    _annotation = annotation;
    
    self.titleLabel.text = annotation.title;
    
    self.subtitleLabel.text = annotation.partner.name;
    
    self.favoriteButton.selected = annotation.favorite;
    self.favoriteButton.accessibilityValue = self.favoriteButton.selected ? NSLocalizedString(@"Yes", @"Yes") : NSLocalizedString(@"No", @"No");
    
    self.promotionImageView.image = annotation.image;
    
    NSMutableAttributedString *attributedText = annotation.attributedDescription.mutableCopy;
    [attributedText addAttribute:NSForegroundColorAttributeName value:self.descriptionLabel.textColor range:NSMakeRange(0, attributedText.length)];
    NSShadow *shadow = NSShadow.new;
    shadow.shadowColor = self.descriptionLabel.shadowColor;
    shadow.shadowOffset = self.descriptionLabel.shadowOffset;
    [attributedText addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, attributedText.length)];
    self.descriptionLabel.attributedText = attributedText.copy;
}

- (IBAction)switchFavorite:(id)sender
{
    if (self.favoriteButton.selected)
    {
        [self.favoriteButton deselect];
        self.favoriteButton.accessibilityValue = NSLocalizedString(@"No", @"No");
        self.annotation.favorite = NO;
    }
    else
    {
        [self.favoriteButton select];
        self.favoriteButton.accessibilityValue = NSLocalizedString(@"Yes", @"Yes");
        self.annotation.favorite = YES;
    }
    
    if (self.delegate != nil)
    {
        [self.delegate annotationDetailTableViewCell:self hasModified:self.annotation sender:sender];
    }
}

@end
