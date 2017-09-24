////////////////////////////////////////////////////////////////////////////////
//
//  TYPHOON FRAMEWORK
//  Copyright 2015, Typhoon Framework Contributors
//  All Rights Reserved.
//
//  NOTICE: The authors permit you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import "TyphoonViewHelpers.h"
#import "TyphoonStoryboard.h"
#import "NSLayoutConstraint+TyphoonOutletTransfer.h"
#import "OCLogTemplate.h"

@implementation TyphoonViewHelpers

+ (id)viewFromDefinition:(NSString *)definitionKey originalView:(UIView *)original
{
    if ([[original subviews] count] > 0) {
        LogInfo(@"Warning: placeholder view contains (%d) subviews. They will be replaced by typhoon definition '%@'", (int)[[original subviews] count], definitionKey);
    }
    TyphoonComponentFactory *currentFactory = [TyphoonComponentFactory factoryForResolvingUI];
    if (!currentFactory) {
        [NSException raise:NSInternalInconsistencyException format:@"Can't find Typhoon factory to resolve definition from xib. Check [TyphoonComponentFactory setFactoryForResolvingUI:] method."];
    }
    id result = [currentFactory componentForKey:definitionKey];
    if (![result isKindOfClass:[UIView class]]) {
        [NSException raise:NSInternalInconsistencyException format:@"Error: definition for key '%@' is not kind of UIView but %@", definitionKey, result];
    }
    [self transferPropertiesFromView:original toView:result];
    return result;
}

+ (void)transferPropertiesFromView:(UIView *)src toView:(UIView *)dst
{
    //Transferring autolayout
    dst.translatesAutoresizingMaskIntoConstraints = src.translatesAutoresizingMaskIntoConstraints;

    for (NSLayoutConstraint *constraint in src.constraints) {
        BOOL replaceFirstItem = [constraint firstItem] == src;
        BOOL replaceSecondItem = [constraint secondItem] == src;
        id firstItem = replaceFirstItem ? dst : constraint.firstItem;
        id secondItem = replaceSecondItem ? dst : constraint.secondItem;
        NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:firstItem
                                                                         attribute:constraint.firstAttribute
                                                                         relatedBy:constraint.relation
                                                                            toItem:secondItem
                                                                         attribute:constraint.secondAttribute
                                                                        multiplier:constraint.multiplier
                                                                          constant:constraint.constant];
        newConstraint.priority = constraint.priority;
        
        NSString *typhoonTransferIdentifier = [[NSUUID UUID] UUIDString];
        constraint.typhoonTransferIdentifier = typhoonTransferIdentifier;
        newConstraint.typhoonTransferIdentifier = typhoonTransferIdentifier;
        newConstraint.typhoonTransferConstraint = constraint;

        [dst addConstraint:newConstraint];
    }
    
    dst.frame = src.frame;
    dst.autoresizesSubviews = src.autoresizesSubviews;
    dst.autoresizingMask = src.autoresizingMask;
}

@end
