@import Foundation;
@import CoreLocation;
@import GoogleMaps;

@protocol GClusterItem <NSObject>

@property (nonatomic, assign, readonly) CLLocationCoordinate2D position;

@property (nonatomic, strong) GMSMarker *marker;

@end
