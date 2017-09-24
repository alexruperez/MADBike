//
//  BMPromotionDetailTableViewCell.h
//  BiciMAD
//
//  Created by alexruperez on 5/5/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMAnnotationDetailTableViewCellProtocol.h"

@class BMPromotion;

@interface BMPromotionDetailTableViewCell : UITableViewCell <BMAnnotationDetailTableViewCell>

@property (nonatomic, strong) BMPromotion *annotation;

@property (nonatomic, assign) BOOL shouldHighlightContent;

@end
