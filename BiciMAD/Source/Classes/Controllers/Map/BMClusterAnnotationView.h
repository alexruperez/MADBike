//
//  BMClusterAnnotationView.h
//  BiciMAD
//
//  Created by alexruperez on 20/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import MapKit;

#import "GCluster.h"

@interface BMClusterAnnotationView : MKAnnotationView

@property (nonatomic, strong) id<GCluster> mapClusterAnnotation;
@property (nonatomic, strong, readonly) UIImage *annotationImage;

@end
