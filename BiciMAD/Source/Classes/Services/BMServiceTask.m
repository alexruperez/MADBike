//
//  BMServiceTask.m
//  BiciMAD
//
//  Created by alexruperez on 13/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMServiceTask.h"

#import "BMHTTPClient.h"

@interface BMServiceTask ()

@property (nonatomic, strong) NSURLSessionTask *task;

@end

@implementation BMServiceTask

+ (instancetype)taskWithHTTPClient:(BMHTTPClient *)HTTPClient
{
    return [[self alloc] initWithHTTPClient:HTTPClient];
}

- (instancetype)initWithHTTPClient:(BMHTTPClient *)HTTPClient
{
    self = super.init;
    
    if (self)
    {
        _HTTPClient = HTTPClient;
    }
    
    return self;
}

- (NSURL *)baseURL
{
    [self bm_subclassResponsibility:_cmd];
    return nil;
}

- (NSString *)requestURLString
{
    [self bm_subclassResponsibility:_cmd];
    return nil;
}

- (NSURL *)requestURL
{
    return [NSURL URLWithString:self.requestURLString relativeToURL:self.baseURL];
}

- (void)handleResponse:(NSURLResponse *)response responseObject:(id)responseObject error:(NSError *)error
{
    [self bm_subclassResponsibility:_cmd];
}

- (id)parseResponseObject:(id)responseObject error:(NSError **)error
{
    return responseObject;
}

- (NSString *)HTTPMethod
{
    return kBMHTTPClientGETMethod;
}

- (BMMutableURLRequest *)request
{
    BMMutableURLRequest *request = [BMMutableURLRequest requestWithURL:self.requestURL];
    
    request.HTTPMethod = self.HTTPMethod;
    
    request.timeoutInterval = kBMHTTPClientDefaultTimeout;
    
    [request addValue:kBMHTTPClientJSONValue forHTTPHeaderField:kBMHTTPClientContentTypeKey];
    [request addValue:kBMHTTPClientJSONValue forHTTPHeaderField:kBMHTTPClientAcceptKey];
    
    [self configureRequest:request];
    
    if ([request.HTTPMethod isEqualToString:kBMHTTPClientPOSTMethod] && !request.HTTPBody)
    {
        NSError *error = nil;
        
        [request setJSONBody:self.JSONBody error:&error];
        
        if (![self validateRequest:request error:&error])
        {
            DDLogError(@"Validation error: %@", error.localizedDescription);
            
            if (self.failureBlock)
            {
                self.failureBlock(error);
            }
            
            return nil;
        }
    }
    
    [request setCompletionBlock:^(NSURLResponse *response, id responseObject, NSError *error) {
        [self handleResponse:response responseObject:responseObject error:error];
    }];
    
    return request;
}

- (void)configureRequest:(BMMutableURLRequest *)request
{
    
}

- (BOOL)validateRequest:(BMMutableURLRequest *)request error:(NSError **)error
{
    return YES;
}

- (id)JSONBody
{
    [self bm_subclassResponsibility:_cmd];
    return nil;
}

- (void)execute
{
    [self executeInBackground:NO];
}

- (void)executeInBackground:(BOOL)background
{
    self.task = [self.HTTPClient makeRequest:self.request inBackground:background];
}

- (void)cancel
{
    [self.task cancel];
    self.task = nil;
}

@end
