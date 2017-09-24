//
//  BMTipsTimelineDataSource.h
//  BiciMAD
//
//  Created by alexruperez on 23/2/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import <TwitterKit/TwitterKit.h>

@interface BMTipsTimelineDataSource : TWTRCollectionTimelineDataSource

- (instancetype)initWithAPIClient:(TWTRAPIClient *)client;

@end
