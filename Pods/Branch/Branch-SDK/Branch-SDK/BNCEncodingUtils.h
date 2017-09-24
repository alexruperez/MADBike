//
//  BNCEncodingUtils.h
//  Branch
//
//  Created by Graham Mueller on 3/31/15.
//  Copyright (c) 2015 Branch Metrics. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark BNCKeyValue

@interface BNCKeyValue : NSObject

+ (BNCKeyValue*) key:(NSString*)key value:(NSString*)value;
- (NSString*) description;

@property (nonatomic, strong) NSString* key;
@property (nonatomic, strong) NSString* value;

@end

#pragma mark - BNCEncodingUtils

@interface BNCEncodingUtils : NSObject

+ (NSString *)base64EncodeStringToString:(NSString *)strData;
+ (NSString *)base64DecodeStringToString:(NSString *)strData;
+ (NSString *)base64EncodeData:(NSData *)objData;
+ (NSData *)base64DecodeString:(NSString *)strBase64;

+ (NSString *)md5Encode:(NSString *)input;

+ (NSString *)urlEncodedString:(NSString *)string;
+ (NSString *)encodeArrayToJsonString:(NSArray *)dictionary;
+ (NSString *)encodeDictionaryToJsonString:(NSDictionary *)dictionary;
+ (NSData *)encodeDictionaryToJsonData:(NSDictionary *)dictionary;

+ (NSString*) stringByPercentDecodingString:(NSString*)string;

+ (NSDictionary *)decodeJsonDataToDictionary:(NSData *)jsonData;
+ (NSDictionary *)decodeJsonStringToDictionary:(NSString *)jsonString;
+ (NSDictionary *)decodeQueryStringToDictionary:(NSString *)queryString;
+ (NSString *)encodeDictionaryToQueryString:(NSDictionary *)dictionary;

+ (NSString *) hexStringFromData:(NSData*)data;
+ (NSData *)   dataFromHexString:(NSString*)string;

+ (NSArray<BNCKeyValue*>*) queryItems:(NSURL*)URL;

@end
