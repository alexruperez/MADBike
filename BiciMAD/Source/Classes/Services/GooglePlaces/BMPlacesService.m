//
//  BMPlacesService.m
//  BiciMAD
//
//  Created by alexruperez on 22/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMPlacesService.h"

#import "BMServicesAssembly.h"

static NSString * const kBMPlacesCountryCode = @"es";

@interface BMPlacesService ()

@property (nonatomic, strong) BMPlacesTask *task;

@end

@implementation BMPlacesService

- (void)placesWithInput:(NSString *)input sessionToken:(GMSAutocompleteSessionToken *)sessionToken filter:(GMSAutocompleteFilter *)filter bounds:(GMSCoordinateBounds *)bounds boundsMode:(GMSAutocompleteBoundsMode)boundsMode successBlock:(BMPlacesServiceArrayBlock)successBlock failureBlock:(BMPlacesServiceErrorBlock)failureBlock
{
    [self.task cancel];
    
    self.task = [self.servicesAssembly placesTaskWithInput:input sessionToken:sessionToken filter:filter];

    self.task.bounds = bounds;

    self.task.boundsMode = boundsMode;
    
    [self.task setSuccessBlock:successBlock];
    
    [self.task setFailureBlock:failureBlock];
    
    [self.task execute];
}

@end
