//
//  BMHTTPClient.h
//  BiciMAD
//
//  Created by alexruperez on 7/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import Foundation;

#import "BMHTTPClientConstants.h"
#import "BMMutableURLRequest.h"

@interface BMHTTPClient : NSObject

+ (instancetype)clientWithBaseURLString:(NSString *)baseURLString;

- (instancetype)initWithBaseURLString:(NSString *)baseURLString;

- (void)invalidateSession;

- (NSURLSessionTask *)makeRequest:(BMMutableURLRequest *)request inBackground:(BOOL)background;

@end
