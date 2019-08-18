//
//  BMHTTPClientConstants.m
//  BiciMAD
//
//  Created by alexruperez on 7/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMHTTPClientConstants.h"

@implementation BMHTTPClientConstants

// DrunkCode API URL
NSString * const kBMHTTPClientDrunkcodeProductionURLString = @"https://madbike.herokuapp.com/";
NSString * const kBMHTTPClientDrunkcodeStagingURLString = @"https://madbike-staging.herokuapp.com/";

// DrunkCode Protected Methods
NSString * const kBMRequestAllPartnersURLString = @"partners.json";
NSString * const kBMRequestAirQualityURLString = @"air_qualities.json";

// DrunkCode Error Domain
NSString * const kBMDKErrorDomain = @"org.drunkcode.MADBike.error.drunkcode";

// DrunkCode Error Keys
NSString * const kBMErrorKey = @"error";

// EMT API URL
NSString * const kBMHTTPClientEMTURLString = @"https://openapi.emtmadrid.es/v1/";

// EMT Protected Methods
NSString * const kBMRequestAllStationsEMTURLString = @"transport/bicimad/stations";
NSString * const kBMRequestSingleStationEMTURLString = @"transport/bicimad/stations";
NSString * const kBMRequestIncidencesEMTURLString = @"suggestion";
NSString * const kBMRequestLoginEMTURLString = @"mobilitylabs/user/login";

// EMT Response Keys
NSString * const kBMEMTCodeKey = @"code";
NSString * const kBMEMTDescriptionKey = @"description";
NSString * const kBMEMTDataKey = @"data";
NSString * const kBMEMTStationsKey = @"stations";
NSString * const kBMEMTAccessTokenKey = @"accessToken";

// EMT Error Domain
NSString * const kBMEMTErrorDomain = @"org.drunkcode.MADBike.error.emt";

// EMT Error Codes
NSInteger const kBMEMTErrorCodeSuccess = 0;
NSInteger const kBMEMTErrorCodeNoPassKeyNecesary = 1;
NSInteger const kBMEMTErrorCodePassKeyDistinct = 2;
NSInteger const kBMEMTErrorCodePassKeyExpired = 3;
NSInteger const kBMEMTErrorCodeClientUnauthorized = 4;
NSInteger const kBMEMTErrorCodeClientDeactivate = 5;
NSInteger const kBMEMTErrorCodeClientLocked = 6;
NSInteger const kBMEMTErrorCodeAuthFailed = 9;

// BiciMAD HTTP Config
NSTimeInterval const kBMHTTPClientDefaultTimeout = 30.f;

// BiciMAD HTTP Methods
NSString * const kBMHTTPClientGETMethod = @"GET";
NSString * const kBMHTTPClientPOSTMethod = @"POST";

// BiciMAD HTTP Header Keys
NSString * const kBMHTTPClientContentTypeKey = @"Content-Type";
NSString * const kBMHTTPClientAcceptKey = @"Accept";

// DrunkCode HTTP Header Keys
NSString * const kBMHTTPClientUserEmailKey = @"X-User-Email";
NSString * const kBMHTTPClientUserTokenKey = @"X-User-Token";

// EMT HTTP Header Keys
NSString * const kBMHTTPClientEMTEmailKey = @"email";
NSString * const kBMHTTPClientEMTPasswordKey = @"password";

// BiciMAD HTTP Header Values
NSString * const kBMHTTPClientJSONValue = @"application/json; charset=utf-8";

@end
