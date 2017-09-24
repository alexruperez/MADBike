//
//  BMEMTServiceTask.m
//  BiciMAD
//
//  Created by Alex Rupérez on 10/12/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMEMTServiceTask.h"

@import Crashlytics;

#import "BMHTTPClient.h"
#import "BMServiceTaskProtocol.h"

@interface BMEMTServiceTask () <BMServiceTask>

@end

@implementation BMEMTServiceTask

- (NSURL *)baseURL
{
    return [NSURL URLWithString:kBMHTTPClientEMTURLString];
}

- (NSString *)requestURLString
{
    [self bm_subclassResponsibility:_cmd];
    return nil;
}

- (void)handleResponse:(NSURLResponse *)response responseObject:(id)responseObject error:(NSError *)error
{
    if (!error && [responseObject isKindOfClass:NSDictionary.class] && [responseObject[kBMEMTCodeKey] integerValue] == kBMEMTErrorCodeSuccess)
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
    
    DDLogError(@"EMT error: %@", error.localizedDescription);
    
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
        errorDomain = kBMEMTErrorDomain;
        errorMsg = responseObject[kBMEMTDescriptionKey];
    }
    
    if (!errorMsg)
    {
        errorMsg = @"";
    }
    
    NSError *resultError = [NSError errorWithDomain:errorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
    
    [self.crashlyticsManager recordError:resultError];
    
    return resultError;
}

- (id)JSONBody
{
    return @{};
}

@end
