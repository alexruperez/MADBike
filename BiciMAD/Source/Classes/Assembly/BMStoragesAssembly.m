//
//  BMStoragesAssembly.m
//  BiciMAD
//
//  Created by alexruperez on 18/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMStoragesAssembly.h"

#import "BMPointsStorage.h"

@implementation BMStoragesAssembly

- (BMPointsStorage *)pointsStorage
{
    return [TyphoonDefinition withClass:[BMPointsStorage class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(storagesAssembly) with:self];
        definition.scope = TyphoonScopeSingleton;
    }];
}

@end
