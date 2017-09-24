//
//  BMFavoritesManager.m
//  BiciMAD
//
//  Created by alexruperez on 18/11/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMFavoritesManager.h"

#import "BMFavoritableProtocol.h"
#import "MADBike-Swift.h"

@interface BMFavoritesManager ()

@property (nonatomic, strong) NSMutableArray *favorites;

@end

@implementation BMFavoritesManager

- (NSMutableArray *)favorites
{
    if (!_favorites)
    {
        _favorites = NSMutableArray.new;
    }
    
    return _favorites;
}

- (NSArray *)findAll:(Class)modelClass
{
    NSMutableArray *objects = NSMutableArray.new;
    
    for (id object in self.favorites)
    {
        if ([object isKindOfClass:modelClass])
        {
            [objects addObject:object];
        }
    }
    
    return objects.copy;
}

- (void)load:(id)object
{
    if ([object isKindOfClass:NSArray.class])
    {
        for (id model in object)
        {
            [self loadFavorite:model];
        }
    }
    else
    {
        [self loadFavorite:object];
    }
}

- (void)save:(id)object
{
    if ([object isKindOfClass:NSArray.class])
    {
        for (id model in object)
        {
            [self saveFavorite:model];
        }
        [self log:object];
    }
    else
    {
        [self saveFavorite:object];
        [self log:@[object]];
    }
}

- (void)loadFavorite:(id)object
{
    if ([self isFavoritable:object])
    {
        [object setFavorite:[self.favorites containsObject:object]];
    }
}

- (void)saveFavorite:(id)object
{
    if ([self.favorites containsObject:object])
    {
        [self.favorites removeObject:object];
    }
    
    if ([self isFavoritable:object] && [object favorite])
    {
        [self.favorites addObject:object];
    }
}

- (BOOL)isFavoritable:(id)object
{
    return [object conformsToProtocol:@protocol(BMFavoritable)];
}

@end
