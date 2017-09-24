//
//  BMAnnotationDetailTableViewCellProtocol.h
//  BiciMAD
//
//  Created by alexruperez on 20/4/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import UIKit;

@protocol BMAnnotationDetailTableViewCell;

@protocol BMAnnotationDetailTableViewCellDelegate <NSObject>

- (void)annotationDetailTableViewCell:(UITableViewCell<BMAnnotationDetailTableViewCell> *)cell hasModified:(id)annotation sender:(id)sender;

- (void)annotationDetailTableViewCell:(UITableViewCell<BMAnnotationDetailTableViewCell> *)cell navigateTo:(id)annotation sender:(id)sender;

- (void)annotationDetailTableViewCell:(UITableViewCell<BMAnnotationDetailTableViewCell> *)cell share:(id)annotation sender:(id)sender;

@end

@protocol BMAnnotationDetailTableViewCell <NSObject>

@property (nonatomic, strong) id annotation;

@property (nonatomic, weak) id<BMAnnotationDetailTableViewCellDelegate> delegate;

@property (nonatomic, assign) BOOL shouldHighlightContent;

@end
