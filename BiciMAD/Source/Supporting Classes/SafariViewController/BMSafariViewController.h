//
//  BMSafariViewController.h
//  BiciMAD
//
//  Created by alexruperez on 6/1/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import SafariServices;

typedef void (^BMLoadCompletionHandler)(BOOL didLoad);
typedef void (^BMFinishCompletionHandler)(void);

@interface BMSafariViewController : SFSafariViewController

- (instancetype)initWithURLString:(NSString *)URLString onLoad:(BMLoadCompletionHandler)load onFinish:(BMFinishCompletionHandler)finish;

@end
