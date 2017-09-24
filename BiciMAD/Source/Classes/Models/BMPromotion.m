//
//  BMPromotion.m
//  BiciMAD
//
//  Created by alexruperez on 13/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMPromotion.h"

@import AFNetworking;

#import "MTLValueTransformer+BMValueTransformers.h"

static NSString * const kBMMADBikeDeepLinkPromotionURLString = @"madbike://promotion?id=";
static NSString * const kBMMADBikeWebPromotionURLString = @"https://www.madbikeapp.com/promotions/";

static NSString * const kBMDateFormat = @"yyyy-MM-dd";
static NSString * const kBMKeywordsSeparator = @", ";

static NSString * const kBMMethodNotDetermined = @"none";
static NSString * const kBMMethodWallet = @"wallet";

@implementation BMPromotion

@synthesize favorite, userActivity = _userActivity;

+ (NSValueTransformer *)promotionIdJSONTransformer
{
    return MTLValueTransformer.bm_doubleValueTransformer;
}

+ (NSValueTransformer *)dueDateJSONTransformer
{
    return [MTLValueTransformer bm_dateValueTransformerWithFormat:kBMDateFormat];
}

+ (NSValueTransformer *)methodJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
        if ([value isKindOfClass:NSString.class] && [value isEqualToString:kBMMethodWallet])
        {
            value = @(BMMethodWallet);
        }
        else
        {
            value = @(BMMethodNotDetermined);
        }
        *success = [value isKindOfClass:NSNumber.class];
        return value;
    } reverseBlock:^id(id value, BOOL *success, NSError **error) {
        if ([value integerValue] == BMMethodWallet)
        {
            value = kBMMethodWallet;
        }
        else
        {
            value = kBMMethodNotDetermined;
        }
        *success = [value isKindOfClass:NSString.class];
        return value;
    }];
}

+ (NSValueTransformer *)keywordsJSONTransformer
{
    return [MTLValueTransformer bm_stringArrayValueTransformerWithSeparator:kBMKeywordsSeparator];
}

+ (NSValueTransformer *)imageURLJSONTransformer
{
    return MTLValueTransformer.bm_urlValueTransformer;
}

+ (NSString *)managedObjectEntityName
{
    return self.bm_className;
}

+ (NSSet *)propertyKeysForManagedObjectUniquing
{
    return [NSSet setWithObject:NSStringFromSelector(@selector(promotionId))];
}

+ (NSDictionary *)managedObjectKeysByPropertyKey
{
    NSMutableDictionary *managedObjectKeysByPropertyKey = [NSDictionary mtl_identityPropertyMapWithModel:self].mutableCopy;
    [managedObjectKeysByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(userActivity))];
    [managedObjectKeysByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(attributedDescription))];
    [managedObjectKeysByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(image))];
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
             NSStringFromSelector(@selector(promotionId)): @"id",
             NSStringFromSelector(@selector(title)): @"title",
             NSStringFromSelector(@selector(descriptionHTML)): @"description",
             NSStringFromSelector(@selector(keywords)): @"keywords",
             NSStringFromSelector(@selector(dueDate)): @"due_date",
             NSStringFromSelector(@selector(method)): @"method",
             NSStringFromSelector(@selector(imageURL)): [@"image_x" stringByAppendingString:@(UIScreen.mainScreen.scale).stringValue]
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
    [encodingBehaviorsByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(partner))];
    [encodingBehaviorsByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(attributedDescription))];
    [encodingBehaviorsByPropertyKey removeObjectForKey:NSStringFromSelector(@selector(image))];
    return encodingBehaviorsByPropertyKey.copy;
}

- (AFImageDownloader *)imageDownloader
{
    return AFImageDownloader.defaultInstance;
}

- (void)setPromotionId:(NSString *)promotionId
{
    if (_promotionId != promotionId)
    {
        if ([promotionId isKindOfClass:NSNumber.class])
        {
            _promotionId = [(NSNumber *)promotionId stringValue];
        }
        else if ([promotionId isKindOfClass:NSString.class])
        {
            _promotionId = promotionId;
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

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    if (_imageURL)
    {
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:_imageURL];
        if (imageRequest)
        {
            @weakify(self);
            [self.imageDownloader downloadImageForURLRequest:imageRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                @strongify(self);
                self.image = image;
            } failure:nil];
        }
    }
}

- (BOOL)isEqual:(BMPromotion *)promotion
{
    if ([promotion isKindOfClass:BMPromotion.class])
    {
        return [self.promotionId isEqualToString:promotion.promotionId];
    }
    
    return [super isEqual:promotion];
}

- (NSUInteger)hash
{
    return self.promotionId.hash;
}

- (NSString *)URLScheme
{
    return [kBMMADBikeDeepLinkPromotionURLString stringByAppendingString:self.promotionId];
}

- (NSString *)URLString
{
    return [kBMMADBikeWebPromotionURLString stringByAppendingString:self.promotionId];
}

- (CSSearchableItem *)searchableItem
{
    CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeItem];
    
    attributeSet.title = self.title;
    attributeSet.displayName = self.title;
    NSMutableArray *keywords = @[NSLocalizedString(@"MADBike", @"MADBike"), NSLocalizedString(@"BiciMAD", @"BiciMAD"), NSLocalizedString(@"city", @"city"), NSLocalizedString(@"center", @"center"), NSLocalizedString(@"downtown", @"downtown"), NSLocalizedString(@"promotions", @"promotions")].mutableCopy;
    [keywords addObjectsFromArray:[self.title componentsSeparatedByString:@" "]];
    attributeSet.keywords = keywords.copy;
    attributeSet.identifier = self.promotionId;
    attributeSet.relatedUniqueIdentifier = self.URLString;
    attributeSet.creator = NSLocalizedString(@"MADBike", @"MADBike");
    attributeSet.kind = NSStringFromClass(BMPromotion.class);
    attributeSet.contentURL = [NSURL URLWithString:self.URLString];
    
    return [[CSSearchableItem alloc] initWithUniqueIdentifier:self.URLScheme domainIdentifier:NSStringFromClass(BMPromotion.class) attributeSet:attributeSet];
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
        _userActivity.contentAttributeSet = self.searchableItem.attributeSet;
        _userActivity.keywords = [NSSet setWithArray:_userActivity.contentAttributeSet.keywords];
        _userActivity.webpageURL = [NSURL URLWithString:self.URLString];
    }
    
    return _userActivity;
}

@end
