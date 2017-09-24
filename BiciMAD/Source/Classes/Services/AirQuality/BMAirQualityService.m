//
//  BMAirQualityService.m
//  BiciMAD
//
//  Created by alexruperez on 5/6/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMAirQualityService.h"

#import "BMServicesAssembly.h"

@implementation BMAirQualityService

- (void)airQualitiesWithOnlyCurrentValues:(BOOL)currentValues onlyAverage:(BOOL)onlyAverage discardAverage:(BOOL)discardAverage successBlock:(BMAirQualityServiceArrayBlock)successBlock failureBlock:(BMAirQualityServiceErrorBlock)failureBlock
{
    BMServiceTask *task = [self.servicesAssembly airQualityTaskWithOnlyCurrentValues:@(currentValues) onlyAverage:@(onlyAverage) discardAverage:@(discardAverage)];
    
    [task setSuccessBlock:successBlock];
    
    [task setFailureBlock:failureBlock];
    
    [task execute];
}

@end
