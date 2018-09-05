//
//  BMAirQualityViewController.m
//  BiciMAD
//
//  Created by alexruperez on 5/6/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMAirQualityViewController.h"

@import RESideMenu;
@import MapKit;
@import SVPulsingAnnotationView;
@import AFNetworking;
@import InAppSettingsKit;
@import FXNotifications;

#import "BMFormulaCollectionViewCell.h"
#import "BMAirQualityService.h"
#import "BMManagersAssembly.h"
#import "BMUserDefaultsManager.h"
#import "BMAnalyticsManager.h"
#import "BMHeatmapRenderer.h"
#import "UICollectionViewCell+BMUtils.h"
#import "MKAnnotationView+BMUtils.h"
#import "BMAirQuality.h"
#import "MADBike-Swift.h"

static NSString * const kBMDefaultFormula = @"NO₂";

@interface BMAirQualityViewController () <MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, copy) NSArray *airQualities;
@property (nonatomic, copy) NSArray *formulas;
@property (nonatomic, copy) NSString *currentFormula;

@end

@implementation BMAirQualityViewController

- (instancetype)init
{
    self = [super initWithNibName:self.nibName bundle:self.bundle];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Air Quality", @"Air Quality");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController:)];
    self.navigationItem.leftBarButtonItem.accessibilityLabel = NSLocalizedString(@"Menu", @"Menu");

    [self setUserActivityWithActivityType:kBMMADBikeUserActivityAirQuality title:NSLocalizedString(@"Air Quality", @"Air Quality") description:nil];

    [BMFormulaCollectionViewCell bm_registerNibOnCollectionView:self.collectionView];
    self.collectionView.backgroundView = self.activityIndicatorView;
    
    self.currentFormula = kBMDefaultFormula;
    
    @weakify(self)
    [self.managersAssembly.notificationCenter addObserver:self forName:UIApplicationDidBecomeActiveNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self reloadAirQualities];
    }];
    [self.managersAssembly.notificationCenter addObserver:self forName:AFNetworkingReachabilityDidChangeNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self reloadAirQualities];
    }];
    [self.managersAssembly.notificationCenter addObserver:self forName:kIASKAppSettingChanged object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self configureMap];
    }];
    [self.managersAssembly.notificationCenter addObserver:self forName:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self configureMap];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureMap];
    
    [self reloadAirQualities];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [BMAnalyticsManager logContentViewWithName:self.bm_className contentType:NSStringFromClass(BMAirQuality.class) contentId:nil customAttributes:@{FBSDKAppEventParameterNameContentType: NSStringFromClass(BMAirQuality.class)}];
}

- (UIActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicatorView.color = UIColor.bm_tintColor;
    }
    
    return _activityIndicatorView;
}

- (void)configureMap
{
    self.mapView.showsCompass = [self.managersAssembly.userDefaultsManager storedBoolForKey:kBMUserDefaultsCompassKey];
    self.mapView.showsScale = [self.managersAssembly.userDefaultsManager storedBoolForKey:kBMUserDefaultsScaleKey];
    
    if (CLLocationManager.authorizationStatus >= kCLAuthorizationStatusAuthorizedAlways)
    {
        self.mapView.showsUserLocation = YES;
    }
}

- (void)reloadAirQualities
{
    if (self.airQualities.count == 0) {
        [self.activityIndicatorView startAnimating];
    }
    @weakify(self)
    [self.airQualityService airQualitiesWithOnlyCurrentValues:YES onlyAverage:NO discardAverage:YES successBlock:^(NSArray *airQualities) {
        @strongify(self)
        if (airQualities.count > 0)
        {
            self.airQualities = airQualities;
        }
        
        [self.activityIndicatorView stopAnimating];
        [self reloadData];
    } failureBlock:^(NSError *error) {
        @strongify(self)
        [self.activityIndicatorView stopAnimating];
        [self handleError:error completion:nil];
    }];
}

- (void)reloadData
{
    if (self.airQualities.count > 0)
    {
        [self.mapView removeOverlays:self.mapView.overlays];
        
        NSMutableSet *formulas = NSMutableSet.new;
        DTMHeatmap *heatmap = DTMHeatmap.new;
        NSMutableDictionary *data = NSMutableDictionary.new;
        
        for (BMAirQuality *airQuality in self.airQualities)
        {
            NSValue *mapPointValue = airQuality.mapPointValue;
            
            for (BMAirQualityMetric *metric in airQuality.metrics)
            {
                if (metric.values.count > 0)
                {
                    [formulas addObject:metric.formula];
                    
                    if ([metric.formula isEqualToString:self.currentFormula])
                    {
                        data[mapPointValue] = metric.values.lastObject;
                    }
                }
            }
        }
        
        self.formulas = formulas.allObjects;
        [self.collectionView reloadData];
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:(NSInteger)[self.formulas indexOfObject:self.currentFormula] inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        
        heatmap.data = data.copy;
        
        [self.mapView addOverlay:heatmap level:MKOverlayLevelAboveRoads];
        [self.mapView setVisibleMapRect:heatmap.boundingRect edgePadding:UIEdgeInsetsZero animated:YES];
    }
}

- (void)handleError:(NSError *)error completion:(void (^)(void))completion
{
    if (!self.presentedViewController && [error.domain isEqualToString:NSURLErrorDomain] && error.code != NSURLErrorCancelled)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"Ok") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (completion)
            {
                completion();
            }
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        alertController.view.tintColor = UIColor.bm_tintColor;
    }
    else if (completion)
    {
        completion();
    }
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    return [[BMHeatmapRenderer alloc] initWithOverlay:overlay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView;
    
    if([annotation isKindOfClass:MKUserLocation.class])
    {
        SVPulsingAnnotationView *userAnnotationView = (SVPulsingAnnotationView *)[SVPulsingAnnotationView bm_dequeueReusableAnnotationViewFromMapView:mapView];
        if (!userAnnotationView)
        {
            userAnnotationView = [SVPulsingAnnotationView bm_viewWithAnnotation:annotation];
            userAnnotationView.annotationColor = UIColor.bm_tintColor;
        }
        
        userAnnotationView.canShowCallout = YES;
        
        annotationView = userAnnotationView;
    }
    
    return annotationView;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (NSInteger)self.formulas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BMFormulaCollectionViewCell *cell = [BMFormulaCollectionViewCell bm_dequeueReusableCellForIndexPath:indexPath fromCollectionView:collectionView];
    cell.formulaLabel.text = NSLocalizedString(self.formulas[(NSUInteger)indexPath.item], @"Formula");
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentFormula = self.formulas[(NSUInteger)indexPath.item];
    [self reloadData];
}

@end
