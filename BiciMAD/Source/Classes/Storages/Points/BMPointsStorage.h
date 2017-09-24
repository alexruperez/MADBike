//
//  BMPointsStorage.h
//  BiciMAD
//
//  Created by alexruperez on 18/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMStorage.h"

@interface BMPointsStorage : BMStorage

@property (nonatomic, copy) NSArray *partners;

@property (nonatomic, copy, readonly) NSArray *places;

@property (nonatomic, copy, readonly) NSArray *promotions;

@end
