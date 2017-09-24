//
//  BMMutableURLRequest.h
//  BiciMAD
//
//  Created by alexruperez on 13/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import Foundation;

typedef void (^BMMutableURLRequestCompletionBlock)(NSURLResponse *response, id responseObject, NSError *error);

@interface BMMutableURLRequest : NSMutableURLRequest

@property (nonatomic, copy) BMMutableURLRequestCompletionBlock completionBlock;

- (void)setCompletionBlock:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionBlock;

- (BOOL)setJSONBody:(id)JSONBody error:(NSError **)error;

@end
