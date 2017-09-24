//
//  BMPromotion.h
//  BiciMAD
//
//  Created by alexruperez on 13/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import Mantle;
@import MTLManagedObjectAdapter;

#import "BMFavoritableProtocol.h"
#import "BMSearchableProtocol.h"
#import "BMShareableProtocol.h"
#import "BMPartner.h"

typedef NS_ENUM(NSInteger, BMMethod)
{
    BMMethodNotDetermined = -1,
    BMMethodWallet
};

@interface BMPromotion : MTLModel <MTLJSONSerializing, MTLManagedObjectSerializing, BMFavoritable, BMSearchable, BMShareable>

@property (nonatomic, copy, readonly) NSString *promotionId;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *descriptionHTML;
@property (nonatomic, copy) NSAttributedString *attributedDescription;
@property (nonatomic, copy, readonly) NSArray *keywords;
@property (nonatomic, assign, readonly) BMMethod method;
@property (nonatomic, strong, readonly) NSDate *dueDate;
@property (nonatomic, strong, readonly) NSURL *imageURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) BMPartner *partner;

@end
