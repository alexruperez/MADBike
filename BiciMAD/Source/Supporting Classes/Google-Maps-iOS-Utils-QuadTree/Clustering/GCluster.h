@import Foundation;
@import CoreLocation;
@import GoogleMaps;

@protocol GCluster <NSObject>

@property(nonatomic, assign, readonly) CLLocationCoordinate2D position;

@property(nonatomic, strong, readonly) NSSet *items;

@property(nonatomic, strong) GMSMarker *marker;

@end
