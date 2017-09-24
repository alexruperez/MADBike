//
//  BMCoreDataManager.h
//  BiciMAD
//
//  Created by alexruperez on 8/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import Mantle;
@import MTLManagedObjectAdapter;

typedef void (^BMFindCompletionHandler)(NSArray *results, NSError *error);
typedef void (^BMSaveCompletionHandler)(BOOL contextDidSave, NSError *error);

@interface BMCoreDataManager : NSObject

- (void)takeOff;

- (void)findAll:(Class)modelClass completion:(BMFindCompletionHandler)findCompletionHandler;

- (void)findKeys:(NSArray *)entityKeys modelClass:(Class)modelClass completion:(BMFindCompletionHandler)findCompletionHandler;

- (void)findInput:(NSString *)input selector:(SEL)selector modelClass:(Class)modelClass completion:(BMFindCompletionHandler)findCompletionHandler;

- (void)save:(id)object completion:(BMSaveCompletionHandler)saveCompletionHandler;

- (void)truncateDatabaseWithCompletion:(BMSaveCompletionHandler)saveCompletionHandler;

@end
