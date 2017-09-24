//
//  BMDrunkcodeServiceTask.m
//  BiciMAD
//
//  Created by alexruperez on 7/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMDrunkcodeServiceTask.h"

@import Crashlytics;

#import "BMHTTPClient.h"
#import "BMServiceTaskProtocol.h"
#import "BMAnalyticsManager.h"

@interface BMDrunkcodeServiceTask () <BMServiceTask>

@end

@implementation BMDrunkcodeServiceTask

- (NSURL *)baseURL
{
    return [NSURL URLWithString:kBMHTTPClientDrunkcodeProductionURLString];
}

- (NSString *)requestURLString
{
    [self bm_subclassResponsibility:_cmd];
    return nil;
}

- (void)handleResponse:(NSURLResponse *)response responseObject:(id)responseObject error:(NSError *)error
{
    if (!error)
    {
        responseObject = [self parseResponseObject:responseObject error:&error];
        
        if (!error)
        {
            if (self.successBlock)
            {
                self.successBlock(responseObject);
            }
            return;
        }
    }
    
    error = [self errorWithResponseObject:responseObject defaultError:error];
    
    DDLogError(@"Drunkcode error: %@", error.localizedDescription);
    
    if (self.failureBlock)
    {
        self.failureBlock(error);
    }
}

- (NSError *)errorWithResponseObject:(id)responseObject defaultError:(NSError *)defaultError
{
    NSString *errorDomain = defaultError.domain;
    NSInteger errorCode = defaultError.code;
    NSString *errorMsg = defaultError.localizedDescription;
    
    if ([responseObject isKindOfClass:NSDictionary.class])
    {
        errorDomain = kBMDKErrorDomain;
        errorMsg = responseObject[kBMErrorKey];
    }
    
    if (!errorMsg)
    {
        errorMsg = @"";
    }
    
    NSError *resultError = [NSError errorWithDomain:errorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
    
    [self.crashlyticsManager recordError:resultError];
    
    return resultError;
}

- (void)configureRequest:(BMMutableURLRequest *)request
{
    [request addValue:BMAnalyticsManager.keys.mADBikeAPIUserEmail forHTTPHeaderField:kBMHTTPClientUserEmailKey];
    [request addValue:BMAnalyticsManager.keys.mADBikeAPIUserToken forHTTPHeaderField:kBMHTTPClientUserTokenKey];
}

- (id)JSONBody
{
    return @{};
}

@end
