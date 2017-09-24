//
//  NSArray+BMUtils.h
//  BiciMAD
//
//  Created by alexruperez on 19/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import Foundation;

@interface NSArray (BMUtils)

- (instancetype)bm_map:(id (^)(id object))block;

- (instancetype)bm_mapArray:(NSArray *(^)(id object))block;

- (instancetype)bm_filter:(BOOL (^)(id object))block;

@end
