@import Foundation;
#import "GClusterItem.h"

@protocol GClusterAlgorithm <NSObject>

@property (nonatomic, assign) NSInteger maxDistanceAtZoom;
@property (nonatomic, strong) NSMutableArray *items;

- (void)addItem:(id <GClusterItem>) item;
- (void)removeItems;
- (void)removeItemsNotInRectangle:(CGRect)rect;

- (NSSet*)getClusters:(float)zoom;

@end
