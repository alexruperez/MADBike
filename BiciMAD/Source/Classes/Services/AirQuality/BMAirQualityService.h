//
//  BMAirQualityService.h
//  BiciMAD
//
//  Created by alexruperez on 5/6/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMNetworkService.h"

typedef void (^BMAirQualityServiceArrayBlock)(NSArray *array);
typedef void (^BMAirQualityServiceErrorBlock)(NSError *error);

@interface BMAirQualityService : BMNetworkService

- (void)airQualitiesWithOnlyCurrentValues:(BOOL)currentValues onlyAverage:(BOOL)onlyAverage discardAverage:(BOOL)discardAverage successBlock:(BMAirQualityServiceArrayBlock)successBlock failureBlock:(BMAirQualityServiceErrorBlock)failureBlock;

@end
