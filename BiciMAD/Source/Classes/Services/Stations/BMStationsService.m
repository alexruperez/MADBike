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
#import "BMStation.h"

@implementation BMStationsService

- (void)allStationsWithSuccessBlock:(BMStationsServiceArrayBlock)successBlock failureBlock:(BMStationsServiceErrorBlock)failureBlock
{
    BMServiceTask *taskEMT = [self.servicesAssembly allStationsEMTTask];

    [taskEMT setSuccessBlock:successBlock];

    @weakify(self)
    [taskEMT setFailureBlock:^(NSError *errorEMT) {
        @strongify(self)
        if ([errorEMT.domain isEqualToString:NSURLErrorDomain])
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
                    failureBlock(errorEMT ? errorEMT : coreDataError);
                }
            }];
        }
        else if (failureBlock)
        {
            failureBlock(errorEMT);
        }
    }];

    [taskEMT execute];

}

- (void)singleStationWithStationId:(NSString *)stationId successBlock:(BMStationsServiceStationBlock)successBlock failureBlock:(BMStationsServiceErrorBlock)failureBlock
{
    BMServiceTask *task = [self.servicesAssembly singleStationEMTTaskWithStationId:stationId];

    [task setSuccessBlock:^(NSArray *stations) {
        if ([stations isKindOfClass:NSArray.class] && successBlock)
        {
            successBlock(stations.firstObject);
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
