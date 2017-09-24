//
//  BMPointsService.m
//  BiciMAD
//
//  Created by alexruperez on 7/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMPointsService.h"

#import "BMServicesAssembly.h"
#import "BMCoreDataManager.h"
#import "BMFavoritesManager.h"
#import "BMPointsStorage.h"
#import "BMPartner.h"

@implementation BMPointsService

- (void)allPartnersWithSuccessBlock:(BMPointsServiceArrayBlock)successBlock failureBlock:(BMPointsServiceErrorBlock)failureBlock
{
    BMServiceTask *task = [self.servicesAssembly allPartnersTask];
    
    @weakify(self)
    [task setSuccessBlock:^(NSArray *results) {
        @strongify(self)
        self.pointsStorage.partners = results;
        if (successBlock)
        {
            successBlock(results);
        }
    }];
    
    [task setFailureBlock:^(NSError *error) {
        @strongify(self)
        if ([error.domain isEqualToString:NSURLErrorDomain])
        {
            [self.coreDataManager findAll:BMPartner.class completion:^(NSArray *results, NSError *coreDataError) {
                @strongify(self)
                if (results && !coreDataError)
                {
                    for (BMPartner *partner in results)
                    {
                        [self.favoritesManager load:partner.places];
                        [self.favoritesManager save:partner.places];
                        [self.favoritesManager load:partner.promotions];
                        [self.favoritesManager save:partner.promotions];
                    }
                    
                    self.pointsStorage.partners = results;
                    if (successBlock)
                    {
                        successBlock(results);
                    }
                }
                else if (failureBlock)
                {
                    failureBlock(error ? error : coreDataError);
                }
            }];
        }
        else if (failureBlock)
        {
            failureBlock(error);
        }
    }];
    
    [task execute];
}

- (void)allPartnersWithCompletionBlock:(BMPointsServiceCompletionBlock)completionBlock
{
    [self allPartnersWithSuccessBlock:^(NSArray *results) {
        if (completionBlock)
        {
            completionBlock(results, nil);
        }
    } failureBlock:^(NSError *error) {
        if (completionBlock)
        {
            completionBlock(nil, error);
        }
    }];
}

@end
