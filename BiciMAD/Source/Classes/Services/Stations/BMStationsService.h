//
//  BMStationsService.h
//  BiciMAD
//
//  Created by alexruperez on 20/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import CoreLocation;

#import "BMNetworkService.h"

@class BMCoreDataManager;
@class BMFavoritesManager;
@class BMStation;

typedef void (^BMStationsServiceStringBlock)(NSString *string);
typedef void (^BMStationsServiceStationBlock)(BMStation *station);
typedef void (^BMStationsServiceArrayBlock)(NSArray *array);
typedef void (^BMStationsServiceErrorBlock)(NSError *error);

@interface BMStationsService : BMNetworkService

@property (nonatomic, strong) BMCoreDataManager *coreDataManager;
@property (nonatomic, strong) BMFavoritesManager *favoritesManager;

- (void)allStationsWithSuccessBlock:(BMStationsServiceArrayBlock)successBlock failureBlock:(BMStationsServiceErrorBlock)failureBlock;

- (void)singleStationWithStationId:(NSString *)stationId successBlock:(BMStationsServiceStationBlock)successBlock failureBlock:(BMStationsServiceErrorBlock)failureBlock;

- (void)incidenceWithPhonePreferred:(BOOL)phonePreferred phone:(NSString *)phone email:(NSString *)email lastName:(NSString *)lastName subject:(NSString *)subject text:(NSString *)text successBlock:(BMStationsServiceStringBlock)successBlock failureBlock:(BMStationsServiceErrorBlock)failureBlock;

- (void)findStationsWithInput:(NSString *)input successBlock:(BMStationsServiceArrayBlock)successBlock failureBlock:(BMStationsServiceErrorBlock)failureBlock;

@end
