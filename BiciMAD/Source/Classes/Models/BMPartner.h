//
//  BMPartner.h
//  BiciMAD
//
//  Created by alexruperez on 13/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import Mantle;
@import MTLManagedObjectAdapter;

@interface BMPartner : MTLModel <MTLJSONSerializing, MTLManagedObjectSerializing>

@property (nonatomic, copy, readonly) NSString *partnerId;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *descriptionHTML;
@property (nonatomic, copy) NSAttributedString *attributedDescription;
@property (nonatomic, copy, readonly) NSString *category;
@property (nonatomic, copy, readonly) NSArray *websites;
@property (nonatomic, strong, readonly) NSURL *annotationURL;
@property (nonatomic, copy, readonly) NSArray *places;
@property (nonatomic, copy, readonly) NSArray *promotions;

@end
