//
//  BMAirQualityMetric.m
//  BiciMAD
//
//  Created by alexruperez on 5/6/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMAirQualityMetric.h"

#import "BMAirQuality.h"

@implementation BMAirQualityMetric

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             NSStringFromSelector(@selector(formula)): @"formula",
             NSStringFromSelector(@selector(unit)): @"unit",
             NSStringFromSelector(@selector(values)): @"values"
             };
}

+ (MTLPropertyStorage)storageBehaviorForPropertyWithKey:(NSString *)propertyKey
{
    if ([propertyKey isEqualToString:NSStringFromSelector(@selector(airQuality))])
    {
        return MTLPropertyStorageTransitory;
    }
    
    return [super storageBehaviorForPropertyWithKey:propertyKey];
}

- (BOOL)isEqual:(BMAirQualityMetric *)airQualityMetric
{
    if ([airQualityMetric isKindOfClass:BMAirQualityMetric.class])
    {
        return [self.airQuality isEqual:airQualityMetric.airQuality] && [self.formula isEqualToString:airQualityMetric.formula];
    }
    
    return [super isEqual:airQualityMetric];
}

- (NSUInteger)hash
{
    return self.airQuality.hash + self.formula.hash;
}

@end
