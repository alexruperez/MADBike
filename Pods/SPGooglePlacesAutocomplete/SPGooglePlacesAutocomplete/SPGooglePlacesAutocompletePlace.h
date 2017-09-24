//
//  SPGooglePlacesAutocompletePlace.h
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "SPGooglePlacesAutocompleteUtilities.h"

@interface SPGooglePlacesAutocompletePlace : NSObject {
    CLGeocoder *geocoder;
}

+ (SPGooglePlacesAutocompletePlace *)placeFromDictionary:(NSDictionary *)placeDictionary apiKey:(NSString *)apiKey;

/*!
 Contains the human-readable name for the returned result. For establishment results, this is usually the business name.
 */
@property (nonatomic, strong, readonly) NSString *name;

/*!
 Contains the primary 'type' of this place (i.e. "establishment" or "gecode").
 */
@property (nonatomic, readonly) SPGooglePlacesAutocompletePlaceType type;

/*!
 Contains a unique stable identifier denoting this place. This identifier may not be used to retrieve information about this place, but can be used to consolidate data about this Place, and to verify the identity of a Place across separate searches.
 */
@property (nonatomic, strong, readonly) NSString *placeId;

/*!
 Your application's API key. This key identifies your application for purposes of quota management. Visit the APIs Console to select an API Project and obtain your key. Maps API for Business customers must use the API project created for them as part of their Places for Business purchase. Defaults to kGoogleAPIKey.
 */
@property (nonatomic, strong) NSString *key;

/*!
 Contains the separate terms that make up the returned result's name
 */
@property (nonatomic, strong, readonly) NSArray *terms;

/*!
 Resolves the place to a CLPlacemark, issuing  Google Place Details request if needed.
 */
- (void)resolveToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block;

@end
