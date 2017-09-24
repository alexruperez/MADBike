//
//  BMSearchableProtocol.h
//  BiciMAD
//
//  Created by alexruperez on 19/1/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import CoreSpotlight;
@import MobileCoreServices;

@protocol BMSearchable <NSObject>

@property (nonatomic, weak, readonly) CSSearchableItem *searchableItem;

@property (nonatomic, strong) NSUserActivity *userActivity;

@end
