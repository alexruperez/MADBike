//
//  BMEMTLoginTask.m
//  BiciMAD
//
//  Created by Alex Rupérez on 18/08/19.
//  Copyright © 2019 alexruperez. All rights reserved.
//

#import "BMEMTLoginTask.h"

#import "BMServiceTaskProtocol.h"
#import "BMAnalyticsManager.h"

@interface BMEMTLoginTask () <BMServiceTask>

@end

@implementation BMEMTLoginTask

- (NSString *)requestURLString
{
    return kBMRequestLoginEMTURLString;
}

- (void)configureRequest:(BMMutableURLRequest *)request
{
    [request addValue:BMAnalyticsManager.keys.eMTClientId forHTTPHeaderField:kBMHTTPClientEMTEmailKey];
    [request addValue:BMAnalyticsManager.keys.eMTPassKey forHTTPHeaderField:kBMHTTPClientEMTPasswordKey];
}

- (id)parseResponseObject:(NSDictionary *)responseObject error:(NSError **)error
{
    id data = responseObject[kBMEMTDataKey];

    if ([data isKindOfClass:NSArray.class])
    {
        data = [(NSArray *)data firstObject];
    }

    if ([data isKindOfClass:NSString.class])
    {
        data = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:error];
    }

    if ([data isKindOfClass:NSArray.class])
    {
        data = [(NSArray *)data firstObject];
    }

    if ([data isKindOfClass:NSDictionary.class])
    {
        data = data[kBMEMTAccessTokenKey];
    }
    
    return data;
}

@end
