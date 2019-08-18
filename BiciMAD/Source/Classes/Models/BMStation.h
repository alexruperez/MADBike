//
//  BMStation.h
//  BiciMAD
//
//  Created by alexruperez on 20/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import Mantle;
@import MTLManagedObjectAdapter;

#import "BMFavoritableProtocol.h"
#import "BMSearchableProtocol.h"
#import "BMNavigableProtocol.h"
#import "BMShareableProtocol.h"

typedef NS_ENUM(NSUInteger, BMLight) {
    BMLightGreen,
    BMLightRed,
    BMLightYellow,
    BMLightGray
};

@interface BMStation : MTLModel <MTLJSONSerializing, MTLManagedObjectSerializing, BMFavoritable, BMSearchable, BMNavigable, BMShareable>

@property (nonatomic, copy, readonly) NSString *stationId;
@property (nonatomic, copy, readonly) NSString *stationNumber;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *street;
@property (nonatomic, copy, readonly) NSArray *coordinates;
@property (nonatomic, assign, readonly) BOOL active;
@property (nonatomic, assign, readonly) NSUInteger freeStands;
@property (nonatomic, assign, readonly) NSUInteger totalStands;
@property (nonatomic, assign, readonly) NSUInteger bikesHooked;
@property (nonatomic, assign, readonly) NSUInteger bikesReserved;
@property (nonatomic, assign, readonly) NSUInteger unavailableStands;
@property (nonatomic, assign, readonly) BMLight light;
@property (nonatomic, assign, readonly) BOOL unavailable;
@property (nonatomic, assign, readonly) CGFloat percentage;

@end
