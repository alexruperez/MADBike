//
//  BMHTTPClientConstants.h
//  BiciMAD
//
//  Created by alexruperez on 7/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import Foundation;

@interface BMHTTPClientConstants : NSObject

// DrunkCode API URL
extern NSString * const kBMHTTPClientDrunkcodeProductionURLString;
extern NSString * const kBMHTTPClientDrunkcodeStagingURLString;

// DrunkCode Protected Methods
extern NSString * const kBMRequestAllPartnersURLString;
extern NSString * const kBMRequestAirQualityURLString;

// DrunkCode Error Domain
extern NSString * const kBMDKErrorDomain;

// DrunkCode Error Keys
extern NSString * const kBMErrorKey;

// EMT API URL
extern NSString * const kBMHTTPClientEMTURLString;

// EMT Protected Methods
extern NSString * const kBMRequestAllStationsEMTURLString;
extern NSString * const kBMRequestSingleStationEMTURLString;
extern NSString * const kBMRequestIncidencesEMTURLString;

// EMT Response Keys
extern NSString * const kBMEMTCodeKey;
extern NSString * const kBMEMTDescriptionKey;
extern NSString * const kBMEMTDataKey;
extern NSString * const kBMEMTStationsKey;

// EMT Error Domain
extern NSString * const kBMEMTErrorDomain;

// EMT Error Codes
extern NSInteger const kBMEMTErrorCodeSuccess;
extern NSInteger const kBMEMTErrorCodeNoPassKeyNecesary;
extern NSInteger const kBMEMTErrorCodePassKeyDistinct;
extern NSInteger const kBMEMTErrorCodePassKeyExpired;
extern NSInteger const kBMEMTErrorCodeClientUnauthorized;
extern NSInteger const kBMEMTErrorCodeClientDeactivate;
extern NSInteger const kBMEMTErrorCodeClientLocked;
extern NSInteger const kBMEMTErrorCodeAuthFailed;

// BiciMAD HTTP Config
extern NSTimeInterval const kBMHTTPClientDefaultTimeout;

// BiciMAD HTTP Methods
extern NSString * const kBMHTTPClientGETMethod;
extern NSString * const kBMHTTPClientPOSTMethod;

// BiciMAD HTTP Header Keys
extern NSString * const kBMHTTPClientContentTypeKey;
extern NSString * const kBMHTTPClientAcceptKey;

// DrunkCode HTTP Header Keys
extern NSString * const kBMHTTPClientUserEmailKey;
extern NSString * const kBMHTTPClientUserTokenKey;

// BiciMAD HTTP Header Values
extern NSString * const kBMHTTPClientJSONValue;

@end
