//
//  MTLModel+BMMerge.m
//  BiciMAD
//
//  Created by alexruperez on 1/12/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "MTLModel+BMMerge.h"

@implementation MTLModel (BMMerge)

- (void)mergeValueForKey:(NSString *)key fromModel:(NSObject<MTLModel> *)model {
    NSParameterAssert(key != nil);
    
    SEL selector = MTLSelectorWithCapitalizedKeyPattern("merge", key, "FromModel:");
    if (![self respondsToSelector:selector])
    {
        if (model != nil)
        {
            id value = [model valueForKey:key];
            if (value != nil)
            {
                [self setValue:value forKey:key];
            }
        }
        
        return;
    }
    
    IMP imp = [self methodForSelector:selector];
    void (*function)(id, SEL, id<MTLModel>) = (__typeof__(function))imp;
    function(self, selector, model);
}

@end
