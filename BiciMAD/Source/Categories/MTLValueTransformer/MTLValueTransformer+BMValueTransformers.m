//
//  MTLValueTransformer+BMValueTransformers.m
//  BiciMAD
//
//  Created by alexruperez on 14/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "MTLValueTransformer+BMValueTransformers.h"

@import libextobjc;

@interface MTLValueTransformer ()

@property (nonatomic, copy, readonly) MTLValueTransformerBlock forwardBlock;
@property (nonatomic, copy, readonly) MTLValueTransformerBlock reverseBlock;

@end

@safecategory(MTLValueTransformer, BMValueTransformers)

+ (MTLValueTransformer *)bm_urlValueTransformer
{
    return (MTLValueTransformer *)[NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (MTLValueTransformer *)bm_doubleValueTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
        if ([value isKindOfClass:NSDictionary.class])
        {
            value = [[value allValues] firstObject];
        }
        if ([value isKindOfClass:NSString.class])
        {
            value = @([value doubleValue]);
        }
        if (!value)
        {
            value = @0;
        }
        *success = [value isKindOfClass:NSNumber.class];
        return value;
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:NSDictionary.class])
        {
            value = [[value allValues] firstObject];
        }
        if ([value isKindOfClass:NSNumber.class])
        {
            value = [value stringValue];
        }
        if (!value)
        {
            value = @"";
        }
        *success = [value isKindOfClass:NSString.class];
        return value;
    }];
}

+ (NSDateFormatter *)bm_dateFormatterWithFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = NSDateFormatter.new;
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    dateFormatter.dateFormat = dateFormat;
    return dateFormatter;
}

+ (MTLValueTransformer *)bm_dateValueTransformerWithFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [self bm_dateFormatterWithFormat:dateFormat];
    
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
        if ([value isKindOfClass:NSString.class])
        {
            value = [dateFormatter dateFromString:value];
        }
        *success = [value isKindOfClass:NSDate.class];
        return value;
    } reverseBlock:^id(id value, BOOL *success, NSError **error) {
        if ([value isKindOfClass:NSDate.class])
        {
            value = [dateFormatter stringFromDate:value];
        }
        *success = [value isKindOfClass:NSString.class];
        return value;
    }];
}

+ (MTLValueTransformer *)bm_stringArrayValueTransformerWithSeparator:(NSString *)separator
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
        if ([value isKindOfClass:NSArray.class])
        {
            value = [value componentsJoinedByString:separator];
        }
        *success = [value isKindOfClass:NSString.class];
        return value;
    } reverseBlock:^id(id value, BOOL *success, NSError **error) {
        if ([value isKindOfClass:NSString.class])
        {
            value = [value componentsSeparatedByString:separator];
        }
        *success = [value isKindOfClass:NSArray.class];
        return value;
    }];
}

@end
