//
//  BMPlacesTask.h
//  BiciMAD
//
//  Created by alexruperez on 22/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import CoreLocation;

#import "BMEMTServiceTask.h"

typedef NS_ENUM(NSInteger, BMPlacesTaskPlaceType) {
    BMPlacesTaskPlaceTypeAll,
    BMPlacesTaskPlaceTypeGeocode,
    BMPlacesTaskPlaceTypeAddress,
    BMPlacesTaskPlaceTypeEstablishment,
    BMPlacesTaskPlaceTypeRegions,
    BMPlacesTaskPlaceTypeCities
};

@interface BMPlacesTask : BMEMTServiceTask

+ (instancetype)taskWithApiKey:(NSString *)apiKey input:(NSString *)input sensor:(NSNumber *)sensor;

@property (nonatomic, assign) NSUInteger offset;

@property (nonatomic, assign) CLLocationCoordinate2D location;

@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, copy) NSString *language;

@property (nonatomic, assign) BMPlacesTaskPlaceType type;

@property (nonatomic, copy) NSString *countryCode;

@end
