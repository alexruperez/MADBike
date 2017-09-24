//
//  BMAirQualityTask.h
//  BiciMAD
//
//  Created by alexruperez on 5/6/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMDrunkcodeServiceTask.h"

@interface BMAirQualityTask : BMDrunkcodeServiceTask

@property (nonatomic, assign) BOOL currentValues;
@property (nonatomic, assign) BOOL discardAverage;
@property (nonatomic, assign) BOOL onlyAverage;

@end
