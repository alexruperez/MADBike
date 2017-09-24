//
//  BMStationDetailTableViewCell.m
//  BiciMAD
//
//  Created by alexruperez on 23/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMStationDetailTableViewCell.h"

@import Charts;
@import DOFavoriteButton;

#import "BMStation.h"

@interface BMStationDetailTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet PieChartView *pieChartView;
@property (weak, nonatomic) IBOutlet DOFavoriteButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *openInMapsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UIToolbar *buttonToolbar;


@property (strong, nonatomic) NSNumberFormatter *numberFormatter;

@end

@implementation BMStationDetailTableViewCell

@synthesize delegate;

- (instancetype)init
{
    self = self.bm_loadFromNib;
    return self;
}

- (NSNumberFormatter *)numberFormatter
{
    if (!_numberFormatter)
    {
        _numberFormatter = NSNumberFormatter.new;
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    }
    
    return _numberFormatter;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.pieChartView.rotationWithTwoFingers = YES;
    self.pieChartView.descriptionText = @"";
    self.pieChartView.transparentCircleColor = nil;
    self.pieChartView.holeColor = nil;
    
    self.pieChartView.legend.font = [UIFont systemFontOfSize:12.f];
    self.pieChartView.legend.position = ChartLegendPositionPiechartCenter;
    self.pieChartView.legend.form = ChartLegendFormCircle;
    
    [self configurePieChartView];
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:19.f];

    self.buttonToolbar.translucent = YES;
    [self.buttonToolbar setBackgroundImage:UIImage.new forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.buttonToolbar setShadowImage:UIImage.new forToolbarPosition:UIBarPositionAny];

    self.shareButton.accessibilityLabel = NSLocalizedString(@"Share station", @"Share station");
    self.openInMapsButton.accessibilityLabel = NSLocalizedString(@"Open in maps", @"Open in maps");
    self.favoriteButton.accessibilityLabel = NSLocalizedString(@"Favorite", @"Favorite");
}

- (void)setShouldHighlightContent:(BOOL)shouldHighlightContent
{
    _shouldHighlightContent = shouldHighlightContent;
    
    UIColor *titleColor = _shouldHighlightContent ? UIColor.whiteColor : UIColor.blackColor;
    UIColor *subtitleColor = _shouldHighlightContent ? UIColor.lightTextColor : UIColor.grayColor;
    
    self.pieChartView.legend.textColor = titleColor;
    self.titleLabel.textColor = titleColor;
    self.subtitleLabel.textColor = subtitleColor;
    self.buttonToolbar.tintColor = subtitleColor;
    self.openInMapsButton.tintColor = subtitleColor;
    self.shareButton.tintColor = subtitleColor;
    self.favoriteButton.imageColorOff = subtitleColor;
}

- (void)setAnnotation:(BMStation *)annotation
{
    _annotation = annotation;
    
    self.titleLabel.text = annotation.name;
    
    self.subtitleLabel.text = annotation.subtitle;
    
    self.favoriteButton.selected = annotation.favorite;
    self.favoriteButton.accessibilityValue = self.favoriteButton.selected ? NSLocalizedString(@"Yes", @"Yes") : NSLocalizedString(@"No", @"No");
    
    [self configurePieChartView];
}

- (void)configurePieChartView
{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        NSMutableArray *yValues = NSMutableArray.new;
        NSMutableArray *colors = NSMutableArray.new;
        
        if (self.annotation.freeStands > 0)
        {
            [yValues addObject:[[PieChartDataEntry alloc] initWithValue:(double)self.annotation.freeStands label:NSLocalizedString(@"Free", @"Free")]];
            [colors addObject:UIColor.bm_red];
        }
        if (self.annotation.bikesHooked > 0)
        {
            [yValues addObject:[[PieChartDataEntry alloc] initWithValue:(double)self.annotation.bikesHooked - (double)self.annotation.bikesReserved label:NSLocalizedString(@"Bikes", @"Bikes")]];
            [colors addObject:UIColor.bm_green];
        }
        if (self.annotation.bikesReserved > 0)
        {
            [yValues addObject:[[PieChartDataEntry alloc] initWithValue:(double)self.annotation.bikesReserved label:NSLocalizedString(@"Reserved", @"Reserved")]];
            [colors addObject:UIColor.bm_blue];
        }
        if (self.annotation.unavailableStands > 0)
        {
            [yValues addObject:[[PieChartDataEntry alloc] initWithValue:(double)self.annotation.unavailableStands label:NSLocalizedString(@"Unavailable", @"Unavailable")]];
            [colors addObject:UIColor.bm_gray];
        }
        
        PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithValues:yValues.copy label:nil];
        
        dataSet.colors = colors.copy;

        dispatch_async(dispatch_get_main_queue(), ^{
            PieChartData *data = [[PieChartData alloc] initWithDataSet:dataSet];

            [data setValueFormatter:[[ChartDefaultValueFormatter alloc] initWithFormatter:self.numberFormatter]];
            [data setValueFont:[UIFont boldSystemFontOfSize:10.f]];
            [data setValueTextColor:UIColor.blackColor];

            self.pieChartView.data = data;
        });
    });
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

- (IBAction)share:(id)sender
{
    if (self.delegate != nil)
    {
        [self.delegate annotationDetailTableViewCell:self share:self.annotation sender:sender];
    }
}

@end
