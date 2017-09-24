//
//  NSString+BMSecurity.m
//  BiciMAD
//
//  Created by alexruperez on 7/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "NSString+BMSecurity.h"

#import <CommonCrypto/CommonDigest.h>

@import libextobjc;

@interface NSString (BMHashing)

@property (nonatomic, copy, readonly) NSString *bm_MD5String;

@end

@safecategory(NSString, BMHashing)

- (NSString *)bm_MD5String
{
    const char *cString = self.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cString, (CC_LONG)strlen(cString), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end

@safecategory(NSString, BMSecurity)

- (NSString *)bm_halvedString
{
    return [self substringToIndex:self.length/2];
}

- (NSString *)bm_securizedString
{
    return [self.bm_MD5String stringByAppendingString:self.bm_halvedString.bm_MD5String];
}

@end
