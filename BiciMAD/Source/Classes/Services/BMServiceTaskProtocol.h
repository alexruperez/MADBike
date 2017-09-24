//
//  BMServiceTaskProtocol.h
//  BiciMAD
//
//  Created by alexruperez on 13/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMHTTPClientConstants.h"
#import "BMMutableURLRequest.h"
#import "BMFavoritesManager.h"
#import "BMCoreDataManager.h"
#import "BMSpotlightManager.h"

@protocol BMServiceTask <NSObject>

@property (nonatomic, copy, readonly) NSString *requestURLString;

@optional

@property (nonatomic, copy, readonly) NSString *securityString;
@property (nonatomic, copy, readonly) NSString *securityToken;
@property (nonatomic, copy, readonly) NSString *HTTPMethod;

- (id)parseResponseObject:(id)responseObject error:(NSError **)error;

- (void)configureRequest:(BMMutableURLRequest *)request;

- (BOOL)validateRequest:(BMMutableURLRequest *)request error:(NSError **)error;

@end

@interface BMServiceTask ()

@property (nonatomic, copy, readonly) NSObject *JSONBody;

@end
