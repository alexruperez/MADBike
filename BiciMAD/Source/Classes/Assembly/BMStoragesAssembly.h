//
//  BMStoragesAssembly.h
//  BiciMAD
//
//  Created by alexruperez on 18/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import Typhoon;

#import "BMStorage.h"

@class BMPointsStorage;

@interface BMStoragesAssembly : TyphoonAssembly

- (BMPointsStorage *)pointsStorage;

@end
