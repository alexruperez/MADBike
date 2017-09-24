//
//  BMAirQualityTask.m
//  BiciMAD
//
//  Created by alexruperez on 5/6/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMAirQualityTask.h"

#import "BMServiceTaskProtocol.h"
#import "BMAirQuality.h"

@interface BMServiceTask () <BMServiceTask>

@end

@implementation BMAirQualityTask

- (NSString *)requestURLString
{
    return kBMRequestAirQualityURLString;
}

- (void)configureRequest:(BMMutableURLRequest *)request
{
    [super configureRequest:request];
    
    NSMutableArray *parameters = NSMutableArray.new;
    
    if (self.currentValues)
    {
        [parameters addObject:[NSURLQueryItem queryItemWithName:@"current_values" value:@"1"]];
    }
    
    if (self.discardAverage)
    {
        [parameters addObject:[NSURLQueryItem queryItemWithName:@"discard_average" value:@"1"]];
    }
    
    if (self.onlyAverage)
    {
        [parameters addObject:[NSURLQueryItem queryItemWithName:@"only_average" value:@"1"]];
    }
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
    components.queryItems = parameters.copy;
    request.URL = components.URL;
}

- (id)parseResponseObject:(NSDictionary *)responseObject error:(NSError **)error
{
    NSArray *airQualities = nil;
    
    if ([responseObject isKindOfClass:NSDictionary.class])
    {
        airQualities = [MTLJSONAdapter modelsOfClass:BMAirQuality.class fromJSONArray:responseObject[@"stations"] error:error];
    }
    
    return airQualities;
}

@end
