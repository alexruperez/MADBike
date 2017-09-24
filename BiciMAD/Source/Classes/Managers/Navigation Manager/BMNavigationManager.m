//
//  BMNavigationManager.m
//  BiciMAD
//
//  Created by alexruperez on 13/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMNavigationManager.h"

@import OpenInGoogleMaps;
@import CMMapLauncher;

static NSString * const kBMNavigationManagerReferrer = @"madbike";

@implementation BMNavigationManager

+ (BOOL)open:(id<BMNavigable>)navigable inNavigation:(BMNavigation)navigation
{
    if (navigation == BMNavigationGoogleMaps)
    {
        OpenInGoogleMapsController *openInGoogleMapsController = OpenInGoogleMapsController.sharedInstance;
        NSURL *callbackURL = [NSURL URLWithString:navigable.URLScheme];
        openInGoogleMapsController.callbackURL = callbackURL;
        openInGoogleMapsController.fallbackStrategy = kGoogleMapsFallbackAppleMaps;
        
        GoogleDirectionsDefinition *definition = GoogleDirectionsDefinition.new;
        definition.destinationPoint = [GoogleDirectionsWaypoint waypointWithLocation:navigable.coordinate];
        definition.travelMode = kGoogleMapsTravelModeBiking;
        
        return [openInGoogleMapsController openDirections:definition];
    }
    else if (navigation != BMNavigationNotDetermined)
    {
        CMMapApp mapApp = (CMMapApp)navigation;
        if ([CMMapLauncher isMapAppInstalled:mapApp])
        {
            CMMapPoint *mapPoint = [CMMapPoint mapPointWithName:navigable.title address:navigable.subtitle coordinate:navigable.coordinate];
            return [CMMapLauncher launchMapApp:mapApp forDirectionsFrom:[CMMapPoint currentLocation] to:mapPoint referrer:kBMNavigationManagerReferrer];
        }
        
        return [navigable.mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking}];
    }
    
    return NO;
}

@end
