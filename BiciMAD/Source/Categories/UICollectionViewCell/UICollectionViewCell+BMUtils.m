//
//  UICollectionViewCell+BMUtils.m
//  BiciMAD
//
//  Created by alexruperez on 8/9/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "UICollectionViewCell+BMUtils.h"

@import libextobjc;

@safecategory(UICollectionViewCell, BMUtils)

+ (void)bm_registerNibOnCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:self.bm_nib forCellWithReuseIdentifier:self.bm_className];
}

+ (void)bm_registerClassOnCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerClass:self forCellWithReuseIdentifier:self.bm_className];
}

+ (instancetype)bm_dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath fromCollectionView:(UICollectionView *)collectionView
{
    return [collectionView dequeueReusableCellWithReuseIdentifier:self.bm_className forIndexPath:indexPath];
}

@end
