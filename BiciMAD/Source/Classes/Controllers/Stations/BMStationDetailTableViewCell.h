//
//  BMStationDetailTableViewCell.h
//  BiciMAD
//
//  Created by alexruperez on 23/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMAnnotationDetailTableViewCellProtocol.h"

@class BMStation;

@interface BMStationDetailTableViewCell : UITableViewCell <BMAnnotationDetailTableViewCell>

@property (nonatomic, strong) BMStation *annotation;

@property (nonatomic, assign) BOOL shouldHighlightContent;

@end
