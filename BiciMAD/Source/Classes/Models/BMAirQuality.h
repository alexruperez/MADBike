//
//  BMAirQuality.h
//  BiciMAD
//
//  Created by alexruperez on 5/6/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import CoreLocation;
@import Mantle;

#import "BMAirQualityMetric.h"

@interface BMAirQuality : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *stationId;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, assign, readonly) CLLocationDegrees latitude;
@property (nonatomic, assign, readonly) CLLocationDegrees longitude;
@property (nonatomic, assign, readonly) CLLocationDegrees altitude;
@property (nonatomic, strong, readonly) NSValue *mapPointValue;
@property (nonatomic, copy, readonly) NSArray<BMAirQualityMetric *> *metrics;

@end
