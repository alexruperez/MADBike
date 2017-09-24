//
//  BMMutableURLRequest.m
//  BiciMAD
//
//  Created by alexruperez on 13/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMMutableURLRequest.h"

@implementation BMMutableURLRequest

- (BOOL)setJSONBody:(id)JSONBody error:(NSError **)error
{
    self.HTTPBody = [NSJSONSerialization dataWithJSONObject:JSONBody options:NSJSONWritingPrettyPrinted error:error];
    return !*error;
}

@end
