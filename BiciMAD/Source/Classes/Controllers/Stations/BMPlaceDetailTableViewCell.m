//
//  BMPlaceDetailTableViewCell.m
//  BiciMAD
//
//  Created by alexruperez on 20/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMPlaceDetailTableViewCell.h"

@import DOFavoriteButton;

#import "BMPlace.h"

@interface BMPlaceDetailTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *openInMapsButton;
@property (weak, nonatomic) IBOutlet DOFavoriteButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIImageView *annotationImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation BMPlaceDetailTableViewCell

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
    
    self.openInMapsButton.tintColor = UIColor.bm_tintColor;
    
    self.openInMapsButton.accessibilityLabel = NSLocalizedString(@"Open in maps", @"Open in maps");
    self.favoriteButton.accessibilityLabel = NSLocalizedString(@"Favorite", @"Favorite");
    
    self.annotationImageView.layer.shadowOffset = CGSizeMake(0.f, 0.f);
    self.annotationImageView.layer.shadowRadius = 0.f;
    self.annotationImageView.layer.shadowOpacity = 0.f;
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
    self.annotationImageView.layer.shadowColor = titleColor.CGColor;
}

- (void)setAnnotation:(BMPlace *)annotation
{
    _annotation = annotation;
    
    self.titleLabel.text = annotation.name;
    
    self.subtitleLabel.text = annotation.subtitle;
    
    self.favoriteButton.selected = annotation.favorite;
    self.favoriteButton.accessibilityValue = self.favoriteButton.selected ? NSLocalizedString(@"Yes", @"Yes") : NSLocalizedString(@"No", @"No");
    
    self.annotationImageView.image = annotation.annotationImage;
    
    NSMutableAttributedString *attributedText = annotation.partner.attributedDescription.mutableCopy;
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

- (IBAction)openInMaps:(id)sender
{
    if (self.delegate != nil)
    {
        [self.delegate annotationDetailTableViewCell:self navigateTo:self.annotation sender:sender];
    }
}

@end
