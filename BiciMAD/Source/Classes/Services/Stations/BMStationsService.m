//
//  BMStationsService.m
//  BiciMAD
//
//  Created by alexruperez on 20/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMStationsService.h"

#import "BMServicesAssembly.h"
#import "BMCoreDataManager.h"
#import "BMFavoritesManager.h"
#import "BMHTTPClientConstants.h"
#import "BMStation.h"

@implementation BMStationsService

- (void)allStationsWithSuccessBlock:(BMStationsServiceArrayBlock)successBlock failureBlock:(BMStationsServiceErrorBlock)failureBlock
{
    BMServiceTask *allStationsTask = [self.servicesAssembly allStationsTask];

    [allStationsTask setSuccessBlock:successBlock];

    @weakify(self)
    [allStationsTask setFailureBlock:^(NSError *error) {
        @strongify(self)
        if ([error.domain isEqualToString:NSURLErrorDomain])
        {
            [self.coreDataManager findAll:BMStation.class completion:^(NSArray *results, NSError *coreDataError) {
                @strongify(self)
                if (results && !coreDataError)
                {
                    [self.favoritesManager load:results];
                    [self.favoritesManager save:results];
                    if (successBlock)
                    {
                        successBlock(results);
                    }
                }
                
                if (failureBlock)
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

    [allStationsTask execute];

}

- (void)singleStationWithStationId:(NSString *)stationId successBlock:(BMStationsServiceStationBlock)successBlock failureBlock:(BMStationsServiceErrorBlock)failureBlock
{
    BMServiceTask *task = [self.servicesAssembly singleStationTaskWithStationId:stationId];

    [task setSuccessBlock:^(BMStation *station) {
        if ([station isKindOfClass:BMStation.class] && successBlock)
        {
            successBlock(station);
        }
    }];

    [task setFailureBlock:failureBlock];

    [task execute];
}

- (void)incidenceWithPhonePreferred:(BOOL)phonePreferred phone:(NSString *)phone email:(NSString *)email lastName:(NSString *)lastName subject:(NSString *)subject text:(NSString *)text successBlock:(BMStationsServiceStringBlock)successBlock failureBlock:(BMStationsServiceErrorBlock)failureBlock
{
    BMServiceTask *task = [self.servicesAssembly incidencesEMTTaskWithPhonePreferred:@(phonePreferred) phone:phone email:email lastName:lastName subject:subject text:text];

    [task setSuccessBlock:successBlock];

    [task setFailureBlock:failureBlock];

    [task execute];
}

- (void)findStationsWithInput:(NSString *)input successBlock:(BMStationsServiceArrayBlock)successBlock failureBlock:(BMStationsServiceErrorBlock)failureBlock
{
    [self.coreDataManager findInput:input selector:@selector(name) modelClass:BMStation.class completion:^(NSArray *results, NSError *coreDataError) {
        if (!coreDataError)
        {
            if (successBlock)
            {
                successBlock(results);
            }
        }
        else if (failureBlock)
        {
            failureBlock(coreDataError);
        }
    }];
}

@end
