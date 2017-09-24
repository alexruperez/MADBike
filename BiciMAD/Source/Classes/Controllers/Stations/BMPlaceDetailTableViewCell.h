//
//  BMPlaceDetailTableViewCell.h
//  BiciMAD
//
//  Created by alexruperez on 20/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMAnnotationDetailTableViewCellProtocol.h"

@class BMPlace;

@interface BMPlaceDetailTableViewCell : UITableViewCell <BMAnnotationDetailTableViewCell>

@property (nonatomic, strong) BMPlace *annotation;

@property (nonatomic, assign) BOOL shouldHighlightContent;

@end
