//
//  BMEMTSingleStationTask.m
//  BiciMAD
//
//  Created by Alex Rupérez on 10/12/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMEMTSingleStationTask.h"

#import "BMServiceTaskProtocol.h"
#import "BMStation.h"
#import "BMAnalyticsManager.h"

@interface BMEMTSingleStationTask () <BMServiceTask>

@end

@implementation BMEMTSingleStationTask

- (NSString *)requestURLString
{
    return [NSString stringWithFormat:@"%@/%@", kBMRequestSingleStationEMTURLString, self.stationId];
}

- (id)parseResponseObject:(NSDictionary *)responseObject error:(NSError **)error
{
    NSArray *stations = nil;

    id data = responseObject[kBMEMTDataKey];

    if ([data isKindOfClass:NSString.class])
    {
        data = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:error];
    }

    if ([data isKindOfClass:NSDictionary.class])
    {
        data = data[kBMEMTStationsKey];
    }

    if ([data isKindOfClass:NSArray.class])
    {
        stations = [MTLJSONAdapter modelsOfClass:BMStation.class fromJSONArray:data error:error];
        if (stations)
        {
            [self.favoritesManager load:stations];
            [self.favoritesManager save:stations];
            [self.coreDataManager save:stations completion:nil];
            [self.spotlightManager index:stations completion:nil];
        }
    }

    return stations;
}

@end
