//
//  BMNavigationManager.h
//  BiciMAD
//
//  Created by alexruperez on 13/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMNavigableProtocol.h"

@interface BMNavigationManager : NSObject

+ (BOOL)open:(id<BMNavigable>)navigable inNavigation:(BMNavigation)navigation;

@end
