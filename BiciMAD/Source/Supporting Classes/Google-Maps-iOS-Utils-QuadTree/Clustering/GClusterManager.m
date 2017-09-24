#import "GClusterManager.h"

@interface GClusterManager ()

@property (nonatomic, strong) GMSCameraPosition *previousCameraPosition;

@end

@implementation GClusterManager

- (NSMutableArray *)items
{
    return _clusterAlgorithm.items;
}

- (void)setMapView:(GMSMapView*)mapView
{
    _previousCameraPosition = nil;
    _mapView = mapView;
}

- (void)setClusterAlgorithm:(id <GClusterAlgorithm>)clusterAlgorithm
{
    _previousCameraPosition = nil;
    _clusterAlgorithm = clusterAlgorithm;
}

- (void)setClusterRenderer:(id <GClusterRenderer>)clusterRenderer
{
    _previousCameraPosition = nil;
    _clusterRenderer = clusterRenderer;
}

- (void)addItem:(id <GClusterItem>) item
{
    [_clusterAlgorithm addItem:item];
}

- (void)removeItems
{
  [_clusterAlgorithm removeItems];
}

- (void)removeItemsNotInRectangle:(CGRect)rect
{
    [_clusterAlgorithm removeItemsNotInRectangle:rect];
}

- (void)clusterWithCompletionHandler:(void (^)(void))completionHandler
{
    NSSet *clusters = [_clusterAlgorithm getClusters:_mapView.camera.zoom];
    [_clusterRenderer clustersChanged:clusters withCompletionHandler:completionHandler];
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)cameraPosition
{
    assert(mapView == _mapView);
    
    GMSCameraPosition *position = mapView.camera;
    if (self.previousCameraPosition == nil || self.previousCameraPosition.zoom != position.zoom)
    {
        [self clusterWithCompletionHandler:^{
            self.previousCameraPosition = mapView.camera;
        }];
    }
}

#pragma mark convenience

+ (instancetype)managerWithMapView:(GMSMapView*)googleMap
                         algorithm:(id<GClusterAlgorithm>)algorithm
                          renderer:(id<GClusterRenderer>)renderer
{
    GClusterManager *clusterManager = self.class.new;
    
    if (clusterManager)
    {
        clusterManager.mapView = googleMap;
        clusterManager.clusterAlgorithm = algorithm;
        clusterManager.clusterRenderer = renderer;
    }
    
    return clusterManager;
}

@end
