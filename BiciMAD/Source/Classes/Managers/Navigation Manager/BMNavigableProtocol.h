//
//  BMNavigableProtocol.h
//  BiciMAD
//
//  Created by alexruperez on 13/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import MapKit;
#import "GClusterItem.h"

typedef NS_ENUM(NSInteger, BMNavigation)
{
    BMNavigationNotDetermined = -1,
    BMNavigationAppleMaps,      // Preinstalled Apple Maps
    BMNavigationCitymapper,     // Citymapper
    BMNavigationGoogleMaps,     // Standalone Google Maps App
    BMNavigationNavigon,        // Navigon
    BMNavigationTransitApp,     // Transit App
    BMNavigationWaze,           // Waze
    BMNavigationYandex          // Yandex Navigator
};

static CLLocationDistance const kBMMetersToMiles = 0.000621371f;
static CLLocationDistance const kBMMetersToYards = 1.09361f;
static CLLocationDistance const kBMMetersToKilometers = 0.001f;

@protocol BMNavigable <MKAnnotation, GClusterItem>

@property (nonatomic, weak, readonly) NSString *URLScheme;
@property (nonatomic, weak, readonly) MKPlacemark *placemark;
@property (nonatomic, weak, readonly) MKMapItem *mapItem;
@property (nonatomic, assign, readonly) CLLocationDegrees latitude;
@property (nonatomic, assign, readonly) CLLocationDegrees longitude;
@property (nonatomic, assign) CLLocationDistance distance;

- (BOOL)openIn:(BMNavigation)navigation;

@end
