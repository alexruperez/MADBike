//
//  BMStationDetailCalloutAccessoryView.m
//  BiciMAD
//
//  Created by alexruperez on 15/11/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMStationDetailCalloutAccessoryView.h"

#import "BMStation.h"

@interface BMStationDetailCalloutAccessoryView ()

@property (weak, nonatomic) IBOutlet UILabel *freeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bikesTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *unavailableTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *freeLabel;
@property (weak, nonatomic) IBOutlet UILabel *bikesLabel;
@property (weak, nonatomic) IBOutlet UILabel *unavailableLabel;
@property (weak, nonatomic) IBOutlet UILabel *reservedLabel;

@end

@implementation BMStationDetailCalloutAccessoryView

- (instancetype)init
{
    self = self.bm_loadFromNib;
    
    self.userInteractionEnabled = NO;
    
    return self;
}

- (void)setStation:(BMStation *)station
{
    _station = station;
    
    self.freeTitleLabel.text = NSLocalizedString(@"Free", @"Free");
    
    self.bikesTitleLabel.text = NSLocalizedString(@"Bikes", @"Bikes");
    
    self.unavailableTitleLabel.text = NSLocalizedString(@"Unavailable", @"Unavailable");
    
    self.freeLabel.text = [NSString stringWithFormat:@"%zd", station.freeStands];
    
    self.bikesLabel.text = [NSString stringWithFormat:@"%zd", station.bikesHooked];
    
    self.unavailableLabel.text = [NSString stringWithFormat:@"%zd", station.unavailableStands];

    self.reservedLabel.text = [NSString stringWithFormat:@"%zd", station.bikesReserved];
    
    self.freeTitleLabel.textColor = self.freeLabel.textColor = UIColor.bm_red;
    
    self.bikesTitleLabel.textColor = self.bikesLabel.textColor = UIColor.bm_green;
    
    self.unavailableTitleLabel.textColor = self.unavailableLabel.textColor = UIColor.lightGrayColor;
    
    [self layoutSubviews];
}

@end
