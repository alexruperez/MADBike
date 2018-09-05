//
//  BMStation.m
//  BiciMAD
//
//  Created by alexruperez on 20/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMStation.h"

#import "MTLValueTransformer+BMValueTransformers.h"
#import "BMNavigationManager.h"
#import "BMDeepLinkingManager.h"

static NSString * const kBMAddressDictionaryStreetKey = @"Street";

static NSString * const kBMMADBikeDeepLinkStationURLString = @"madbike://station?id=";
static NSString * const kBMMADBikeWebStationURLString = @"https://www.madbikeapp.com/stations/";

@implementation BMStation

@synthesize favorite, userActivity = _userActivity, marker, distance, latitude, longitude;

+ (NSValueTransformer *)stationIdJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
        if ([value isKindOfClass:NSDictionary.class])
        {
            value = [[value allValues] firstObject];
        }
        if ([value isKindOfClass:NSNumber.class])
        {
            value = [value stringValue];
        }
        if (!value)
        {
            value = @"";
        }
        *success = [value isKindOfClass:NSString.class];
        return value;
    }];
}

+ (NSValueTransformer *)activeJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)freeStandsJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)totalStandsJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)bikesHookedJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)bikesReservedJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)latitudeJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)longitudeJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)lightJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)unavailableJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)percentageJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSString *)managedObjectEntityName
{
    return self.bm_className;
}

+ (NSSet *)propertyKeysForManagedObjectUniquing
{
    return [NSSet setWithObject:NSStringFromSelector(@selector(stationId))];
}

+ (NSDictionary *)managedObjectKeysByPropertyKey
{
    NSMutableDictionary *managedObjectKeysByPropertyKey = [NSDictionary mtl_identityPropertyMapWithModel:self].mutableCopy;
    [managedObjectKeysByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(userActivity))];
    [managedObjectKeysByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(marker))];
    [managedObjectKeysByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(distance))];
    return managedObjectKeysByPropertyKey.copy;
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
        if ([value isKindOfClass:NSDictionary.class])
        {
            value = [[value allValues] firstObject];
        }
        *success = ![value isKindOfClass:NSDictionary.class];
        return value;
    }];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             NSStringFromSelector(@selector(stationId)): @[@"idestacion", @"id"],
             NSStringFromSelector(@selector(stationNumber)): @[@"numero_estacion", @"number"],
             NSStringFromSelector(@selector(name)): @[@"nombre", @"name"],
             NSStringFromSelector(@selector(active)): @[@"activo", @"activate"],
             NSStringFromSelector(@selector(freeStands)): @[@"bases_libres", @"free_bases"],
             NSStringFromSelector(@selector(totalStands)): @[@"numero_bases", @"total_bases"],
             NSStringFromSelector(@selector(bikesHooked)): @[@"bicis_enganchadas", @"dock_bikes"],
             NSStringFromSelector(@selector(bikesReserved)): @[@"reservations_count"],
             NSStringFromSelector(@selector(street)): @[@"direccion", @"address"],
             NSStringFromSelector(@selector(latitude)): @[@"latitud", @"latitude"],
             NSStringFromSelector(@selector(longitude)): @[@"longitud", @"longitude"],
             NSStringFromSelector(@selector(light)): @[@"luz", @"light"],
             NSStringFromSelector(@selector(unavailable)): @[@"no_disponible", @"no_available"],
             NSStringFromSelector(@selector(percentage)): @[@"porcentaje"]
             };
}

+ (NSDictionary *)encodingBehaviorsByPropertyKey
{
    NSMutableDictionary *encodingBehaviorsByPropertyKey = [super encodingBehaviorsByPropertyKey].mutableCopy;
    [encodingBehaviorsByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(userActivity))];
    [encodingBehaviorsByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(marker))];
    [encodingBehaviorsByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(distance))];
    return encodingBehaviorsByPropertyKey.copy;
}

- (BOOL)isEqual:(BMStation *)station
{
    if ([station isKindOfClass:BMStation.class])
    {
        return [self.stationId isEqualToString:station.stationId];
    }
    
    return [super isEqual:station];
}

- (NSUInteger)hash
{
    return self.stationId.hash;
}

- (BOOL)validate:(NSError **)error
{
    return [self valueForKey:NSStringFromSelector(@selector(bikesReserved))] && [super validate:error];
}

- (NSUInteger)unavailableStands
{
    return self.totalStands - self.freeStands - self.bikesHooked;
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (CLLocationCoordinate2D)position
{
    return self.coordinate;
}

- (NSString *)title
{
    return [NSString stringWithFormat:@"%@ - %@", self.stationNumber, self.name];
}

- (NSString *)subtitle
{
    NSString *subtitle = self.street;
    NSString *distanceString = self.distanceString;
    if (distanceString)
    {
        return [subtitle stringByAppendingFormat:@" (%@)", distanceString];
    }
    return subtitle;
}

- (NSString *)distanceString
{
    CLLocationDistance stationDistance = self.distance;

    if (stationDistance <= 0 || stationDistance >= CLLocationDistanceMax)
    {
        return nil;
    }

    BOOL usesMetricSystem = [[NSLocale.autoupdatingCurrentLocale objectForKey:NSLocaleUsesMetricSystem] boolValue];

    if (usesMetricSystem)
    {
        if (stationDistance > 1000)
        {
            return [NSString stringWithFormat:@"%.2fKm", stationDistance * kBMMetersToKilometers];
        }
        return [NSString stringWithFormat:@"%.0fm", stationDistance];
    }

    if (stationDistance > 1000)
    {
        return [NSString stringWithFormat:@"%.2fmi", stationDistance * kBMMetersToMiles];
    }
    return [NSString stringWithFormat:@"%.0fyd", stationDistance * kBMMetersToYards];
}

- (NSDictionary *)addressDictionary
{
    return self.street ? @{kBMAddressDictionaryStreetKey: self.street} : nil;
}

- (MKPlacemark *)placemark
{
    return [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:self.addressDictionary];
}

- (MKMapItem *)mapItem
{
    return [[MKMapItem alloc] initWithPlacemark:self.placemark];
}

- (NSString *)URLScheme
{
    return self.stationId ? [kBMMADBikeDeepLinkStationURLString stringByAppendingString:self.stationId] : kBMMADBikeDeepLinkStationURLString;
}

- (NSString *)URLString
{
    return self.stationId ? [kBMMADBikeWebStationURLString stringByAppendingString:self.stationId] : kBMMADBikeWebStationURLString;
}

- (CSSearchableItem *)searchableItem
{
    CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeItem];
    
    attributeSet.title = self.title;
    attributeSet.displayName = self.title;
    attributeSet.contentDescription = self.subtitle;
    NSMutableArray *keywords = @[NSLocalizedString(@"MADBike", @"MADBike"), NSLocalizedString(@"BiciMAD", @"BiciMAD"), NSLocalizedString(@"bike", @"bike"), NSLocalizedString(@"bikes", @"bikes"), NSLocalizedString(@"bicycle", @"bicycle"), NSLocalizedString(@"bicycles", @"bicycles"), NSLocalizedString(@"Madrid", @"Madrid"), NSLocalizedString(@"move", @"move"), NSLocalizedString(@"city", @"city"), NSLocalizedString(@"center", @"center"), NSLocalizedString(@"downtown", @"downtown"), NSLocalizedString(@"Bonopark", @"Bonopark"), NSLocalizedString(@"map", @"map"), NSLocalizedString(@"stations", @"stations")].mutableCopy;
    [keywords addObjectsFromArray:[self.title componentsSeparatedByString:@" "]];
    attributeSet.keywords = keywords.copy;
    attributeSet.identifier = self.stationId;
    attributeSet.relatedUniqueIdentifier = self.URLString;
    attributeSet.creator = NSLocalizedString(@"MADBike", @"MADBike");
    attributeSet.kind = NSStringFromClass(BMStation.class);
    attributeSet.namedLocation = self.street;
    attributeSet.city = NSLocalizedString(@"Madrid", @"Madrid");
    attributeSet.latitude = @(self.latitude);
    attributeSet.longitude = @(self.longitude);
    attributeSet.supportsNavigation = @(YES);
    attributeSet.contentURL = [NSURL URLWithString:self.URLString];
    
    return [[CSSearchableItem alloc] initWithUniqueIdentifier:self.URLScheme domainIdentifier:NSStringFromClass(BMStation.class) attributeSet:attributeSet];
}

- (NSUserActivity *)userActivity
{
    if (!_userActivity)
    {
        _userActivity = [[NSUserActivity alloc] initWithActivityType:kBMMADBikeUserActivityStation];
        _userActivity.title = self.title;
        _userActivity.eligibleForSearch = YES;
        _userActivity.eligibleForPublicIndexing = YES;
        _userActivity.eligibleForHandoff = YES;
        if (@available(iOS 12.0, *)) {
            _userActivity.eligibleForPrediction = YES;
            _userActivity.persistentIdentifier = self.stationId;
        }
        if ([_userActivity respondsToSelector:@selector(mapItem)])
        {
            _userActivity.mapItem = self.mapItem;
        }
        _userActivity.contentAttributeSet = self.searchableItem.attributeSet;
        _userActivity.keywords = [NSSet setWithArray:_userActivity.contentAttributeSet.keywords];
        _userActivity.webpageURL = [NSURL URLWithString:self.URLString];
        _userActivity.requiredUserInfoKeys = [NSSet setWithObject:kBMMADBikeDeepLinkIdentifier];
        _userActivity.userInfo = @{kBMMADBikeDeepLinkIdentifier: self.stationId};
    }
    
    return _userActivity;
}

- (BOOL)openIn:(BMNavigation)navigation
{
    return [BMNavigationManager open:self inNavigation:navigation];
}

@end
