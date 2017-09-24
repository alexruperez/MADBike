//
//  BMPlace.m
//  BiciMAD
//
//  Created by alexruperez on 13/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMPlace.h"

@import AFNetworking;

#import "MTLValueTransformer+BMValueTransformers.h"
#import "BMNavigationManager.h"

static NSString * const kBMAddressDictionaryStreetKey = @"Street";

static NSString * const kBMMADBikeDeepLinkPlaceURLString = @"madbike://place?id=";
static NSString * const kBMMADBikeWebPlaceURLString = @"https://www.madbikeapp.com/places/";

@implementation BMPlace

@synthesize favorite, userActivity = _userActivity, marker, distance, latitude, longitude;

+ (NSValueTransformer *)placeIdJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)annotationURLJSONTransformer
{
    return MTLValueTransformer.bm_urlValueTransformer;
}

+ (NSValueTransformer *)latitudeJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)longitudeJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)altitudeJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)radiusJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSString *)managedObjectEntityName
{
    return self.bm_className;
}

+ (NSSet *)propertyKeysForManagedObjectUniquing
{
    return [NSSet setWithObject:NSStringFromSelector(@selector(placeId))];
}

+ (NSDictionary *)managedObjectKeysByPropertyKey
{
    NSMutableDictionary *managedObjectKeysByPropertyKey = [NSDictionary mtl_identityPropertyMapWithModel:self].mutableCopy;
    [managedObjectKeysByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(userActivity))];
    [managedObjectKeysByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(marker))];
    [managedObjectKeysByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(distance))];
    [managedObjectKeysByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(annotationImage))];
    return managedObjectKeysByPropertyKey.copy;
}

+ (NSDictionary *)relationshipModelClassesByPropertyKey
{
    return @{
             NSStringFromSelector(@selector(partner)): BMPartner.class
             };
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             NSStringFromSelector(@selector(placeId)): @"id",
             NSStringFromSelector(@selector(name)): @"name",
             NSStringFromSelector(@selector(address)): @"address",
             NSStringFromSelector(@selector(city)): @"city",
             NSStringFromSelector(@selector(country)): @"country",
             NSStringFromSelector(@selector(latitude)): @"latitude",
             NSStringFromSelector(@selector(longitude)): @"longitude",
             NSStringFromSelector(@selector(altitude)): @"altitude",
             NSStringFromSelector(@selector(radius)): @"radius",
             NSStringFromSelector(@selector(annotationURL)): [@"annotation_x" stringByAppendingString:@(UIScreen.mainScreen.scale).stringValue]
             };
}

+ (MTLPropertyStorage)storageBehaviorForPropertyWithKey:(NSString *)propertyKey
{
    if ([propertyKey isEqualToString:NSStringFromSelector(@selector(partner))])
    {
        return MTLPropertyStorageTransitory;
    }
    
    return [super storageBehaviorForPropertyWithKey:propertyKey];
}

+ (NSDictionary *)encodingBehaviorsByPropertyKey
{
    NSMutableDictionary *encodingBehaviorsByPropertyKey = [super encodingBehaviorsByPropertyKey].mutableCopy;
    [encodingBehaviorsByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(userActivity))];
    [encodingBehaviorsByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(marker))];
    [encodingBehaviorsByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(distance))];
    [encodingBehaviorsByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(partner))];
    [encodingBehaviorsByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(annotationImage))];
    return encodingBehaviorsByPropertyKey.copy;
}

- (AFImageDownloader *)imageDownloader
{
    return AFImageDownloader.defaultInstance;
}

- (void)setPlaceId:(NSString *)placeId
{
    if (_placeId != placeId)
    {
        if ([placeId isKindOfClass:NSNumber.class])
        {
            _placeId = [(NSNumber *)placeId stringValue];
        }
        else if ([placeId isKindOfClass:NSString.class])
        {
            _placeId = placeId;
        }
    }
}

- (void)setAnnotationURL:(NSURL *)annotationURL
{
    _annotationURL = annotationURL;
    if (_annotationURL)
    {
        NSURLRequest *annotationImageRequest = [NSURLRequest requestWithURL:_annotationURL];
        if (annotationImageRequest)
        {
            @weakify(self);
            [self.imageDownloader downloadImageForURLRequest:annotationImageRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *annotationImage) {
                @strongify(self);
                self.annotationImage = annotationImage;
            } failure:nil];
        }
    }
}

- (BOOL)isEqual:(BMPlace *)place
{
    if ([place isKindOfClass:BMPlace.class])
    {
        return [self.placeId isEqualToString:place.placeId];
    }
    
    return [super isEqual:place];
}

- (NSUInteger)hash
{
    return self.placeId.hash;
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
    return self.name;
}

- (NSString *)subtitle
{
    return self.address;
}

- (NSDictionary *)addressDictionary
{
    return self.address ? @{kBMAddressDictionaryStreetKey: self.address} : nil;
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
    return [kBMMADBikeDeepLinkPlaceURLString stringByAppendingString:self.placeId];
}

- (NSString *)URLString
{
    return [kBMMADBikeWebPlaceURLString stringByAppendingString:self.placeId];
}

- (CSSearchableItem *)searchableItem
{
    CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeItem];
    
    attributeSet.title = self.title;
    attributeSet.displayName = self.title;
    NSMutableArray *keywords = @[NSLocalizedString(@"MADBike", @"MADBike"), NSLocalizedString(@"BiciMAD", @"BiciMAD"), NSLocalizedString(@"city", @"city"), NSLocalizedString(@"center", @"center"), NSLocalizedString(@"downtown", @"downtown"), NSLocalizedString(@"places", @"places")].mutableCopy;
    [keywords addObjectsFromArray:[self.title componentsSeparatedByString:@" "]];
    attributeSet.keywords = keywords.copy;
    attributeSet.identifier = self.placeId;
    attributeSet.relatedUniqueIdentifier = self.URLString;
    attributeSet.creator = NSLocalizedString(@"MADBike", @"MADBike");
    attributeSet.kind = NSStringFromClass(BMPlace.class);
    attributeSet.namedLocation = self.address;
    attributeSet.city = self.city;
    attributeSet.country = self.country;
    attributeSet.latitude = @(self.latitude);
    attributeSet.longitude = @(self.longitude);
    attributeSet.altitude = @(self.altitude);
    attributeSet.supportsNavigation = @(YES);
    attributeSet.contentURL = [NSURL URLWithString:self.URLString];
    
    return [[CSSearchableItem alloc] initWithUniqueIdentifier:self.URLScheme domainIdentifier:NSStringFromClass(BMPlace.class) attributeSet:attributeSet];
}

- (NSUserActivity *)userActivity
{
    if (!_userActivity)
    {
        _userActivity = [[NSUserActivity alloc] initWithActivityType:NSUserActivityTypeBrowsingWeb];
        _userActivity.title = self.title;
        _userActivity.eligibleForSearch = YES;
        _userActivity.eligibleForPublicIndexing = YES;
        _userActivity.eligibleForHandoff = YES;
        if ([_userActivity respondsToSelector:@selector(mapItem)])
        {
            _userActivity.mapItem = self.mapItem;
        }
        _userActivity.contentAttributeSet = self.searchableItem.attributeSet;
        _userActivity.keywords = [NSSet setWithArray:_userActivity.contentAttributeSet.keywords];
        _userActivity.webpageURL = [NSURL URLWithString:self.URLString];
    }
    
    return _userActivity;
}

- (BOOL)openIn:(BMNavigation)navigation
{
    return [BMNavigationManager open:self inNavigation:navigation];
}

@end
