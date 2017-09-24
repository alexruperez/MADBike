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

#import "DTMHeatmapRenderer.h"
#import "DTMDiffHeatmap.h"
#import "DTMHeatmap.h"
#import "DTMColorProvider.h"
#import "DTMDiffColorProvider.h"

FOUNDATION_EXPORT double DTMHeatmapVersionNumber;
FOUNDATION_EXPORT const unsigned char DTMHeatmapVersionString[];

