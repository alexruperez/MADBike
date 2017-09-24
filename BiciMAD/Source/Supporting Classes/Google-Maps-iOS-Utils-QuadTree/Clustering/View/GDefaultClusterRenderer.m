@import CoreText;
#import "GDefaultClusterRenderer.h"
#import "GQuadItem.h"
#import "BMClusterAnnotationView.h"

@implementation GDefaultClusterRenderer
{
    GMSMapView *_map;
}

- (instancetype)initWithMapView:(GMSMapView*)googleMap
{
    self = super.init;
    
    if (self)
    {
        _map = googleMap;
    }
    
    return self;
}

- (void)clustersChanged:(NSSet*)clusters withCompletionHandler:(void (^)(void))completionHandler
{
    [_map clear];
    
    for (id <GCluster> cluster in clusters)
    {
        BMClusterAnnotationView *annotationView = BMClusterAnnotationView.new;
        GMSMarker *marker = GMSMarker.new;
        
        NSUInteger count = cluster.items.count;
        if (count > 1)
        {
            marker.title = [NSString stringWithFormat:NSLocalizedString(@"%ld Stations", @"%ld Stations"), cluster.items.count];
            marker.userData = cluster;
            annotationView.annotation = nil;
            annotationView.mapClusterAnnotation = marker.userData;
        }
        else
        {
            marker.title = cluster.marker.title;
            marker.snippet = cluster.marker.snippet;
            marker.userData = cluster.marker.userData;
            annotationView.annotation = marker.userData;
            annotationView.mapClusterAnnotation = nil;
        }
        
        marker.iconView = annotationView;
        marker.flat = cluster.marker.flat;
        marker.appearAnimation = cluster.marker.appearAnimation;
        marker.infoWindowAnchor = cluster.marker.infoWindowAnchor;
        marker.tracksViewChanges = cluster.marker.tracksViewChanges;
        marker.tracksInfoWindowChanges = cluster.marker.tracksInfoWindowChanges;
        marker.position = cluster.marker.position;
        marker.map = _map;
    }
    
    if (completionHandler)
    {
        completionHandler();
    }
}

@end
