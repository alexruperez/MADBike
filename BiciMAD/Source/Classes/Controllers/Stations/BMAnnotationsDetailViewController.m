//
//  BMAnnotationsDetailViewController.m
//  BiciMAD
//
//  Created by alexruperez on 21/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMAnnotationsDetailViewController.h"

@import CMMapLauncher;

#import "BMAnalyticsManager.h"
#import "BMManagersAssembly.h"
#import "BMCoreDataManager.h"
#import "BMFavoritesManager.h"
#import "BMUserDefaultsManager.h"
#import "BMDeepLinkingManager.h"
#import "BMStation.h"
#import "BMPlace.h"
#import "BMPromotion.h"
#import "BMStationDetailTableViewCell.h"
#import "BMPlaceDetailTableViewCell.h"
#import "BMPromotionDetailTableViewCell.h"
#import "UITableViewCell+BMUtils.h"
#import "MADBike-Swift.h"

@interface BMAnnotationsDetailViewController () <UITableViewDataSource, UITableViewDelegate, BMAnnotationDetailTableViewCellDelegate, UIPopoverPresentationControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation BMAnnotationsDetailViewController

- (instancetype)init
{
    self = [super initWithNibName:self.nibName bundle:self.bundle];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.titleString)
    {
        self.title = self.titleString;
    }
    else if (self.annotations.count == 1)
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if ([self.annotations.firstObject conformsToProtocol:@protocol(BMNavigable)])
        {
            self.title = [self.annotations.firstObject title];
        }
        if ([self.annotations.firstObject conformsToProtocol:@protocol(BMSearchable)])
        {
            self.userActivity = [self.annotations.firstObject userActivity];
            [self.userActivity becomeCurrent];
        }
    }
    else
    {
        self.title = [NSString stringWithFormat:NSLocalizedString(@"%ld Stations", @"%ld Stations"), self.annotations.count];
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_close"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewController:)];
    self.navigationItem.leftBarButtonItem.accessibilityLabel = NSLocalizedString(@"Close", @"Close");

    [BMStationDetailTableViewCell bm_registerNibOnTableView:self.tableView];
    [BMPlaceDetailTableViewCell bm_registerNibOnTableView:self.tableView];
    [BMPromotionDetailTableViewCell bm_registerNibOnTableView:self.tableView];

    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.tableFooterView = UIView.new;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = UIScreen.mainScreen.bounds.size.width;
}

- (void)setShouldHighlightContent:(BOOL)shouldHighlightContent
{
    _shouldHighlightContent = shouldHighlightContent;
    [(UIVisualEffectView *)self.view setEffect:[UIBlurEffect effectWithStyle:_shouldHighlightContent ? UIBlurEffectStyleDark : UIBlurEffectStyleLight]];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSString *mapType = [self.managersAssembly.userDefaultsManager storedStringForKey:kBMUserDefaultsMapTypeKey];
    
    self.shouldHighlightContent = [mapType isEqualToString:kBMUserDefaultsMapTypeStandardValue] == NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [BMAnalyticsManager logContentViewWithName:self.bm_className contentType:NSStringFromClass(BMStation.class) contentId:self.title customAttributes:@{FBSDKAppEventParameterNameContentType: NSStringFromClass(BMStation.class), FBSDKAppEventParameterNameContentID: self.title ? self.title : NSNull.null}];
    
    [self.userActivity becomeCurrent];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.userActivity resignCurrent];
}

- (IBAction)dismissViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)self.annotations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id annotation = nil;
    
    if (self.annotations.count > (NSUInteger)indexPath.row)
    {
        annotation = self.annotations[(NSUInteger)indexPath.row];
    }
    
    UITableViewCell<BMAnnotationDetailTableViewCell> *cell = [BMStationDetailTableViewCell bm_dequeueReusableCellForIndexPath:indexPath fromTableView:tableView];
    
    if ([annotation isKindOfClass:BMPlace.class])
    {
        cell = [BMPlaceDetailTableViewCell bm_dequeueReusableCellForIndexPath:indexPath fromTableView:tableView];
    }
    if ([annotation isKindOfClass:BMPromotion.class])
    {
        cell = [BMPromotionDetailTableViewCell bm_dequeueReusableCellForIndexPath:indexPath fromTableView:tableView];
    }

    cell.delegate = self;
    cell.shouldHighlightContent = self.shouldHighlightContent;
    cell.annotation = annotation;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = UIColor.clearColor;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    cell.layoutMargins = UIEdgeInsetsZero;
}

#pragma mark - BMAnnotationDetailTableViewCellDelegate

- (void)annotationDetailTableViewCell:(UITableViewCell<BMAnnotationDetailTableViewCell> *)cell hasModified:(id)annotation sender:(id)sender
{
    [self.managersAssembly.favoritesManager save:annotation];
    [self.managersAssembly.coreDataManager save:annotation completion:nil];
}

- (void)annotationDetailTableViewCell:(UITableViewCell<BMAnnotationDetailTableViewCell> *)cell share:(id)annotation sender:(id)sender
{
    [self.managersAssembly.shareManager shareStation:annotation fromViewController:self barButtonItem:sender handler:nil];
}

- (void)annotationDetailTableViewCell:(UITableViewCell<BMAnnotationDetailTableViewCell> *)cell navigateTo:(id)annotation sender:(UIView *)sender
{
    if ([annotation conformsToProtocol:@protocol(BMNavigable)])
    {
        NSNumber *navigation = [self.managersAssembly.userDefaultsManager storedNumberForKey:kBMUserDefaultsNavigationKey];
        
        BMNavigation navigationValue = navigation.integerValue;
        if (!navigation || navigationValue == BMNavigationNotDetermined)
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Navigation", @"Navigation") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Apple Maps", @"Apple Maps") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.managersAssembly.userDefaultsManager storeNumber:@(BMNavigationAppleMaps) forKey:kBMUserDefaultsNavigationKey];
                [annotation openIn:BMNavigationAppleMaps];
            }]];
            if ([CMMapLauncher isMapAppInstalled:CMMapAppGoogleMaps])
            {
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Google Maps", @"Google Maps") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self.managersAssembly.userDefaultsManager storeNumber:@(BMNavigationGoogleMaps) forKey:kBMUserDefaultsNavigationKey];
                    [annotation openIn:BMNavigationGoogleMaps];
                }]];
            }
            if ([CMMapLauncher isMapAppInstalled:CMMapAppCitymapper])
            {
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Citymapper", @"Citymapper") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self.managersAssembly.userDefaultsManager storeNumber:@(BMNavigationCitymapper) forKey:kBMUserDefaultsNavigationKey];
                    [annotation openIn:BMNavigationCitymapper];
                }]];
            }
            if ([CMMapLauncher isMapAppInstalled:CMMapAppNavigon])
            {
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Navigon", @"Navigon") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self.managersAssembly.userDefaultsManager storeNumber:@(BMNavigationNavigon) forKey:kBMUserDefaultsNavigationKey];
                    [annotation openIn:BMNavigationNavigon];
                }]];
            }
            if ([CMMapLauncher isMapAppInstalled:CMMapAppTheTransitApp])
            {
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Transit App", @"Transit App") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self.managersAssembly.userDefaultsManager storeNumber:@(BMNavigationTransitApp) forKey:kBMUserDefaultsNavigationKey];
                    [annotation openIn:BMNavigationTransitApp];
                }]];
            }
            if ([CMMapLauncher isMapAppInstalled:CMMapAppWaze])
            {
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Waze", @"Waze") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self.managersAssembly.userDefaultsManager storeNumber:@(BMNavigationWaze) forKey:kBMUserDefaultsNavigationKey];
                    [annotation openIn:BMNavigationWaze];
                }]];
            }
            if ([CMMapLauncher isMapAppInstalled:CMMapAppYandex])
            {
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yandex", @"Yandex") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self.managersAssembly.userDefaultsManager storeNumber:@(BMNavigationYandex) forKey:kBMUserDefaultsNavigationKey];
                    [annotation openIn:BMNavigationYandex];
                }]];
            }
            
            if (alertController.actions.count > 1)
            {
                if (alertController.popoverPresentationController)
                {
                    alertController.popoverPresentationController.delegate = self;
                    if ([sender isKindOfClass:UIView.class])
                    {
                        alertController.popoverPresentationController.sourceView = sender;
                        alertController.popoverPresentationController.sourceRect = sender.frame;
                    }
                }
                else
                {
                    alertController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                }
                [self presentViewController:alertController animated:YES completion:nil];
                alertController.view.tintColor = UIColor.bm_tintColor;
            }
            else
            {
                [annotation openIn:BMNavigationAppleMaps];
            }
        }
        else
        {
            [annotation openIn:navigationValue];
        }
    }
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController
{
    if (!popoverPresentationController.sourceView || CGRectEqualToRect(popoverPresentationController.sourceRect, CGRectZero))
    {
        if (!popoverPresentationController.barButtonItem && self.navigationItem.leftBarButtonItem)
        {
            popoverPresentationController.barButtonItem = self.navigationItem.leftBarButtonItem;
        }
        else
        {
            popoverPresentationController.sourceView = self.view;
            popoverPresentationController.sourceRect = self.view.frame;
        }
    }
}

@end
