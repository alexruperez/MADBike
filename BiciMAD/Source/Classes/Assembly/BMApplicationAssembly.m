//
//  BMApplicationAssembly.m
//  BiciMAD
//
//  Created by alexruperez on 8/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMApplicationAssembly.h"

@import AFNetworkActivityLogger;

#import "BMServicesAssembly.h"
#import "BMManagersAssembly.h"
#import "BMViewControllersAssembly.h"
#import "DDCLSLogger.h"

#import "BMAppDelegate.h"

@implementation BMApplicationAssembly

- (DDASLLogger *)aslLogger
{
    return [TyphoonDefinition withClass:[DDASLLogger class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(sharedInstance)];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (DDTTYLogger *)ttyLogger
{
    return [TyphoonDefinition withClass:[DDTTYLogger class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(sharedInstance)];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (DDCLSLogger *)clsLogger
{
    return [TyphoonDefinition withClass:[DDCLSLogger class] configuration:^(TyphoonDefinition *definition) {
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (AFNetworkActivityLogger *)networkActivityLogger
{
    return [TyphoonDefinition withClass:[AFNetworkActivityLogger class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(sharedLogger)];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (BMAppDelegate *)appDelegate
{
    return [TyphoonDefinition withClass:[BMAppDelegate class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(application) with:[self application]];
        [definition injectProperty:@selector(window) with:[self window]];
        [definition injectProperty:@selector(rootViewController) with:[self.viewControllersAssembly rootViewController]];
        [definition injectProperty:@selector(managersAssembly) with:self.managersAssembly];
        [definition injectProperty:@selector(aslLogger) with:[self aslLogger]];
        [definition injectProperty:@selector(ttyLogger) with:[self ttyLogger]];
        [definition injectProperty:@selector(clsLogger) with:[self clsLogger]];
        [definition injectProperty:@selector(networkActivityLogger) with:[self networkActivityLogger]];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (UIApplication *)application
{
    return [TyphoonDefinition withClass:[UIApplication class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(sharedApplication)];
        definition.scope = TyphoonScopeSingleton;
    }];
}

- (UIWindow *)window
{
    return [TyphoonDefinition withClass:[UIWindow class] configuration:^(TyphoonDefinition *definition) {
        [definition useInitializer:@selector(initWithFrame:) parameters:^(TyphoonMethod *initializer) {
            [initializer injectParameterWith:[NSValue valueWithCGRect:UIScreen.mainScreen.bounds]];
        }];
        [definition injectProperty:@selector(rootViewController) with:[self.viewControllersAssembly rootViewController]];
        definition.scope = TyphoonScopeSingleton;
    }];
}

@end
