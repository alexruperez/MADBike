//
//  BMTwitterTimelinePageViewController.h
//  BiciMAD
//
//  Created by alexruperez on 14/8/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

@import UIKit;

@class BMViewControllersAssembly;
@class TweetPresenter;

@interface BMTwitterTimelinePageViewController : UIPageViewController

- (instancetype)initWithDataSources:(NSArray *)dataSources titles:(NSArray *)titles viewControllersAssembly:(BMViewControllersAssembly *)viewControllersAssembly;
@property (nonatomic, strong) NSNotificationCenter *notificationCenter;
@property (nonatomic, strong) TweetPresenter *tweetPresenter;

@end
