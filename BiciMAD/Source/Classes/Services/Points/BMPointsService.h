//
//  BMPointsService.h
//  BiciMAD
//
//  Created by alexruperez on 7/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMNetworkService.h"

@class BMCoreDataManager;
@class BMFavoritesManager;
@class BMPointsStorage;

typedef void (^BMPointsServiceArrayBlock)(NSArray *array);
typedef void (^BMPointsServiceErrorBlock)(NSError *error);
typedef void (^BMPointsServiceCompletionBlock)(NSArray *array, NSError *error);

@interface BMPointsService : BMNetworkService

@property (nonatomic, strong) BMCoreDataManager *coreDataManager;
@property (nonatomic, strong) BMFavoritesManager *favoritesManager;
@property (nonatomic, strong) BMPointsStorage *pointsStorage;

- (void)allPartnersWithSuccessBlock:(BMPointsServiceArrayBlock)successBlock failureBlock:(BMPointsServiceErrorBlock)failureBlock;

- (void)allPartnersWithCompletionBlock:(BMPointsServiceCompletionBlock)completionBlock;

@end
