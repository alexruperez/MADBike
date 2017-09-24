//
//  BMFormulaCollectionViewCell.m
//  BiciMAD
//
//  Created by alexruperez on 6/6/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMFormulaCollectionViewCell.h"

@implementation BMFormulaCollectionViewCell

- (instancetype)init
{
    self = self.bm_loadFromNib;
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.formulaLabel.textColor = UIColor.whiteColor;
    self.backgroundColor = UIColor.bm_backgroundColor;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.formulaLabel.textColor = selected ? UIColor.bm_tintColor : UIColor.whiteColor;
    self.backgroundColor = selected ? UIColor.whiteColor : UIColor.bm_backgroundColor;
}

@end
