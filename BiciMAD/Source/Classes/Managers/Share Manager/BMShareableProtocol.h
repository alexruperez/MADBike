//
//  BMShareableProtocol.h
//  BiciMAD
//
//  Created by alexruperez on 15/11/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@protocol BMShareable <NSObject>

@property (nonatomic, weak, readonly) NSString *URLScheme;
@property (nonatomic, weak, readonly) NSString *URLString;

@end
