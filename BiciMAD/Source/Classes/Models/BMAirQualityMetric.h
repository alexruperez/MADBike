//
//  BMAirQualityMetric.h
//  BiciMAD
//
//  Created by alexruperez on 5/6/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import Mantle;

@class BMAirQuality;

@interface BMAirQualityMetric : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *formula;
@property (nonatomic, copy, readonly) NSString *unit;
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *values;
@property (nonatomic, weak) BMAirQuality *airQuality;

@end
