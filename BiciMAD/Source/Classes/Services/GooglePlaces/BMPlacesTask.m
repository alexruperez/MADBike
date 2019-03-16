//
//  BMPlacesTask.m
//  BiciMAD
//
//  Created by alexruperez on 22/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMPlacesTask.h"

@import GooglePlaces;

@interface BMPlacesTask ()

@property (nonatomic, copy) NSString *input;
@property (nonatomic, copy) GMSAutocompleteSessionToken *sessionToken;
@property (nonatomic, copy) GMSAutocompleteFilter *filter;

@end

@implementation BMPlacesTask

+ (instancetype)taskWithHTTPClient:(BMHTTPClient *)HTTPClient
{
    [NSException raise:NSInvalidArgumentException format:@"%@ class uses %@ initializer!", self.bm_className, NSStringFromSelector(@selector(taskWithInput:sessionToken:filter:))];
    return nil;
}

+ (instancetype)taskWithInput:(NSString *)input sessionToken:(GMSAutocompleteSessionToken *)sessionToken filter:(GMSAutocompleteFilter *)filter
{
    return [[self alloc] initWithInput:input sessionToken:sessionToken filter:filter];
}

- (instancetype)initWithInput:(NSString *)input sessionToken:(GMSAutocompleteSessionToken *)sessionToken filter:(GMSAutocompleteFilter *)filter
{
    self = super.init;
    
    if (self)
    {
        _input = input;
        _sessionToken = sessionToken;
        _filter = filter;
    }
    
    return self;
}

- (void)executeInBackground:(BOOL)background
{
    [GMSPlacesClient.sharedClient findAutocompletePredictionsFromQuery:self.input bounds:self.bounds boundsMode:self.boundsMode filter:self.filter sessionToken:self.sessionToken callback:^(NSArray<GMSAutocompletePrediction *> * _Nullable results, NSError * _Nullable error) {
        if (results != nil && self.successBlock) {
            self.successBlock(results);
        }
        else if (self.failureBlock)
        {
            self.failureBlock(error);
        }
    }];
}

@end
