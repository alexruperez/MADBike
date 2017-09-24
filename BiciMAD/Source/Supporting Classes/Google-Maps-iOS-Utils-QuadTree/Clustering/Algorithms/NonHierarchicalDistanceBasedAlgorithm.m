@import GoogleMaps;
#import "NonHierarchicalDistanceBasedAlgorithm.h"
#import "GStaticCluster.h"

@implementation NonHierarchicalDistanceBasedAlgorithm
{
    GQTPointQuadTree *_quadTree;
}

- (instancetype)initWithMaxDistanceAtZoom:(NSInteger)aMaxDistanceAtZoom
{
    self = super.init;
    
    if (self)
    {
        _items = NSMutableArray.new;
        _quadTree = [[GQTPointQuadTree alloc] initWithBounds:(GQTBounds){0,0,1,1}];
        _maxDistanceAtZoom = aMaxDistanceAtZoom;
    }
    
    return self;
}

- (instancetype)init
{
    return [self initWithMaxDistanceAtZoom:50];
}

- (void)addItem:(id<GClusterItem>)item
{
    GQuadItem *quadItem = [[GQuadItem alloc] initWithItem:item];
    [_items addObject:quadItem];
    [_quadTree add:quadItem];
}

- (void)removeItems
{
  [_items removeAllObjects];
  [_quadTree clear];
}

- (void)removeItemsNotInRectangle:(CGRect)rect
{
    NSMutableArray *newItems = NSMutableArray.new;
    [_quadTree clear];
    
    for (GQuadItem *item in _items)
    {
        if (CGRectContainsPoint(rect, CGPointMake((CGFloat)item.position.latitude, (CGFloat)item.position.longitude)))
        {
            [newItems addObject:item];
            [_quadTree add:item];
        }
    }
    
    _items = newItems;
}

- (NSSet*)getClusters:(float)zoom
{
    int discreteZoom = (int)zoom;
    
    double zoomSpecificSpan = self.maxDistanceAtZoom / pow(2, discreteZoom) / 256;
    
    NSMutableSet *visitedCandidates = NSMutableSet.new;
    NSMutableSet *results = NSMutableSet.new;
    NSMutableDictionary *distanceToCluster = NSMutableDictionary.new;
    NSMutableDictionary *itemToCluster = NSMutableDictionary.new;
    
    for (GQuadItem *candidate in _items)
    {
        if (candidate.hidden)
        {
            continue;
        }
        
        if ([visitedCandidates containsObject:candidate])
        {
            // Candidate is already part of another cluster.
            continue;
        }
        
        GQTBounds bounds = [self createBoundsFromSpan:candidate.point span:zoomSpecificSpan];
        NSArray *clusterItems  = [_quadTree searchWithBounds:bounds];
        if (clusterItems.count == 1)
        {
            // Only the current marker is in range. Just add the single item to the results.
            [results addObject:candidate];
            [visitedCandidates addObject:candidate];
            distanceToCluster[candidate] = @0.f;
            continue;
        }
        
        GStaticCluster *cluster = [[GStaticCluster alloc] initWithCoordinate:candidate.position andMarker:candidate.marker];
        [results addObject:cluster];
        
        for (GQuadItem *clusterItem in clusterItems)
        {
            if (clusterItem.hidden)
            {
                continue;
            }
            NSNumber *existingDistance = distanceToCluster[clusterItem];
            double distance = [self distanceSquared:clusterItem.point :candidate.point];
            if (existingDistance != nil)
            {
                // Item already belongs to another cluster. Check if it's closer to this cluster.
                if ([existingDistance doubleValue] < distance)
                {
                    continue;
                }
                
                // Move item to the closer cluster.
                GStaticCluster *oldCluster = itemToCluster[clusterItem];
                [oldCluster remove:clusterItem];
            }
            distanceToCluster[clusterItem] = @(distance);
            [cluster add:clusterItem];
            itemToCluster[clusterItem] = cluster;
        }
        [visitedCandidates addObjectsFromArray:clusterItems];
    }
    
    return results;
}

- (double)distanceSquared:(GQTPoint)a :(GQTPoint)b
{
    return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y);
}

- (GQTBounds)createBoundsFromSpan:(GQTPoint)point span:(double)span
{
    double halfSpan = span / 2;
    
    GQTBounds bounds;
    bounds.minX = point.x - halfSpan;
    bounds.maxX = point.x + halfSpan;
    bounds.minY = point.y - halfSpan;
    bounds.maxY = point.y + halfSpan;

    return bounds;
}

@end
