//
//  ClusterRenderer.h
//  Parkingmobility
//
//  Created by Colin Edwards on 1/18/14.
//  Copyright (c) 2014 Colin Edwards. All rights reserved.
//

@import Foundation;
@import GoogleMaps;

@protocol GClusterRenderer <NSObject>

- (void)clustersChanged:(NSSet*)clusters withCompletionHandler:(void (^)(void))completionHandler;

@end
