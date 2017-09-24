//
//  NSArray+BMUtils.m
//  BiciMAD
//
//  Created by alexruperez on 19/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "NSArray+BMUtils.h"

@import libextobjc;

@safecategory(NSArray, BMUtils)

- (instancetype)bm_map:(id (^)(id object))block
{
    NSMutableArray *mappedObjects = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id object in self)
    {
        if (object && block)
        {
            id mappedObject = block(object);
            if (mappedObject)
            {
                [mappedObjects addObject:mappedObject];
            }
        }
    }
    
    return mappedObjects.copy;
}

- (instancetype)bm_mapArray:(NSArray *(^)(id object))block
{
    NSMutableArray *mappedObjects = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id object in self)
    {
        if (object && block)
        {
            NSArray *mappedObject = block(object);
            if (mappedObject)
            {
                [mappedObjects addObjectsFromArray:mappedObject];
            }
        }
    }
    
    return mappedObjects.copy;
}

- (instancetype)bm_filter:(BOOL (^)(id object))block
{
    NSMutableArray *filteredObjects = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id object in self)
    {
        if (object && block && block(object))
        {
            [filteredObjects addObject:object];
        }
    }
    
    return filteredObjects.copy;
}

@end
