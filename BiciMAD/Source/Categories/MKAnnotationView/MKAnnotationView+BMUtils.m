//
//  MKAnnotationView+BMUtils.m
//  BiciMAD
//
//  Created by alexruperez on 8/9/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "MKAnnotationView+BMUtils.h"

@import libextobjc;

@safecategory(MKAnnotationView, BMUtils)

+ (MKAnnotationView *)bm_dequeueReusableAnnotationViewFromMapView:(MKMapView *)mapView
{
    return [mapView dequeueReusableAnnotationViewWithIdentifier:self.bm_className];
}

+ (instancetype)bm_viewWithAnnotation:(id <MKAnnotation>)annotation
{
    return [[self alloc] initWithAnnotation:annotation reuseIdentifier:self.bm_className];
}

@end
