//
//  BMAllStationsTask.m
//  BiciMAD
//
//  Created by Alex Rupérez on 10/12/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMAllStationsTask.h"

#import "BMServiceTaskProtocol.h"
#import "BMStation.h"
#import "BMAnalyticsManager.h"
#import "BMUserDefaultsManager.h"

@interface BMAllStationsTask () <BMServiceTask>

@end

@implementation BMAllStationsTask

- (NSString *)requestURLString
{
    return kBMRequestAllStationsURLString;
}

- (id)parseResponseObject:(NSDictionary *)responseObject error:(NSError **)error
{
    NSArray *stations = nil;

    id data = responseObject[kBMStationsKey];
    
    if ([data isKindOfClass:NSArray.class])
    {
        stations = [MTLJSONAdapter modelsOfClass:BMStation.class fromJSONArray:data error:error];
        if (stations)
        {
            [self.favoritesManager load:stations];
            [self.favoritesManager save:stations];
            [self.coreDataManager save:stations completion:nil];
            [self.spotlightManager truncateIndexWithDomain:NSStringFromClass(BMStation.class) completion:nil];
            [self.spotlightManager index:stations completion:nil];
        }
    }
    
    return stations;
}

@end
