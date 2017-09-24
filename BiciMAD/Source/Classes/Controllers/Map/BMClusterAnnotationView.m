//
//  BMClusterAnnotationView.m
//  BiciMAD
//
//  Created by alexruperez on 20/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMClusterAnnotationView.h"

@import CCHMapClusterController;

#import "BMStation.h"
#import "BMPlace.h"

@interface BMClusterAnnotationView ()

@property (nonatomic) UILabel *countLabel;

@end

@implementation BMClusterAnnotationView

- (instancetype)init
{
    self = [self initWithAnnotation:nil reuseIdentifier:nil];
    
    return self;
}

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.backgroundColor = UIColor.clearColor;
        self.layer.shadowColor = UIColor.blackColor.CGColor;
        self.layer.shadowOffset = CGSizeMake(0.f, 0.f);
        self.layer.shadowRadius = 0.f;
        self.layer.shadowOpacity = 0.f;
        [self setUpLabel];
    }
    
    return self;
}

- (UIImage *)annotationImage
{
    return self.bm_snapshot;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    if (annotation)
    {
        [self layoutSubviews];
    }
}

- (void)setMapClusterAnnotation:(id<GCluster>)mapClusterAnnotation
{
    _mapClusterAnnotation = mapClusterAnnotation;
    if (mapClusterAnnotation)
    {
        [self layoutSubviews];
    }
}

- (void)setUpLabel
{
    _countLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _countLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.backgroundColor = UIColor.clearColor;
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.adjustsFontSizeToFitWidth = YES;
    _countLabel.minimumScaleFactor = 2.f;
    _countLabel.numberOfLines = 1;
    _countLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    [self addSubview:_countLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CCHMapClusterAnnotation *mapClusterAnnotation = self.annotation;
    id annotation = self.annotation;
    
    if ([mapClusterAnnotation isKindOfClass:CCHMapClusterAnnotation.class] && mapClusterAnnotation.isUniqueLocation)
    {
        annotation = mapClusterAnnotation.annotations.anyObject;
    }
    
    if ([annotation isKindOfClass:BMStation.class])
    {
        switch ([annotation light])
        {
            case BMLightGreen:
                self.image = [UIImage imageNamed:@"ic_marker_green"];
                break;
            case BMLightRed:
                self.image = [UIImage imageNamed:@"ic_marker_red"];
                break;
            case BMLightYellow:
                self.image = [UIImage imageNamed:@"ic_marker_yellow"];
                break;
            default:
                self.image = [UIImage imageNamed:@"ic_marker_gray"];
                break;
        }
        
        self.centerOffset = CGPointMake(0, self.image.size.height * -0.5f);
        CGRect frame = self.bounds;
        frame.origin.y -= 3.f;
        self.countLabel.frame = frame;
        self.countLabel.textColor = UIColor.blackColor;
        self.countLabel.text = [annotation stationNumber];
        self.countLabel.font = [UIFont boldSystemFontOfSize:9.f];
    }
    else if ([annotation isKindOfClass:BMPlace.class])
    {
        self.image = [annotation annotationImage];
        self.centerOffset = CGPointZero;
        self.countLabel.text = nil;
    }
    else
    {
        self.image = [UIImage imageNamed:@"ic_marker_cluster"];
        self.centerOffset = CGPointMake(0, self.image.size.height * -0.5f);
        CGRect frame = self.bounds;
        frame.origin.y -= 4.f;
        self.countLabel.frame = frame;
        self.countLabel.textColor = UIColor.whiteColor;
        
        NSUInteger count = 0;
        
        if (mapClusterAnnotation)
        {
            count = mapClusterAnnotation.annotations.count;
        }
        else if (self.mapClusterAnnotation)
        {
            count = self.mapClusterAnnotation.items.count;
        }
        
        self.countLabel.text = [NSString stringWithFormat:@"%ld+", (unsigned long)count];
        self.countLabel.font = [UIFont boldSystemFontOfSize:12.f];
    }
}

@end
