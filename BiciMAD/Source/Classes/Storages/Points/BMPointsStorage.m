//
//  BMPointsStorage.m
//  BiciMAD
//
//  Created by alexruperez on 18/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMPointsStorage.h"
#import "NSArray+BMUtils.h"
#import "BMPartner.h"

@implementation BMPointsStorage

- (NSArray *)places
{
    return [self.partners bm_mapArray:^id(BMPartner *partner) {
        return partner.places;
    }];
}

- (NSArray *)promotions
{
    return [self.partners bm_mapArray:^id(BMPartner *partner) {
        return partner.promotions;
    }];
}

@end
