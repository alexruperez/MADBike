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

- (void)placesWithInput:(NSString *)input sensor:(BOOL)sensor location:(CLLocationCoordinate2D)location radius:(CGFloat)radius offset:(NSUInteger)offset type:(BMPlacesTaskPlaceType)type successBlock:(BMPlacesServiceArrayBlock)successBlock failureBlock:(BMPlacesServiceErrorBlock)failureBlock
{
    [self.task cancel];
    
    self.task = [self.servicesAssembly placesTaskWithInput:input sensor:@(sensor)];
    
    self.task.location = location;
    
    self.task.radius = radius;
    
    self.task.offset = offset;
    
    self.task.language = [NSLocale.autoupdatingCurrentLocale objectForKey:NSLocaleLanguageCode];
    
    self.task.countryCode = kBMPlacesCountryCode;
    
    self.task.type = type;
    
    [self.task setSuccessBlock:successBlock];
    
    [self.task setFailureBlock:failureBlock];
    
    [self.task execute];
}

@end
