//
//  BMStationDetailMarkerInfoContentsView.m
//  BiciMAD
//
//  Created by alexruperez on 8/3/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMStationDetailMarkerInfoContentsView.h"

#import "BMStationDetailCalloutAccessoryView.h"
#import "BMStation.h"

@interface BMStationDetailMarkerInfoContentsView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIView *stationDetailContainer;
@property (strong, nonatomic) BMStationDetailCalloutAccessoryView *stationDetailCalloutAccessoryView;

@end

@implementation BMStationDetailMarkerInfoContentsView

- (instancetype)init
{
    self = self.bm_loadFromNib;
    
    self.userInteractionEnabled = NO;
    
    self.stationDetailCalloutAccessoryView = BMStationDetailCalloutAccessoryView.new;
    
    [self.stationDetailContainer addSubview:self.stationDetailCalloutAccessoryView];
    
    return self;
}

- (void)setStation:(BMStation *)station
{
    _station = station;
    
    self.stationDetailCalloutAccessoryView.station = station;
    self.titleLabel.text = station.title;
    self.subtitleLabel.text = station.subtitle;
    [self layoutSubviews];
}

@end
