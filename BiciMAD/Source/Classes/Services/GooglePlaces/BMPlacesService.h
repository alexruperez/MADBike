//
//  BMPlacesService.h
//  BiciMAD
//
//  Created by alexruperez on 22/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import GooglePlaces;

#import "BMNetworkService.h"

#import "BMPlacesTask.h"

typedef void (^BMPlacesServiceArrayBlock)(NSArray *array);
typedef void (^BMPlacesServiceErrorBlock)(NSError *error);

@interface BMPlacesService : BMNetworkService

- (void)placesWithInput:(NSString *)input sessionToken:(GMSAutocompleteSessionToken *)sessionToken filter:(GMSAutocompleteFilter *)filter bounds:(GMSCoordinateBounds *)bounds boundsMode:(GMSAutocompleteBoundsMode)boundsMode successBlock:(BMPlacesServiceArrayBlock)successBlock failureBlock:(BMPlacesServiceErrorBlock)failureBlock;

@end
