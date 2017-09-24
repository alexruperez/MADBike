//
//  BMSpotlightManager.h
//  BiciMAD
//
//  Created by alexruperez on 19/1/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import Foundation;

typedef void (^BMIndexCompletionHandler)(NSError *error);

@interface BMSpotlightManager : NSObject

- (BOOL)index:(id)object completion:(BMIndexCompletionHandler)indexCompletionHandler;

- (BOOL)truncateIndexWithDomain:(NSString *)domainIdentifier completion:(BMIndexCompletionHandler)indexCompletionHandler;

- (void)truncateIndexWithCompletion:(BMIndexCompletionHandler)indexCompletionHandler;

@end
