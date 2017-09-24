//
//  BMGreenTipsTimelineDataSource.m
//  BiciMAD
//
//  Created by alexruperez on 23/2/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMGreenTipsTimelineDataSource.h"

static NSString * const kBMTipsTimelineENIdentifier = @"737373381146910721";
static NSString * const kBMTipsTimelineESIdentifier = @"737373980861059073";

static NSString * const kBMTipsTimelineESLanguageCodeIdentifier = @"es";

static NSUInteger const kBMTipsTimelineMaxTweetsPerRequest = 0;

@implementation BMGreenTipsTimelineDataSource

- (instancetype)initWithAPIClient:(TWTRAPIClient *)client
{
    NSString *languageCode = [NSLocale.autoupdatingCurrentLocale objectForKey:NSLocaleLanguageCode];
    
    self = [self initWithCollectionID:[languageCode isEqualToString:kBMTipsTimelineESLanguageCodeIdentifier] ? kBMTipsTimelineESIdentifier : kBMTipsTimelineENIdentifier APIClient:client maxTweetsPerRequest:kBMTipsTimelineMaxTweetsPerRequest];
    
    return self;
}

@end
