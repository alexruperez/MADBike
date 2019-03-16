//
//  BMGoogleMapsPresenter.m
//  BiciMAD
//
//  Created by alexruperez on 3/3/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMGoogleMapsPresenter.h"

@import INTULocationManager;

#import "BMManagersAssembly.h"
#import "BMUserDefaultsManager.h"
#import "BMStationDetailMarkerInfoContentsView.h"
#import "BMStation.h"
#import "GCluster.h"
#import "GClusterManager.h"
#import "BMNavigableProtocol.h"
#import "GDefaultClusterRenderer.h"
#import "NonHierarchicalDistanceBasedAlgorithm.h"

static CGFloat const kBMStationsEdgeInset = 40.f;
static CLLocationDistance const kBMUserLocationZoom = 100.f;

@interface BMGoogleMapsPresenter () <GMSMapViewDelegate>

@property (nonatomic, strong) INTULocationManager *locationManager;

@property (nonatomic, strong) GClusterManager *clusterManager;
@property (nonatomic, strong) id<GClusterAlgorithm> clusterAlgorithm;
@property (nonatomic, strong) id<GClusterRenderer> clusterRenderer;

@property (nonatomic, assign, readonly) UIEdgeInsets mapEdgeInsets;

@end

@implementation BMGoogleMapsPresenter

- (instancetype)initWithDelegate:(id<BMMapPresenterDelegate>)delegate mapView:(GMSMapView *)mapView
{
    self = [super init];
    
    if (self)
    {
        _delegate = delegate;
        _mapView = mapView;
        _mapView.delegate = self;
    }
    
    return self;
}

- (INTULocationManager *)locationManager
{
    if (!_locationManager)
    {
        _locationManager = INTULocationManager.sharedInstance;
    }
    
    return _locationManager;
}

- (id<GClusterAlgorithm>)clusterAlgorithm
{
    if (!_clusterAlgorithm)
    {
        _clusterAlgorithm = NonHierarchicalDistanceBasedAlgorithm.new;
    }
    
    return _clusterAlgorithm;
}

- (id<GClusterRenderer>)clusterRenderer
{
    if (!_clusterRenderer)
    {
        _clusterRenderer = [[GDefaultClusterRenderer alloc] initWithMapView:self.mapView];
    }
    
    return _clusterRenderer;
}

- (GClusterManager *)clusterManager
{
    if (!_clusterManager)
    {
        _clusterManager = [GClusterManager managerWithMapView:self.mapView algorithm:self.clusterAlgorithm renderer:self.clusterRenderer];
    }
    
    return _clusterManager;
}

- (UIEdgeInsets)mapEdgeInsets
{
    return UIEdgeInsetsMake(kBMStationsEdgeInset, kBMStationsEdgeInset, kBMStationsEdgeInset * 2.f, kBMStationsEdgeInset);
}

- (NSSet *)annotations
{
    return [NSSet setWithArray:self.clusterManager.items];
}

- (NSSet *)selectedAnnotations
{
    if (self.mapView.selectedMarker.userData)
    {
        return [NSSet setWithObject:self.mapView.selectedMarker.userData];
    }
    
    return NSSet.set;
}

- (CLLocation *)location
{
    return self.mapView.myLocation;
}

- (CLLocationCoordinate2D)centerCoordinate
{
    CLLocationCoordinate2D coordinate = self.mapView.camera.target;
    
    if (!CLLocationCoordinate2DIsValid(coordinate) || !(coordinate.latitude > 0.f || coordinate.longitude > 0.f))
    {
        coordinate = CLLocationCoordinate2DMake(40.4169743f, -3.7058546f);
        CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordinate radius:kBMUserLocationZoom identifier:@"Madrid"];
        [self setVisibleCircularRegion:region animated:NO];
    }
    
    return coordinate;
}

- (void)mapViewLoaded
{}

- (void)updateMapOptions
{
    self.mapView.accessibilityElementsHidden = NO;
    self.mapView.settings.indoorPicker = NO;
    self.mapView.settings.compassButton = [self.managersAssembly.userDefaultsManager storedBoolForKey:kBMUserDefaultsCompassKey];
    self.mapView.buildingsEnabled = [self.managersAssembly.userDefaultsManager storedBoolForKey:kBMUserDefaultsBuildingsKey];
    self.clusterAlgorithm.maxDistanceAtZoom = [self.managersAssembly.userDefaultsManager storedBoolForKey:kBMUserDefaultsClusteringKey] ? 50 : 0;
    self.mapView.trafficEnabled = [self.managersAssembly.userDefaultsManager storedBoolForKey:kBMUserDefaultsTrafficKey];
    
    NSString *mapType = [self.managersAssembly.userDefaultsManager storedStringForKey:kBMUserDefaultsMapTypeKey];
    
    if ([mapType isEqualToString:kBMUserDefaultsMapTypeStandardValue])
    {
        self.mapView.mapType = kGMSTypeNormal;
    }
    else if ([mapType isEqualToString:kBMUserDefaultsMapTypeSatelliteValue])
    {
        self.mapView.mapType = kGMSTypeSatellite;
    }
    else if ([mapType isEqualToString:kBMUserDefaultsMapTypeHybridValue])
    {
        self.mapView.mapType = kGMSTypeHybrid;
    }
    
    if (CLLocationManager.authorizationStatus >= kCLAuthorizationStatusAuthorizedAlways)
    {
        self.mapView.myLocationEnabled = YES;
    }
    
    self.mapView.preferredFrameRate = NSProcessInfo.processInfo.isLowPowerModeEnabled ? kGMSFrameRatePowerSave : kGMSFrameRateMaximum;
}

- (void)showUserLocation:(id)sender
{
    CLLocationCoordinate2D coordinate = self.location.coordinate;
    
    if (self.location && CLLocationCoordinate2DIsValid(coordinate) && (coordinate.latitude > 0.f || coordinate.longitude > 0.f))
    {
        [self showCoordinate:coordinate zoom:kBMUserLocationZoom animated:YES];
    }
    else
    {
        @weakify(self)
        [self.delegate locationPermissionsNeeded:^(BOOL success) {
            if (success)
            {
                @strongify(self)
                [self.locationManager requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:10.f delayUntilAuthorized:YES block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                    @strongify(self)
                    if (currentLocation && status == INTULocationStatusSuccess)
                    {
                        self.mapView.myLocationEnabled = YES;
                        [self showCoordinate:currentLocation.coordinate zoom:kBMUserLocationZoom animated:YES];
                        [self.delegate didUpdateUserLocation:currentLocation];
                    }
                }];
            }
        }];
    }
}

- (void)showCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
    [self showCoordinate:coordinate zoom:kBMUserLocationZoom animated:YES];
}

- (void)showCoordinate:(CLLocationCoordinate2D)coordinate zoom:(CLLocationDistance)zoom animated:(BOOL)animated
{
    if (CLLocationCoordinate2DIsValid(coordinate) && (coordinate.latitude > 0.f || coordinate.longitude > 0.f) && zoom > 0.f)
    {
        GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:coordinate zoom:[GMSCameraPosition zoomAtCoordinate:coordinate forMeters:zoom perPoints:(CGFloat)zoom]];

        if (animated)
        {
            [self.mapView animateToCameraPosition:cameraPosition];
        }
        else
        {
            self.mapView.camera = cameraPosition;
        }
    }
}

- (void)setVisibleMapAnnotations:(id)annotations animated:(BOOL)animated
{
    GMSCoordinateBounds *bounds = GMSCoordinateBounds.new;
    for (id<GCluster> annotation in annotations)
    {
        bounds = [bounds includingCoordinate:annotation.position];
    }
    
    if (bounds.isValid)
    {
        GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate fitBounds:bounds withEdgeInsets:self.mapEdgeInsets];
        
        @weakify(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self)
            if (animated)
            {
                [self.mapView animateWithCameraUpdate:cameraUpdate];
            }
            else
            {
                [self.mapView moveCamera:cameraUpdate];
            }
        });
    }
}

- (void)setVisibleCircularRegion:(CLCircularRegion *)circularRegion animated:(BOOL)animated
{
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:circularRegion.center zoom:[GMSCameraPosition zoomAtCoordinate:circularRegion.center forMeters:circularRegion.radius perPoints:(CGFloat)circularRegion.radius]];
    
    if (animated)
    {
        [self.mapView animateToCameraPosition:cameraPosition];
    }
    else
    {
        self.mapView.camera = cameraPosition;
    }
}

- (void)addAnnotations:(NSArray *)annotations withCompletionHandler:(void (^)(void))completionHandler
{
    for (id<BMNavigable> annotation in annotations)
    {
        if ([annotation conformsToProtocol:@protocol(BMNavigable)])
        {
            GMSMarker *marker = [GMSMarker markerWithPosition:annotation.position];
            marker.appearAnimation = kGMSMarkerAnimationNone;
            marker.tracksViewChanges = YES;
            marker.tracksInfoWindowChanges = YES;
            marker.infoWindowAnchor = CGPointMake(0.5f, 0.1f);
            marker.title = annotation.title;
            marker.snippet = annotation.subtitle;
            marker.userData = annotation;
            
            annotation.marker = marker;
            
            [self.clusterManager addItem:annotation];
        }
    }
    
    [self.clusterManager clusterWithCompletionHandler:completionHandler];
}

- (void)clearAllAnnotations:(void (^)(void))completionHandler
{
    [self.clusterManager removeItems];
    
    [self.clusterManager clusterWithCompletionHandler:completionHandler];
}

- (void)selectAnnotation:(id<GCluster>)annotation andZoomToRegionWithLatitudinalMeters:(CLLocationDistance)latitudinalMeters longitudinalMeters:(CLLocationDistance)longitudinalMeters
{
    self.mapView.selectedMarker = annotation.marker;
}

- (id)uniqueLocationAnnotation:(id<GCluster>)annotation
{
    if ([annotation conformsToProtocol:@protocol(GCluster)])
    {
        if (annotation.items.count == 1)
        {
            return annotation.items.anyObject;
        }
    }
    
    return annotation;
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    if ([self.clusterManager respondsToSelector:@selector(mapView:idleAtCameraPosition:)])
    {
        [self.clusterManager mapView:mapView idleAtCameraPosition:position];
    }
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    if ([marker.userData conformsToProtocol:@protocol(GCluster)])
    {
        id<GCluster> mapClusterAnnotation = marker.userData;
        if (mapClusterAnnotation.items.count > 1)
        {
            [self setVisibleMapAnnotations:mapClusterAnnotation.items animated:YES];
            return YES;
        }
    }
    
    return NO;
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoContents:(GMSMarker *)marker
{
    BMStationDetailMarkerInfoContentsView *stationDetailMarkerInfoContentsView = nil;
    id markerObject = marker.userData;
    if ([markerObject isKindOfClass:BMStation.class] && [markerObject active] && ![markerObject unavailable])
    {
        stationDetailMarkerInfoContentsView = BMStationDetailMarkerInfoContentsView.new;
        stationDetailMarkerInfoContentsView.station = markerObject;
    }
    
    return stationDetailMarkerInfoContentsView;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    if (marker.userData)
    {
        [self.delegate presentAnnotationsDetail:@[marker.userData] titleString:nil animated:YES];
    }
}

- (void)mapViewDidFinishTileRendering:(GMSMapView *)mapView
{
    [self.delegate didFinishRenderingMap:YES];
}

@end
