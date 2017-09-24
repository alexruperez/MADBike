//
//  SPGooglePlacesAutocompleteUtilities.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/18/12.
//  Modified by Shahar Hadas on 3/26/2014
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//  Copyright (c) 2014 Sparq. All rights reserved.
//

#import "SPGooglePlacesAutocompleteUtilities.h"

@implementation NSArray(SPFoundationAdditions)
- (id)onlyObject {
    return [self count] >= 1 ? self[0] : nil;
}
@end

NSArray *SPGooglePlacesAutocompletePlaceTypeNames(void)
{
    static NSMutableArray *names = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        names = [NSMutableArray array];

        [names insertObject:@"" atIndex:SPPlaceTypeAll];

        [names insertObject:@"geocode" atIndex:SPPlaceTypeGeocode];
	[names insertObject:@"address" atIndex:SPPlaceTypeAddress];
        [names insertObject:@"establishment" atIndex:SPPlaceTypeEstablishment];
        [names insertObject:@"(regions)" atIndex:SPPlaceTypeRegions];
        [names insertObject:@"(cities)" atIndex:SPPlaceTypeCities];
        [names insertObject:@"address" atIndex:SPPlaceTypeAddress];

    });

    return names;
}

SPGooglePlacesAutocompletePlaceType SPPlaceTypeFromDictionary(NSDictionary *placeDictionary) {
    NSUInteger index;

    for (NSString *type in placeDictionary[@"types"]) {
        index = [SPGooglePlacesAutocompletePlaceTypeNames() indexOfObject:type];

        if (index != NSNotFound) {
            return (SPGooglePlacesAutocompletePlaceType)index;
        }
    }

    return SPPlaceTypeGeocode;
}

NSString *SPBooleanStringForBool(BOOL boolean) {
    return boolean ? @"true" : @"false";
}

NSString *SPPlaceTypeStringForPlaceType(SPGooglePlacesAutocompletePlaceType type) {
    return [SPGooglePlacesAutocompletePlaceTypeNames() objectAtIndex:type];
}

extern BOOL SPIsEmptyString(NSString *string) {
    return !string || ![string length];
}
