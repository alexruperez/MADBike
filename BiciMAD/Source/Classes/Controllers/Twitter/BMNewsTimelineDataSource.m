//
//  BMNewsTimelineDataSource.m
//  BiciMAD
//
//  Created by alexruperez on 23/2/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMNewsTimelineDataSource.h"

static NSString * const kBMNewsTimelineScreenName = @"madbikeapp";
static NSString * const kBMNewsTimelineUserIdentifier = nil;
static NSUInteger const kBMNewsTimelineMaxTweetsPerRequest = 0;
static BOOL const kBMNewsTimelineIncludeReplies = NO;
static BOOL const kBMNewsTimelineIncludeRetweets = YES;

@implementation BMNewsTimelineDataSource

- (instancetype)initWithAPIClient:(TWTRAPIClient *)client
{
    self = [self initWithScreenName:kBMNewsTimelineScreenName userID:kBMNewsTimelineUserIdentifier APIClient:client maxTweetsPerRequest:kBMNewsTimelineMaxTweetsPerRequest includeReplies:kBMNewsTimelineIncludeReplies includeRetweets:kBMNewsTimelineIncludeRetweets];
    
    return self;
}

@end
