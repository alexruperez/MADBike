//
//  BMFavoritesManager.h
//  BiciMAD
//
//  Created by alexruperez on 18/11/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import Foundation;

@interface BMFavoritesManager : NSObject

- (NSArray *)findAll:(Class)modelClass;

- (void)load:(id)object;

- (void)save:(id)object;

@end
