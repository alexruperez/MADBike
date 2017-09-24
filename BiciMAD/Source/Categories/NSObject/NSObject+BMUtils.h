//
//  NSObject+BMUtils.h
//  BiciMAD
//
//  Created by alexruperez on 14/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import Foundation;

@interface NSObject (BMUtils)

+ (NSString *)bm_className;

- (NSString *)bm_className;

- (void)bm_subclassResponsibility:(SEL)selector;

@end
