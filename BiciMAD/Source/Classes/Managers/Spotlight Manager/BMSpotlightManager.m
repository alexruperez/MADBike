//
//  BMSpotlightManager.m
//  BiciMAD
//
//  Created by alexruperez on 19/1/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMSpotlightManager.h"

#import "BMSearchableProtocol.h"

@implementation BMSpotlightManager

- (CSSearchableIndex *)searchableIndex
{
    return CSSearchableIndex.isIndexingAvailable ? CSSearchableIndex.defaultSearchableIndex : nil;
}

- (BOOL)index:(id)object completion:(BMIndexCompletionHandler)indexCompletionHandler
{
    NSMutableArray *searchableItems = NSMutableArray.new;
    
    if ([object isKindOfClass:NSArray.class])
    {
        for (id searchable in object)
        {
            if ([self canIndex:searchable])
            {
                [searchableItems addObject:[searchable searchableItem]];
            }
            else
            {
                return NO;
            }
        }
    }
    else if ([self canIndex:object])
    {
        [searchableItems addObject:[object searchableItem]];
    }
    else
    {
        return NO;
    }
    
    [self indexSearchableItems:searchableItems.copy completion:indexCompletionHandler];
    
    return YES;
}

- (BOOL)truncateIndexWithDomain:(NSString *)domainIdentifier completion:(BMIndexCompletionHandler)indexCompletionHandler
{
    if ([domainIdentifier isKindOfClass:NSString.class])
    {
        [self deleteSearchableItemsWithDomainIdentifiers:@[domainIdentifier] completion:indexCompletionHandler];
        
        return YES;
    }
    
    return NO;
}

- (void)truncateIndexWithCompletion:(BMIndexCompletionHandler)indexCompletionHandler
{
    [self deleteAllSearchableItemsWithCompletion:indexCompletionHandler];
}

- (BOOL)canIndex:(id)object
{
    return [object conformsToProtocol:@protocol(BMSearchable)] && [object searchableItem];
}

- (void)indexSearchableItems:(NSArray *)items completion:(BMIndexCompletionHandler)indexCompletionHandler
{
    [self.searchableIndex indexSearchableItems:items completionHandler:indexCompletionHandler];
}

- (void)deleteSearchableItemsWithIdentifiers:(NSArray *)identifiers completion:(BMIndexCompletionHandler)indexCompletionHandler
{
    [self.searchableIndex deleteSearchableItemsWithIdentifiers:identifiers completionHandler:indexCompletionHandler];
}

- (void)deleteSearchableItemsWithDomainIdentifiers:(NSArray *)domainIdentifiers completion:(BMIndexCompletionHandler)indexCompletionHandler
{
    [self.searchableIndex deleteSearchableItemsWithDomainIdentifiers:domainIdentifiers completionHandler:indexCompletionHandler];
}

- (void)deleteAllSearchableItemsWithCompletion:(BMIndexCompletionHandler)indexCompletionHandler
{
    [self.searchableIndex deleteAllSearchableItemsWithCompletionHandler:indexCompletionHandler];
}

@end
