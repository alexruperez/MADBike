//
//  MTLValueTransformer+BMValueTransformers.h
//  BiciMAD
//
//  Created by alexruperez on 14/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import Mantle;

@interface MTLValueTransformer (BMValueTransformers)

+ (MTLValueTransformer *)bm_urlValueTransformer;
+ (MTLValueTransformer *)bm_doubleValueTransformer;
+ (MTLValueTransformer *)bm_dateValueTransformerWithFormat:(NSString *)dateFormat;
+ (MTLValueTransformer *)bm_stringArrayValueTransformerWithSeparator:(NSString *)separator;

@end
