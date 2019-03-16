//
//  BMMapKitPresenter.m
//  BiciMAD
//
//  Created by alexruperez on 3/3/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMMapKitPresenter.h"

@import CCHMapClusterController;
@import SVPulsingAnnotationView;

#import "BMManagersAssembly.h"
#import "BMUserDefaultsManager.h"
#import "BMClusterAnnotationView.h"
#import "BMStationDetailCalloutAccessoryView.h"
#import "MKAnnotationView+BMUtils.h"
#import "BMStation.h"

static CGFloat const kBMStationsEdgeInset = 40.f;

@interface BMMapKitPresenter () <MKMapViewDelegate, CCHMapClusterControllerDelegate>

@property (nonatomic, strong) CCHMapClusterController *mapClusterController;
@property (nonatomic, assign, readonly) UIEdgeInsets mapEdgeInsets;
@property (nonatomic, assign) BOOL isRequestingLocationAuthorization;

@end

@implementation BMMapKitPresenter

- (instancetype)initWithDelegate:(id<BMMapPresenterDelegate>)delegate mapView:(MKMapView *)mapView
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

- (CCHMapClusterController *)mapClusterController
{
    if (!_mapClusterController)
    {
        _mapClusterController = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
        _mapClusterController.delegate = self;
    }
    
    return _mapClusterController;
}

- (UIEdgeInsets)mapEdgeInsets
{
    return UIEdgeInsetsMake(kBMStationsEdgeInset, kBMStationsEdgeInset, kBMStationsEdgeInset * 2.f, kBMStationsEdgeInset);
}

- (NSSet *)annotations
{
    return self.mapClusterController.annotations;
}

- (NSSet *)selectedAnnotations
{
    return [NSSet setWithArray:self.mapView.selectedAnnotations];
}

- (CLLocation *)location
{
    return self.mapView.userLocation.location;
}

- (CLLocationCoordinate2D)centerCoordinate
{
    return self.mapView.centerCoordinate;
}

- (void)mapViewLoaded
{}

- (void)updateMapOptions
{
    self.mapView.showsCompass = [self.managersAssembly.userDefaultsManager storedBoolForKey:kBMUserDefaultsCompassKey];
    self.mapView.showsScale = [self.managersAssembly.userDefaultsManager storedBoolForKey:kBMUserDefaultsScaleKey];
    self.mapView.showsPointsOfInterest = [self.managersAssembly.userDefaultsManager storedBoolForKey:kBMUserDefaultsPointsOfInterestKey];
    self.mapView.showsBuildings = [self.managersAssembly.userDefaultsManager storedBoolForKey:kBMUserDefaultsBuildingsKey];
    self.mapClusterController.maxZoomLevelForClustering = [self.managersAssembly.userDefaultsManager storedBoolForKey:kBMUserDefaultsClusteringKey] ? DBL_MAX : 0;
    self.mapView.showsTraffic = [self.managersAssembly.userDefaultsManager storedBoolForKey:kBMUserDefaultsTrafficKey];
    
    NSString *mapType = [self.managersAssembly.userDefaultsManager storedStringForKey:kBMUserDefaultsMapTypeKey];
    
    if ([mapType isEqualToString:kBMUserDefaultsMapTypeStandardValue])
    {
        self.mapView.mapType = MKMapTypeStandard;
    }
    else if ([mapType isEqualToString:kBMUserDefaultsMapTypeSatelliteValue])
    {
        self.mapView.mapType = MKMapTypeSatellite;
    }
    else if ([mapType isEqualToString:kBMUserDefaultsMapTypeHybridValue])
    {
        self.mapView.mapType = MKMapTypeHybrid;
    }
    
    if (CLLocationManager.authorizationStatus >= kCLAuthorizationStatusAuthorizedAlways)
    {
        self.isRequestingLocationAuthorization = YES;
        self.mapView.showsUserLocation = YES;
    }
}

- (void)showUserLocation:(id)sender
{
    if (CLLocationManager.authorizationStatus < kCLAuthorizationStatusAuthorizedAlways)
    {
        self.isRequestingLocationAuthorization = YES;
        [self.delegate locationPermissionsNeeded:nil];
    }
    
    self.mapView.showsUserLocation = YES;
    
    if (self.mapView.userTrackingMode != MKUserTrackingModeFollow)
    {
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    }
    else
    {
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    }
}

- (void)showCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
    if (CLLocationCoordinate2DIsValid(coordinate) && (coordinate.latitude > 0.f || coordinate.longitude > 0.f))
    {
        [self.mapView setCenterCoordinate:coordinate animated:animated];
    }
}

- (void)setVisibleMapAnnotations:(id)annotations animated:(BOOL)animated
{
    MKMapRect zoomRect = MKMapRectNull;
    for (id<MKAnnotation> annotation in annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1f, 0.1f);
        if (MKMapRectIsNull(zoomRect))
        {
            zoomRect = pointRect;
        }
        else
        {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    if (!MKMapRectIsEmpty(zoomRect))
    {
        [self.mapView setVisibleMapRect:zoomRect edgePadding:self.mapEdgeInsets animated:animated];
    }
}

- (MKMapRect)mapRectForCircularRegion:(CLCircularRegion *)circularRegion
{
    MKCoordinateRegion region =  MKCoordinateRegionMakeWithDistance(circularRegion.center, circularRegion.radius * 2.f, circularRegion.radius * 2.f);
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta / 2.f, region.center.longitude - region.span.longitudeDelta / 2.f));
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta / 2.f, region.center.longitude + region.span.longitudeDelta / 2.f));
    return MKMapRectMake(MIN(a.x,b.x), MIN(a.y,b.y), ABS(a.x-b.x), ABS(a.y-b.y));
}

- (void)setVisibleCircularRegion:(CLCircularRegion *)circularRegion animated:(BOOL)animated
{
    MKMapRect mapRect = [self mapRectForCircularRegion:circularRegion];
    if (!MKMapRectIsEmpty(mapRect))
    {
        [self.mapView setVisibleMapRect:mapRect edgePadding:self.mapEdgeInsets animated:YES];
    }
}

- (void)addAnnotations:(NSArray *)annotations withCompletionHandler:(void (^)(void))completionHandler
{
    NSMutableArray *navigableAnnotations = NSMutableArray.new;
    for (id<BMNavigable> annotation in annotations)
    {
        if ([annotation conformsToProtocol:@protocol(BMNavigable)])
        {
            [navigableAnnotations addObject:annotation];
        }
    }
    [self.mapClusterController addAnnotations:navigableAnnotations.copy withCompletionHandler:completionHandler];
}

- (void)removeAnnotations:(NSArray *)annotations withCompletionHandler:(void (^)(void))completionHandler
{
    [self.mapClusterController removeAnnotations:annotations withCompletionHandler:completionHandler];
}

- (void)clearAllAnnotations:(void (^)(void))completionHandler
{
    [self removeAnnotations:self.annotations.allObjects withCompletionHandler:completionHandler];
}

- (void)selectAnnotation:(id)annotation andZoomToRegionWithLatitudinalMeters:(CLLocationDistance)latitudinalMeters longitudinalMeters:(CLLocationDistance)longitudinalMeters
{
    [self.mapClusterController selectAnnotation:annotation andZoomToRegionWithLatitudinalMeters:latitudinalMeters longitudinalMeters:longitudinalMeters];
}

- (id)uniqueLocationAnnotation:(id)annotation
{
    if ([annotation isKindOfClass:CCHMapClusterAnnotation.class])
    {
        CCHMapClusterAnnotation *clusterAnnotation = annotation;
        if (clusterAnnotation.isUniqueLocation)
        {
            return clusterAnnotation.annotations.anyObject;
        }
    }
    
    return annotation;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView;
    
    if ([annotation isKindOfClass:CCHMapClusterAnnotation.class])
    {
        CCHMapClusterAnnotation *mapClusterAnnotation = annotation;
        BMClusterAnnotationView *clusterAnnotationView = (BMClusterAnnotationView *)[BMClusterAnnotationView bm_dequeueReusableAnnotationViewFromMapView:mapView];
        if (clusterAnnotationView)
        {
            clusterAnnotationView.annotation = annotation;
        }
        else
        {
            clusterAnnotationView = [BMClusterAnnotationView bm_viewWithAnnotation:annotation];
            UIButton *rightCalloutAccessoryButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightCalloutAccessoryButton setImage:UIImage.new forState:UIControlStateNormal];
            clusterAnnotationView.rightCalloutAccessoryView = rightCalloutAccessoryButton;
            clusterAnnotationView.rightCalloutAccessoryView.tintColor = UIColor.bm_tintColor;
            clusterAnnotationView.rightCalloutAccessoryView.accessibilityLabel = NSLocalizedString(@"More details", @"More details");
        }
        
        if (mapClusterAnnotation.isUniqueLocation)
        {
            clusterAnnotationView.canShowCallout = YES;
            BMStationDetailCalloutAccessoryView *stationDetailCalloutAccessoryView = nil;
            id annotationObject = mapClusterAnnotation.annotations.anyObject;
            if ([annotationObject isKindOfClass:BMStation.class] && [annotationObject active] && ![annotationObject unavailable])
            {
                stationDetailCalloutAccessoryView = BMStationDetailCalloutAccessoryView.new;
                stationDetailCalloutAccessoryView.station = annotationObject;
            }
            clusterAnnotationView.detailCalloutAccessoryView = stationDetailCalloutAccessoryView;
        }
        else
        {
            clusterAnnotationView.canShowCallout = NO;
            clusterAnnotationView.detailCalloutAccessoryView = nil;
        }
        
        [clusterAnnotationView setNeedsLayout];
        
        annotationView = clusterAnnotationView;
    }
    else if([annotation isKindOfClass:MKUserLocation.class])
    {
        SVPulsingAnnotationView *userAnnotationView = (SVPulsingAnnotationView *)[SVPulsingAnnotationView bm_dequeueReusableAnnotationViewFromMapView:mapView];
        if (!userAnnotationView)
        {
            userAnnotationView = [SVPulsingAnnotationView bm_viewWithAnnotation:annotation];
            userAnnotationView.annotationColor = UIColor.bm_tintColor;
        }
        
        userAnnotationView.canShowCallout = YES;
        
        annotationView = userAnnotationView;
    }
    
    return annotationView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    polylineRenderer.strokeColor = [UIColor.bm_tintColor colorWithAlphaComponent:0.5f];
    return polylineRenderer;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:CCHMapClusterAnnotation.class])
    {
        CCHMapClusterAnnotation *mapClusterAnnotation = view.annotation;
        if (mapClusterAnnotation.isUniqueLocation)
        {
            [self.delegate presentAnnotationsDetail:mapClusterAnnotation.annotations.allObjects titleString:nil animated:YES];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:CCHMapClusterAnnotation.class])
    {
        CCHMapClusterAnnotation *mapClusterAnnotation = view.annotation;
        if (!mapClusterAnnotation.isUniqueLocation && !MKMapRectIsEmpty(mapClusterAnnotation.mapRect))
        {
            [mapView setVisibleMapRect:mapClusterAnnotation.mapRect edgePadding:self.mapEdgeInsets animated:YES];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.isRequestingLocationAuthorization = NO;
    
    if (userLocation.location && CLLocationCoordinate2DIsValid(userLocation.location.coordinate))
    {
        [self.delegate didUpdateUserLocation:userLocation.location];
    }
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    [self.delegate didFinishRenderingMap:fullyRendered];
}

#pragma mark - CCHMapClusterControllerDelegate

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController titleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    if (mapClusterAnnotation.isUniqueLocation)
    {
        return [mapClusterAnnotation.annotations.anyObject title];
    }
    
    return [NSString stringWithFormat:NSLocalizedString(@"%ld Stations", @"%ld Stations"), mapClusterAnnotation.annotations.count];
}

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController subtitleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    if (mapClusterAnnotation.isUniqueLocation)
    {
        return [mapClusterAnnotation.annotations.anyObject subtitle];
    }
    
    return nil;
}

- (void)mapClusterController:(CCHMapClusterController *)mapClusterController willReuseMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    MKAnnotationView *annotationView = [self.mapView viewForAnnotation:mapClusterAnnotation];
    
    annotationView.canShowCallout = mapClusterAnnotation.isUniqueLocation;
    
    [annotationView setNeedsLayout];
}

@end
