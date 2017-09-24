@import Foundation;
@import GoogleMaps;
#import "GClusterAlgorithm.h"
#import "GClusterRenderer.h"
#import "GQTPointQuadTreeItem.h"

@interface GClusterManager : NSObject <GMSMapViewDelegate> 

@property(nonatomic, strong) GMSMapView *mapView;
@property(nonatomic, strong) id<GClusterAlgorithm> clusterAlgorithm;
@property(nonatomic, strong) id<GClusterRenderer> clusterRenderer;
@property(nonatomic, strong, readonly) NSMutableArray *items;

- (void)addItem:(id <GClusterItem>) item;
- (void)removeItems;
- (void)removeItemsNotInRectangle:(CGRect)rect;

- (void)clusterWithCompletionHandler:(void (^)(void))completionHandler;

//convenience

+ (instancetype)managerWithMapView:(GMSMapView*)googleMap
                         algorithm:(id<GClusterAlgorithm>)algorithm
                          renderer:(id<GClusterRenderer>)renderer;

@end
