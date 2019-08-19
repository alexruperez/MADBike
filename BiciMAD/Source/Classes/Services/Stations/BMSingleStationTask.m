//
//  BMSingleStationTask.m
//  BiciMAD
//
//  Created by Alex Rupérez on 10/12/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMSingleStationTask.h"

#import "BMServiceTaskProtocol.h"
#import "BMStation.h"
#import "BMAnalyticsManager.h"
#import "BMUserDefaultsManager.h"

@interface BMSingleStationTask () <BMServiceTask>

@end

@implementation BMSingleStationTask

- (NSString *)requestURLString
{
    return [NSString stringWithFormat:kBMRequestSingleStationURLString, self.stationId];
}

- (id)parseResponseObject:(NSDictionary *)responseObject error:(NSError **)error
{
    BMStation *station = nil;

    if ([responseObject isKindOfClass:NSDictionary.class])
    {
        station = [MTLJSONAdapter modelOfClass:BMStation.class fromJSONDictionary:responseObject error:error];
        if (station)
        {
            [self.favoritesManager load:station];
            [self.favoritesManager save:station];
            [self.coreDataManager save:station completion:nil];
            [self.spotlightManager index:station completion:nil];
        }
    }

    return station;
}

@end
