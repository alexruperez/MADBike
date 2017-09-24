//
//  UICollectionReusableView+BMUtils.m
//  BiciMAD
//
//  Created by alexruperez on 8/9/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "UICollectionReusableView+BMUtils.h"

@import libextobjc;

@safecategory(UICollectionReusableView, BMUtils)

+ (void)bm_registerNibOnCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:self.bm_nib forSupplementaryViewOfKind:self.bm_className withReuseIdentifier:self.bm_className];
}

+ (void)bm_registerClassOnCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerClass:self forSupplementaryViewOfKind:self.bm_className withReuseIdentifier:self.bm_className];
}

+ (instancetype)bm_dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath fromCollectionView:(UICollectionView *)collectionView
{
    return [collectionView dequeueReusableSupplementaryViewOfKind:self.bm_className withReuseIdentifier:self.bm_className forIndexPath:indexPath];
}

@end
