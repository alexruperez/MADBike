//
//  NSObject+BMUtils.m
//  BiciMAD
//
//  Created by alexruperez on 14/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "NSObject+BMUtils.h"

@implementation NSObject (BMUtils)

+ (NSString *)bm_className
{
    return [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
}

- (NSString *)bm_className
{
    return self.class.bm_className;
}

- (void)bm_subclassResponsibility:(SEL)selector
{
    [NSException raise:NSInvalidArgumentException format:@"[%@ %@] should be overridden by subclass!", self.bm_className, selector ? NSStringFromSelector(selector) : @"(null)"];
}

@end
