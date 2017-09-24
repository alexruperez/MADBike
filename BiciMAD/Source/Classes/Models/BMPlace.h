//
//  BMPlace.h
//  BiciMAD
//
//  Created by alexruperez on 13/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import Mantle;
@import MTLManagedObjectAdapter;

#import "BMFavoritableProtocol.h"
#import "BMSearchableProtocol.h"
#import "BMNavigableProtocol.h"
#import "BMShareableProtocol.h"
#import "BMPartner.h"

@interface BMPlace : MTLModel <MTLJSONSerializing, MTLManagedObjectSerializing, BMFavoritable, BMSearchable, BMNavigable, BMShareable>

@property (nonatomic, copy, readonly) NSString *placeId;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *address;
@property (nonatomic, copy, readonly) NSString *city;
@property (nonatomic, copy, readonly) NSString *country;
@property (nonatomic, assign, readonly) CLLocationDegrees altitude;
@property (nonatomic, assign, readonly) CLLocationDegrees radius;
@property (nonatomic, strong, readonly) NSURL *annotationURL;
@property (nonatomic, strong) UIImage *annotationImage;
@property (nonatomic, weak) BMPartner *partner;

@end
