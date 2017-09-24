//
//  BMPartner.m
//  BiciMAD
//
//  Created by alexruperez on 13/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMPartner.h"

#import "MTLValueTransformer+BMValueTransformers.h"
#import "BMPlace.h"
#import "BMPromotion.h"

static NSString * const kBMWebsitesSeparator = @", ";

@implementation BMPartner

+ (NSValueTransformer *)partnerIdJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)annotationURLJSONTransformer
{
    return MTLValueTransformer.bm_urlValueTransformer;
}

+ (NSValueTransformer *)websitesJSONTransformer
{
    return [MTLValueTransformer bm_stringArrayValueTransformerWithSeparator:kBMWebsitesSeparator];
}

+ (NSValueTransformer *)placesJSONTransformer
{
    return [MTLJSONAdapter arrayTransformerWithModelClass:BMPlace.class];
}

+ (NSValueTransformer *)promotionsJSONTransformer
{
    return [MTLJSONAdapter arrayTransformerWithModelClass:BMPromotion.class];
}

+ (NSString *)managedObjectEntityName
{
    return self.bm_className;
}

+ (NSSet *)propertyKeysForManagedObjectUniquing
{
    return [NSSet setWithObject:NSStringFromSelector(@selector(partnerId))];
}

+ (NSDictionary *)managedObjectKeysByPropertyKey
{
    NSMutableDictionary *managedObjectKeysByPropertyKey = [NSDictionary mtl_identityPropertyMapWithModel:self].mutableCopy;
    [managedObjectKeysByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(attributedDescription))];
    return managedObjectKeysByPropertyKey.copy;
}

+ (NSDictionary *)relationshipModelClassesByPropertyKey
{
    return @{
             NSStringFromSelector(@selector(places)): BMPlace.class,
             NSStringFromSelector(@selector(promotions)): BMPromotion.class
             };
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             NSStringFromSelector(@selector(partnerId)): @"id",
             NSStringFromSelector(@selector(name)): @"name",
             NSStringFromSelector(@selector(descriptionHTML)): @"description",
             NSStringFromSelector(@selector(category)): @"category",
             NSStringFromSelector(@selector(websites)): @"websites",
             NSStringFromSelector(@selector(places)): @"places",
             NSStringFromSelector(@selector(promotions)): @"promotions",
             NSStringFromSelector(@selector(annotationURL)): [@"annotation_x" stringByAppendingString:@(UIScreen.mainScreen.scale).stringValue]
             };
}

+ (NSDictionary *)encodingBehaviorsByPropertyKey
{
    NSMutableDictionary *encodingBehaviorsByPropertyKey = [super encodingBehaviorsByPropertyKey].mutableCopy;
    [encodingBehaviorsByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(attributedDescription))];
    return encodingBehaviorsByPropertyKey.copy;
}

- (void)setPartnerId:(NSString *)partnerId
{
    if (_partnerId != partnerId)
    {
        if ([partnerId isKindOfClass:NSNumber.class])
        {
            _partnerId = [(NSNumber *)partnerId stringValue];
        }
        else if ([partnerId isKindOfClass:NSString.class])
        {
            _partnerId = partnerId;
        }
    }
}

- (void)setDescriptionHTML:(NSString *)descriptionHTML
{
    _descriptionHTML = descriptionHTML;
    if (_descriptionHTML)
    {
        descriptionHTML = [NSString stringWithFormat:@"<span style=\"font-family: %@\">%@</span>", [UIFont systemFontOfSize:0.f].fontName, _descriptionHTML];
        self.attributedDescription = [[NSAttributedString alloc] initWithData:[descriptionHTML dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
    }
}

- (void)setPlaces:(NSArray *)places
{
    _places = places.copy;
    for (BMPlace *place in _places)
    {
        place.partner = self;
    }
}

- (void)setPromotions:(NSArray *)promotions {
    _promotions = promotions.copy;
    for (BMPromotion *promotion in _promotions)
    {
        promotion.partner = self;
    }
}

- (BOOL)isEqual:(BMPartner *)partner
{
    if ([partner isKindOfClass:BMPartner.class])
    {
        return [self.partnerId isEqualToString:partner.partnerId];
    }
    
    return [super isEqual:partner];
}

- (NSUInteger)hash
{
    return self.partnerId.hash;
}

@end
