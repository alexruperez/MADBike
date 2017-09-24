//
//  MKAnnotationView+BMUtils.h
//  BiciMAD
//
//  Created by alexruperez on 8/9/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import MapKit;

@interface MKAnnotationView (BMUtils)

+ (MKAnnotationView *)bm_dequeueReusableAnnotationViewFromMapView:(MKMapView *)mapView;

+ (instancetype)bm_viewWithAnnotation:(id <MKAnnotation>)annotation;

@end
