//
//  BMPlacesService.h
//  BiciMAD
//
//  Created by alexruperez on 22/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import CoreLocation;

#import "BMNetworkService.h"

#import "BMPlacesTask.h"

typedef void (^BMPlacesServiceArrayBlock)(NSArray *array);
typedef void (^BMPlacesServiceErrorBlock)(NSError *error);

@interface BMPlacesService : BMNetworkService

- (void)placesWithInput:(NSString *)input sensor:(BOOL)sensor location:(CLLocationCoordinate2D)location radius:(CGFloat)radius offset:(NSUInteger)offset type:(BMPlacesTaskPlaceType)type successBlock:(BMPlacesServiceArrayBlock)successBlock failureBlock:(BMPlacesServiceErrorBlock)failureBlock;

@end
