//
//  BMCoreDataManager.m
//  BiciMAD
//
//  Created by alexruperez on 8/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMCoreDataManager.h"

@import CocoaLumberjack;
@import MagicalRecord;

static NSString * const kBMCoreDataManagerDatabaseName = @"MADBike.sqlite";

@implementation BMCoreDataManager

- (void)takeOff
{
#ifdef DEBUG
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelInfo];
#else
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelWarn];
#endif
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:kBMCoreDataManagerDatabaseName];
}

- (NSManagedObjectContext *)defaultContext
{
    return NSManagedObjectContext.MR_defaultContext;
}

- (NSManagedObjectContext *)rootSavingContext
{
    return NSManagedObjectContext.MR_rootSavingContext;
}

- (void)findAll:(Class)modelClass completion:(BMFindCompletionHandler)findCompletionHandler
{
    [self findAll:modelClass context:self.defaultContext completion:findCompletionHandler];
}

- (void)findAll:(Class)modelClass context:(NSManagedObjectContext *)context completion:(BMFindCompletionHandler)findCompletionHandler
{
    if ([modelClass isSubclassOfClass:MTLModel.class] && [modelClass conformsToProtocol:@protocol(MTLManagedObjectSerializing)])
    {
        [self findAllEntities:NSStringFromClass(modelClass) context:context completion:^(NSArray *entities, NSError *error) {
            if (findCompletionHandler)
            {
                NSMutableArray *models = NSMutableArray.new;
                
                for (NSManagedObject *managedObject in entities)
                {
                    id model = [MTLManagedObjectAdapter modelOfClass:modelClass fromManagedObject:managedObject error:&error];
                    if (model)
                    {
                        [models addObject:model];
                    }
                }
                
                findCompletionHandler(models.copy, error);
            }
        }];
    }
    else if (findCompletionHandler)
    {
        findCompletionHandler(@[], nil);
    }
}

- (void)findAllEntities:(NSString *)entityName context:(NSManagedObjectContext *)context completion:(BMFindCompletionHandler)findCompletionHandler
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        NSArray *entities = [context executeFetchRequest:request error:&error];
        
        if (findCompletionHandler)
        {
            findCompletionHandler(entities, error);
        }
        
    }];
}

- (void)findInput:(NSString *)input selector:(SEL)selector modelClass:(Class)modelClass completion:(BMFindCompletionHandler)findCompletionHandler
{
    [self findInput:input selector:selector modelClass:modelClass context:self.defaultContext completion:^(NSArray *entities, NSError *error) {
        if (findCompletionHandler)
        {
            NSMutableArray *models = NSMutableArray.new;
            
            for (NSManagedObject *managedObject in entities)
            {
                id model = [MTLManagedObjectAdapter modelOfClass:modelClass fromManagedObject:managedObject error:&error];
                if (model)
                {
                    [models addObject:model];
                }
            }
            
            findCompletionHandler(models.copy, error);
        }
    }];
}

- (void)findInput:(NSString *)input selector:(SEL)selector modelClass:(Class)modelClass context:(NSManagedObjectContext *)context completion:(BMFindCompletionHandler)findCompletionHandler
{
    NSString *managedObjectEntityName = [modelClass managedObjectEntityName];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:managedObjectEntityName];
    
    request.predicate = [NSPredicate predicateWithFormat:@"self.%K CONTAINS[cd] %@", NSStringFromSelector(selector), input];
    
    [context performBlockAndWait:^{
        NSError *error = nil;
        NSArray *entities = [context executeFetchRequest:request error:&error];
        
        if (findCompletionHandler)
        {
            findCompletionHandler(entities, error);
        }
    }];
}

- (void)findKeys:(NSArray *)entityKeys modelClass:(Class)modelClass completion:(BMFindCompletionHandler)findCompletionHandler
{
    [self findKeys:entityKeys modelClass:modelClass context:self.defaultContext completion:findCompletionHandler];
}

- (void)findKeys:(NSArray *)entityKeys modelClass:(Class)modelClass context:(NSManagedObjectContext *)context completion:(BMFindCompletionHandler)findCompletionHandler
{
    [self findEntityKeys:entityKeys modelClass:modelClass context:context completion:^(NSArray *entities, NSError *error) {
        if (findCompletionHandler)
        {
            NSMutableArray *models = NSMutableArray.new;
            
            for (NSManagedObject *managedObject in entities)
            {
                id model = [MTLManagedObjectAdapter modelOfClass:modelClass fromManagedObject:managedObject error:&error];
                if (model)
                {
                    [models addObject:model];
                }
            }
            
            findCompletionHandler(models.copy, error);
        }
    }];
}

- (void)findEntityKeys:(NSArray *)entityKeys modelClass:(Class)modelClass context:(NSManagedObjectContext *)context completion:(BMFindCompletionHandler)findCompletionHandler
{
    NSString *managedObjectEntityName = [modelClass managedObjectEntityName];
    
    NSSet *propertyKeysForManagedObjectUniquing = [modelClass propertyKeysForManagedObjectUniquing];
    
    NSString *entityKey = [propertyKeysForManagedObjectUniquing anyObject];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:managedObjectEntityName];
    
    request.predicate = [NSPredicate predicateWithFormat:@"self.%K IN %@", entityKey, entityKeys];
    
    request.fetchLimit = entityKeys.count;
    
    [context performBlockAndWait:^{
        NSError *error = nil;
        NSArray *entities = [context executeFetchRequest:request error:&error];
        
        if (findCompletionHandler)
        {
            findCompletionHandler(entities, error);
        }
    }];
}

- (void)saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block completion:(BMSaveCompletionHandler)saveCompletionHandler
{
    [MagicalRecord saveWithBlock:block completion:saveCompletionHandler];
}

- (BOOL)managedObjectFromModel:(id)model insertingIntoContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    if ([model isKindOfClass:MTLModel.class] && [model conformsToProtocol:@protocol(MTLManagedObjectSerializing)])
    {
        [MTLManagedObjectAdapter managedObjectFromModel:model insertingIntoContext:context error:error];
        return !*error;
    }
    
    return NO;
}

- (void)save:(id)object completion:(BMSaveCompletionHandler)saveCompletionHandler
{
    @weakify(self)
    [self saveWithBlock:^(NSManagedObjectContext *localContext) {
        @strongify(self)
        NSError *error = nil;
        
        if ([object isKindOfClass:NSArray.class])
        {
            for (id model in object)
            {
                [self managedObjectFromModel:model insertingIntoContext:localContext error:&error];
            }
        }
        else
        {
            [self managedObjectFromModel:object insertingIntoContext:localContext error:&error];
        }
        
        if (error)
        {
            [MagicalRecord handleErrors:error];
        }
    } completion:saveCompletionHandler];
}

- (NSManagedObjectModel *)defaultManagedObjectModel
{
    return NSManagedObjectModel.MR_defaultManagedObjectModel;
}

- (void)truncateDatabaseWithCompletion:(BMSaveCompletionHandler)saveCompletionHandler
{
    @weakify(self)
    [self saveWithBlock:^(NSManagedObjectContext *localContext) {
        @strongify(self)
        NSArray *entities = self.defaultManagedObjectModel.entities;
        
        for (NSEntityDescription *description in entities)
        {
            [self findAllEntities:description.name context:localContext completion:^(NSArray *allEntities, NSError *error) {
                if (error)
                {
                    [MagicalRecord handleErrors:error];
                }
                else
                {
                    for (NSManagedObject *managedObject in allEntities)
                    {
                        [managedObject MR_deleteEntityInContext:localContext];
                    }
                }
            }];
        }
    } completion:saveCompletionHandler];
}

@end
