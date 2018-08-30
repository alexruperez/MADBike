//
//  BMHTTPClient.m
//  BiciMAD
//
//  Created by alexruperez on 7/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMHTTPClient.h"

@import AFNetworking;

static NSString * const kBMBackgroundSessionIdentifier = @"org.drunkcode.MADBike.background";

@interface BMHTTPClient ()

@property (nonatomic, strong) NSURL *baseURL;

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) AFHTTPSessionManager *backgroundSessionManager;

@end

@implementation BMHTTPClient

+ (instancetype)clientWithBaseURLString:(NSString *)baseURLString
{
    return [[self alloc] initWithBaseURLString:baseURLString];
}

- (instancetype)initWithBaseURLString:(NSString *)baseURLString
{
    self = super.init;
    
    if (self)
    {
        _baseURL = [NSURL URLWithString:baseURLString];
    }
    
    return self;
}

- (NSURLSessionConfiguration *)sessionConfiguration
{
    NSURLSessionConfiguration *sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration;
    
    return sessionConfiguration;
}

- (NSURLSessionConfiguration *)backgroundSessionConfiguration
{
    NSURLSessionConfiguration *backgroundSessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kBMBackgroundSessionIdentifier];
    backgroundSessionConfiguration.discretionary = YES;
    
    return backgroundSessionConfiguration;
}

- (AFHTTPSessionManager *)sessionManager
{
    if (!_sessionManager)
    {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.baseURL sessionConfiguration:self.sessionConfiguration];
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
        _sessionManager.responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[[AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments], [AFHTTPResponseSerializer serializer]]];
        [_sessionManager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential **credential) {
            *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            return NSURLSessionAuthChallengeUseCredential;
        }];
    }
    
    return _sessionManager;
}

- (AFHTTPSessionManager *)backgroundSessionManager
{
    if (!_backgroundSessionManager)
    {
        _backgroundSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.baseURL sessionConfiguration:self.backgroundSessionConfiguration];
        _backgroundSessionManager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
        _backgroundSessionManager.responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[[AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments], [AFHTTPResponseSerializer serializer]]];
        [_backgroundSessionManager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential **credential) {
            *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            return NSURLSessionAuthChallengeUseCredential;
        }];
    }
    
    return _backgroundSessionManager;
}

- (void)invalidateSession
{
    [self.sessionManager invalidateSessionCancelingTasks:YES];
    [self.backgroundSessionManager invalidateSessionCancelingTasks:YES];
    self.sessionManager = nil;
    self.backgroundSessionManager = nil;
}

- (NSURLSessionTask *)makeRequest:(BMMutableURLRequest *)request inBackground:(BOOL)background
{
    return [self resumeDataTaskWithRequest:request inBackground:background completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if ([request isKindOfClass:BMMutableURLRequest.class])
        {
            if ([responseObject isKindOfClass:NSData.class] && [responseObject bytes] != NULL)
            {
                NSError *JSONError = nil;
                
                id responseJSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&JSONError];
                
                if (!JSONError)
                {
                    responseObject = responseJSON;
                }
                else if (!error)
                {
                    responseObject = [NSString stringWithUTF8String:[responseObject bytes]];
                    error = JSONError;
                }
            }
            
            if (request.completionBlock)
            {
                request.completionBlock(response, responseObject, error);
            }
        }
    }];
}

- (NSURLSessionDataTask *)resumeDataTaskWithRequest:(NSURLRequest *)request inBackground:(BOOL)background completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    NSURLSessionDataTask *dataTask = [self dataTaskWithRequest:request inBackground:background completionHandler:completionHandler];
    
    [dataTask resume];
    
    return dataTask;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request inBackground:(BOOL)background completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    if (!request.URL || [request.URL isEqual:NSNull.null])
    {
        return nil;
    }
    
    return [background ? self.backgroundSessionManager : self.sessionManager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {} downloadProgress:^(NSProgress * _Nonnull downloadProgress) {} completionHandler:completionHandler];
}

@end
