//
//  UICollectionViewCell+BMUtils.h
//  BiciMAD
//
//  Created by alexruperez on 8/9/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import UIKit;

@interface UICollectionViewCell (BMUtils)

+ (void)bm_registerNibOnCollectionView:(UICollectionView *)collectionView;

+ (void)bm_registerClassOnCollectionView:(UICollectionView *)collectionView;

+ (instancetype)bm_dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath fromCollectionView:(UICollectionView *)collectionView;

@end
