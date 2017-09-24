//
//  BMAllPartnersTask.m
//  BiciMAD
//
//  Created by alexruperez on 7/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMAllPartnersTask.h"

#import "BMServiceTaskProtocol.h"
#import "BMPartner.h"
#import "BMPromotion.h"
#import "BMPlace.h"

@interface BMAllPartnersTask () <BMServiceTask>

@end

@implementation BMAllPartnersTask

- (NSString *)requestURLString
{
    return kBMRequestAllPartnersURLString;
}

- (id)parseResponseObject:(NSArray *)responseObject error:(NSError **)error
{
    NSArray *partners = nil;
    
    if ([responseObject isKindOfClass:NSArray.class])
    {
        partners = [MTLJSONAdapter modelsOfClass:BMPartner.class fromJSONArray:responseObject error:error];
        if (partners)
        {
            [self.spotlightManager truncateIndexWithDomain:NSStringFromClass(BMPlace.class) completion:nil];
            [self.spotlightManager truncateIndexWithDomain:NSStringFromClass(BMPromotion.class) completion:nil];
            for (BMPartner *partner in partners)
            {
                [self.favoritesManager load:partner.places];
                [self.favoritesManager save:partner.places];
                [self.spotlightManager index:partner.places completion:nil];
                [self.favoritesManager load:partner.promotions];
                [self.favoritesManager save:partner.promotions];
                [self.spotlightManager index:partner.promotions completion:nil];
            }
            
            [self.coreDataManager save:partners completion:nil];
        }
    }
    
    return partners;
}

@end
