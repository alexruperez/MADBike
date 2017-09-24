//
//  DDCLSLogger.m
//
//  Created by alexruperez on 19/8/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "DDCLSLogger.h"

@import Crashlytics;

@implementation DDCLSLogger

- (void)logMessage:(DDLogMessage *)logMessage {
    NSString *message = _logFormatter ? [_logFormatter formatLogMessage:logMessage] : logMessage->_message;
    
    if (message) {
        CLSLog(@"%@", message);
    }
}

- (NSString *)loggerName {
    return @"com.alexruperez.clsLogger";
}

@end
