////////////////////////////////////////////////////////////////////////////////
//
//  TYPHOON FRAMEWORK
//  Copyright 2013, Typhoon Framework Contributors
//  All Rights Reserved.
//
//  NOTICE: The authors permit you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////


#import "TyphoonTestUtils.h"


@implementation TyphoonTestUtils

+ (void)waitForCondition:(TyphoonAsynchConditionBlock)condition
{
    [self waitForCondition:condition andPerformTests:^{
        //No assertions - wait for condition only.
    }];
}

+ (void)waitForCondition:(TyphoonAsynchConditionBlock)condition andPerformTests:(TyphoonTestAssertionsBlock)assertions
{
    [self wait:7 secondsForCondition:condition andPerformTests:assertions];
}

+ (void)wait:(NSTimeInterval)seconds secondsForCondition:(TyphoonAsynchConditionBlock)condition andPerformTests:(TyphoonTestAssertionsBlock)assertions
{
    __block BOOL conditionMet = NO;
    for (float i = 0; i < seconds * 4; i = i + 0.1f) {
        conditionMet = condition();
        if (conditionMet) {
            break;
        }
        else {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
    }
    if (conditionMet) {
        if (assertions) {
            assertions();
        }
    }
    else {
        [NSException raise:NSGenericException format:@"Condition didn't happen before timeout: %f", seconds];
    }
}


@end
