//
//  BMTipsTimelineDataSource.m
//  BiciMAD
//
//  Created by alexruperez on 23/2/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMTipsTimelineDataSource.h"

static NSString * const kBMTipsTimelineENIdentifier = @"702216997413789700";
static NSString * const kBMTipsTimelineESIdentifier = @"702218309266251777";

static NSString * const kBMTipsTimelineESLanguageCodeIdentifier = @"es";

static NSUInteger const kBMTipsTimelineMaxTweetsPerRequest = 0;

@implementation BMTipsTimelineDataSource

- (instancetype)initWithAPIClient:(TWTRAPIClient *)client
{
    NSString *languageCode = [NSLocale.autoupdatingCurrentLocale objectForKey:NSLocaleLanguageCode];
    
    self = [self initWithCollectionID:[languageCode isEqualToString:kBMTipsTimelineESLanguageCodeIdentifier] ? kBMTipsTimelineESIdentifier : kBMTipsTimelineENIdentifier APIClient:client maxTweetsPerRequest:kBMTipsTimelineMaxTweetsPerRequest];
    
    return self;
}

@end
