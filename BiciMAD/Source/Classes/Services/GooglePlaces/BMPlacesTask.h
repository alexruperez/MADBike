//
//  BMPlacesTask.h
//  BiciMAD
//
//  Created by alexruperez on 22/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import GooglePlaces;

#import "BMEMTServiceTask.h"

@interface BMPlacesTask : BMEMTServiceTask

+ (instancetype)taskWithInput:(NSString *)input sessionToken:(GMSAutocompleteSessionToken *)sessionToken filter:(GMSAutocompleteFilter *)filter;

@property (nonatomic, copy) GMSCoordinateBounds *bounds;

@property (nonatomic, assign) GMSAutocompleteBoundsMode boundsMode;

@end
