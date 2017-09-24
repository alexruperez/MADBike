@import Foundation;
#import "GClusterAlgorithm.h"
#import "GQTPointQuadTree.h"

@interface NonHierarchicalDistanceBasedAlgorithm : NSObject<GClusterAlgorithm>

@property (nonatomic, assign) NSInteger maxDistanceAtZoom;
@property (nonatomic, strong) NSMutableArray *items;

- (instancetype)initWithMaxDistanceAtZoom:(NSInteger)maxDistanceAtZoom;

@end
