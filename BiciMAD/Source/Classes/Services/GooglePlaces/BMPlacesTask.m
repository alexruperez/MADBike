//
//  BMPlacesTask.m
//  BiciMAD
//
//  Created by alexruperez on 22/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMPlacesTask.h"

@import SPGooglePlacesAutocomplete;

@interface SPGooglePlacesAutocompleteQuery (BMCancelTask)

- (void)cancelOutstandingRequests;

@end

@interface BMPlacesTask ()

@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic, copy) NSString *input;
@property (nonatomic, assign) BOOL sensor;
@property (nonatomic, strong) SPGooglePlacesAutocompleteQuery *query;

@end

@implementation BMPlacesTask

+ (instancetype)taskWithHTTPClient:(BMHTTPClient *)HTTPClient
{
    [NSException raise:NSInvalidArgumentException format:@"%@ class uses %@ initializer!", self.bm_className, NSStringFromSelector(@selector(taskWithApiKey:input:sensor:))];
    return nil;
}

+ (instancetype)taskWithApiKey:(NSString *)apiKey input:(NSString *)input sensor:(NSNumber *)sensor
{
    return [[self alloc] initWithApiKey:apiKey input:input sensor:sensor];
}

- (instancetype)initWithApiKey:(NSString *)apiKey input:(NSString *)input sensor:(NSNumber *)sensor
{
    self = super.init;
    
    if (self)
    {
        _apiKey = apiKey;
        _input = input;
        _sensor = sensor.boolValue;
    }
    
    return self;
}

- (void)executeInBackground:(BOOL)background
{
    self.query = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:self.apiKey];
    
    self.query.input = self.input;
    self.query.sensor = self.sensor;
    self.query.offset = self.offset;
    self.query.location = self.location;
    self.query.radius = self.radius;
    self.query.language = self.language;
    self.query.countryCode = self.countryCode;
    self.query.types = (SPGooglePlacesAutocompletePlaceType)self.type;
    
    [self.query fetchPlaces:^(NSArray *places, NSError *error) {
        if (!error)
        {
            if (self.successBlock)
            {
                self.successBlock(places);
            }
        }
        else if (self.failureBlock)
        {
            self.failureBlock(error);
        }
    }];
}

- (void)cancel
{
    [self.query cancelOutstandingRequests];
    self.query = nil;
}

@end
