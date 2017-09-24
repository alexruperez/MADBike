//
//  BMAirQuality.m
//  BiciMAD
//
//  Created by alexruperez on 5/6/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMAirQuality.h"

@import MapKit;

#import "MTLValueTransformer+BMValueTransformers.h"
#import "BMAirQualityMetric.h"

static NSString * const kBMDateFormat = @"yyyy-MM-dd";

@implementation BMAirQuality

+ (NSValueTransformer *)stationIdJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)dateJSONTransformer
{
    return [MTLValueTransformer bm_dateValueTransformerWithFormat:kBMDateFormat];
}

+ (NSValueTransformer *)latitudeJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)longitudeJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)altitudeJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)metricsJSONTransformer
{
    return [MTLJSONAdapter arrayTransformerWithModelClass:BMAirQualityMetric.class];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             NSStringFromSelector(@selector(stationId)): @"id",
             NSStringFromSelector(@selector(name)): @"name",
             NSStringFromSelector(@selector(date)): @"date",
             NSStringFromSelector(@selector(latitude)): @"latitude",
             NSStringFromSelector(@selector(longitude)): @"longitude",
             NSStringFromSelector(@selector(altitude)): @"altitude",
             NSStringFromSelector(@selector(metrics)): @"metrics"
             };
}

- (void)setStationId:(NSString *)stationId
{
    if (_stationId != stationId)
    {
        if ([stationId isKindOfClass:NSNumber.class])
        {
            _stationId = [(NSNumber *)stationId stringValue];
        }
        else if ([stationId isKindOfClass:NSString.class])
        {
            _stationId = stationId;
        }
    }
}

- (void)setMetrics:(NSArray<BMAirQualityMetric *> *)metrics
{
    _metrics = metrics.copy;
    for (BMAirQualityMetric *metric in _metrics)
    {
        metric.airQuality = self;
    }
}

- (CLLocation *)location
{
    return [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.latitude, self.longitude) altitude:self.altitude horizontalAccuracy:0.f verticalAccuracy:0.f timestamp:self.date];
}

- (MKMapPoint)mapPoint
{
    return MKMapPointForCoordinate(CLLocationCoordinate2DMake(self.latitude, self.longitude));
}

- (NSValue *)mapPointValue
{
    MKMapPoint mapPoint = self.mapPoint;
    return [NSValue value:&mapPoint withObjCType:@encode(MKMapPoint)];
}

- (BOOL)isEqual:(BMAirQuality *)airQuality
{
    if ([airQuality isKindOfClass:BMAirQuality.class])
    {
        return [self.stationId isEqualToString:airQuality.stationId];
    }
    
    return [super isEqual:airQuality];
}

- (NSUInteger)hash
{
    return self.stationId.hash;
}

@end
