#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CCHCenterOfMassMapClusterer.h"
#import "CCHFadeInOutMapAnimator.h"
#import "CCHMapAnimator.h"
#import "CCHMapClusterAnnotation.h"
#import "CCHMapClusterController.h"
#import "CCHMapClusterControllerDelegate.h"
#import "CCHMapClusterer.h"
#import "CCHNearCenterMapClusterer.h"

FOUNDATION_EXPORT double CCHMapClusterControllerVersionNumber;
FOUNDATION_EXPORT const unsigned char CCHMapClusterControllerVersionString[];

