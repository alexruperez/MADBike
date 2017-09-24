//
//  BMHeatmapRenderer.m
//  BiciMAD
//
//  Created by alexruperez on 7/6/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMHeatmapRenderer.h"

static MKZoomScale const kBMMinZoomScale = 0.0009765625f;

@implementation BMHeatmapRenderer

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    [super drawMapRect:mapRect zoomScale:MIN(kBMMinZoomScale, zoomScale) inContext:context];
}

@end
