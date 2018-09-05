//
//  BMStationsViewController.m
//  BiciMAD
//
//  Created by alexruperez on 20/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMStationsViewController.h"

@import AFNetworking;
@import DOFavoriteButton;
@import BBBadgeBarButtonItem;
@import InAppSettingsKit;
@import GoogleMaps;
@import FXNotifications;
@import Popover;

#import "BMAnalyticsManager.h"
#import "BMStation.h"
#import "BMPlace.h"
#import "BMHTTPClientConstants.h"
#import "BMStationsService.h"
#import "BMViewControllersAssembly.h"
#import "BMApplicationAssembly.h"
#import "BMManagersAssembly.h"
#import "BMPresentersAssembly.h"
#import "BMPrePermissionManager.h"
#import "BMFavoritesManager.h"
#import "BMUserDefaultsManager.h"
#import "BMCoreDataManager.h"
#import "BMDeepLinkingManager.h"
#import "NSArray+BMUtils.h"
#import "BMAnnotationsDetailViewController.h"
#import "BMWeatherViewController.h"
#import "BMMapPresenterProtocol.h"
#import "BMSearchPresenterProtocol.h"
#import "MADBike-Swift.h"

@interface BMStationsViewController () <BMMapPresenterDelegate, BMSearchPresenterDelegate>

@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic, weak) IBOutlet UIButton *reloadAllStationsButton;
@property (nonatomic, weak) IBOutlet UIButton *showUserLocationButton;
@property (nonatomic, weak) IBOutlet DOFavoriteButton *favoritesButton;
@property (nonatomic, strong) IBOutlet BBBadgeBarButtonItem *weatherBarButtonItem;
@property (nonatomic, weak) IBOutlet UIButton *weatherButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *filterBarButtonItem;

@property (nonatomic, strong) UIView *mapView;
@property (nonatomic, strong) id<BMMapPresenter> mapPresenter;
@property (nonatomic, strong) id<BMSearchPresenter> searchPresenter;
@property (nonatomic, strong) BMWeatherViewController *weatherViewController;
@property (nonatomic, strong) FilterView *filterView;

@property (nonatomic, assign) BOOL isReloadingAllStations;

@end

@implementation BMStationsViewController

- (BMWeatherViewController *)weatherViewController
{
    if (!_weatherViewController)
    {
        _weatherViewController = [self.viewControllersAssembly weatherViewController];
        @weakify(self)
        [_weatherViewController setSuccessBlock:^(SmileWeatherData *data) {
            @strongify(self)
            [self updateWeatherBarButtonItem];
            SmileWeatherForecastDayData *forecastDayData = data.forecastData.firstObject;
            if (forecastDayData.icon.length > 0)
            {
                [self.weatherButton setTitle:forecastDayData.icon forState:UIControlStateNormal];
            }
        }];
        [_weatherViewController setFailureBlock:^(NSError *error) {
            @strongify(self)
            [self.weatherButton setTitle:@"!" forState:UIControlStateNormal];
            self.weatherBarButtonItem.badgeValue = @"--";
            [self handleError:error completion:nil];
        }];
        [_weatherViewController setTempUnitsBlock:^(SmileWeatherData *data, BOOL fahrenheit) {
            @strongify(self)
            [self.managersAssembly.userDefaultsManager storeBool:fahrenheit forKey:kBMUserDefaultsFahrenheitKey];
            [self updateWeatherBarButtonItem];
        }];
    }
    
    return _weatherViewController;
}

- (FilterView *)filterView
{
    if (!_filterView)
    {
        _filterView = FilterView.bm_loadFromNib;
        BMUserDefaultsManager *userDefaultsManager = self.managersAssembly.userDefaultsManager;
        @weakify(self)
        [_filterView setHandler:^(NSArray<BMStation *> *stations, BOOL green, BOOL red, BOOL yellow, BOOL gray) {
            @strongify(self)
            [self.mapPresenter clearAllAnnotations:^{
                @strongify(self)
                [self.mapPresenter addAnnotations:stations withCompletionHandler:^{
                    @strongify(self)
                    self.filterBarButtonItem.image = [UIImage imageNamed:green && red && yellow && gray ? @"ic_layers" : @"ic_layers_hidden"];
                    if (self.filterView.completion)
                    {
                        self.filterView.completion();
                        self.filterView.completion = nil;
                    }
                    [userDefaultsManager storeBool:green forKey:kBMUserDefaultsGreenFilterKey];
                    [userDefaultsManager storeBool:red forKey:kBMUserDefaultsRedFilterKey];
                    [userDefaultsManager storeBool:yellow forKey:kBMUserDefaultsYellowFilterKey];
                    [userDefaultsManager storeBool:gray forKey:kBMUserDefaultsGrayFilterKey];
                }];
            }];
        }];
        BOOL green = [userDefaultsManager storedBoolForKey:kBMUserDefaultsGreenFilterKey];
        BOOL red = [userDefaultsManager storedBoolForKey:kBMUserDefaultsRedFilterKey];
        BOOL yellow = [userDefaultsManager storedBoolForKey:kBMUserDefaultsYellowFilterKey];
        BOOL gray = [userDefaultsManager storedBoolForKey:kBMUserDefaultsGrayFilterKey];
        [_filterView configureFilterWithGreen:green red:red yellow:yellow gray:gray];
    }

    NSString *mapType = [self.managersAssembly.userDefaultsManager storedStringForKey:kBMUserDefaultsMapTypeKey];
    _filterView.shouldHighlightContent = [mapType isEqualToString:kBMUserDefaultsMapTypeStandardValue] == NO;

    return _filterView;
}

- (void)setMapView:(UIView *)mapView
{
    _mapView = mapView;
    [self showMapView:_mapView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MADBike", @"MADBike");
    self.navigationItem.leftBarButtonItem.accessibilityLabel = NSLocalizedString(@"Menu", @"Menu");

    [self setUserActivityWithActivityType:kBMMADBikeUserActivityStation title:NSLocalizedString(@"Stations", @"Stations") description:nil];
    
    self.view.backgroundColor = UIColor.bm_backgroundColor;
    
    self.definesPresentationContext = YES;
    
    self.toolBar.barTintColor = UIColor.bm_barTintColor;
    
    self.searchPresenter = [self.presentersAssembly placesSearchPresenterWithDelegate:self];
    
    [self updateSettings:nil];
    
    self.weatherBarButtonItem = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:self.weatherButton];
    self.weatherBarButtonItem.badgeBGColor = UIColor.whiteColor;
    self.weatherBarButtonItem.badgeTextColor = UIColor.bm_tintColor;
    self.weatherBarButtonItem.badgeOriginX = 20.f;
    self.weatherBarButtonItem.badgeOriginY = 6.f;
    self.weatherBarButtonItem.badgeValue = @"--";
    
    self.reloadAllStationsButton.accessibilityLabel = NSLocalizedString(@"Reload stations", @"Reload stations");
    self.showUserLocationButton.accessibilityLabel = NSLocalizedString(@"Your location", @"Your location");
    self.favoritesButton.accessibilityLabel = NSLocalizedString(@"Your favorites", @"Your favorites");
    self.weatherButton.accessibilityLabel = NSLocalizedString(@"Weather", @"Weather");
    self.filterBarButtonItem.accessibilityLabel = NSLocalizedString(@"Filter", @"Filter");
    
    [self.searchPresenter loadViewIfNeeded];
    
    @weakify(self)
    [self.managersAssembly.notificationCenter addObserver:self forName:UIApplicationDidBecomeActiveNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self applicationDidBecomeActive:note];
    }];
    [self.managersAssembly.notificationCenter addObserver:self forName:AFNetworkingReachabilityDidChangeNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self reachabilityDidChange:note];
    }];
    [self.managersAssembly.notificationCenter addObserver:self forName:kIASKAppSettingChanged object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self updateSettings:note];
    }];
    [self.managersAssembly.notificationCenter addObserver:self forName:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self updateSettings:note];
    }];
    [self.managersAssembly.notificationCenter addObserver:self forName:kBMMADBikeDeepLinkStationNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self handleStationDeepLink:note];
    }];
    [self.managersAssembly.notificationCenter addObserver:self forName:kBMMADBikeDeepLinkWeatherNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self showWeather:note.object];
    }];
    [self.managersAssembly.notificationCenter addObserver:self forName:kBMMADBikeDeepLinkSearchNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self showSearch:note];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self reloadAllStations:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [BMAnalyticsManager logContentViewWithName:self.bm_className contentType:NSStringFromClass(BMStation.class) contentId:nil customAttributes:@{FBSDKAppEventParameterNameContentType: NSStringFromClass(BMStation.class), kBMMapEngineKey: self.mapView ? NSStringFromClass(self.mapView.class) : NSNull.null}];

    NSString *currentAppVersion = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
    if (![self.managersAssembly.userDefaultsManager storedBoolForKey:currentAppVersion])
    {
        [self.managersAssembly.prePermissionManager push:nil];
        [self.managersAssembly.userDefaultsManager storeBool:YES forKey:currentAppVersion];
    }
}

- (void)showMapView:(UIView *)mapView
{
    if (self.view.subviews.count > 4)
    {
        [self.view.subviews[1] removeFromSuperview];
    }
    mapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:mapView atIndex:1];
    NSDictionary *variableBindings = NSDictionaryOfVariableBindings(mapView);
    CGFloat bottom = [mapView isKindOfClass:MKMapView.class] ? 22.f : 11.f;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapView]-bottom-|" options:(NSLayoutFormatOptions)kNilOptions metrics:@{@"bottom": @(bottom)} views:variableBindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapView]|" options:(NSLayoutFormatOptions)kNilOptions metrics:nil views:variableBindings]];
}

- (void)reloadMapView
{
    NSString *mapEngine = [self.managersAssembly.userDefaultsManager storedStringForKey:kBMUserDefaultsMapEngineKey];
    
    if ([mapEngine isEqualToString:kBMUserDefaultsMapEngineAppleMapsValue] && ![self.mapView isKindOfClass:MKMapView.class])
    {
        self.mapView = MKMapView.new;
        self.mapPresenter = [self.presentersAssembly mapKitPresenterWithDelegate:self mapView:self.mapView];
        [self.mapPresenter mapViewLoaded];
    }
    else if ([mapEngine isEqualToString:kBMUserDefaultsMapEngineGoogleMapsValue] && ![self.mapView isKindOfClass:GMSMapView.class])
    {
        self.mapView = GMSMapView.new;
        self.mapPresenter = [self.presentersAssembly googleMapsPresenterWithDelegate:self mapView:self.mapView];
        [self.mapPresenter mapViewLoaded];
    }
}

- (void)applicationDidBecomeActive:(id)sender
{
    [self updateSettings:sender];
    
    [self reloadAllStations:sender];
}

- (void)reachabilityDidChange:(id)sender
{
    CLLocation *location = self.mapPresenter.location;
    
    if (location && CLLocationCoordinate2DIsValid(location.coordinate))
    {
        self.weatherViewController.location = location;
    }
    
    [self reloadAllStations:sender];
}

- (void)updateSettings:(id)sender
{
    [self reloadMapView];
    
    [self.mapPresenter updateMapOptions];
    
    [self updateWeatherBarButtonItem];
}

- (void)handleStationDeepLink:(id)sender
{
    if ([sender isKindOfClass:NSNotification.class])
    {
        sender = [sender object];
    }
    
    if (self.favoritesButton.selected)
    {
        [self.favoritesButton deselect];
    }
    
    self.isReloadingAllStations = NO;
    
    @weakify(self)
    [self reloadAllStations:sender completion:^(NSArray *stations) {
        @strongify(self)
        if ([sender isKindOfClass:BMStation.class])
        {
            [self handleStationDeepLink:@[sender] animated:YES];
        }
        else if ([sender isKindOfClass:NSString.class] && [sender integerValue])
        {
            stations = [stations bm_filter:^BOOL(BMStation *station) {
                return [station.stationId isEqualToString:sender];
            }];
            if (stations.count > 0)
            {
                [self handleStationDeepLink:stations animated:YES];
            }
            else
            {
                [self.managersAssembly.coreDataManager findKeys:@[sender] modelClass:BMStation.class completion:^(NSArray *results, NSError *error) {
                    if (results)
                    {
                        @strongify(self)
                        [self handleStationDeepLink:results animated:YES];
                    }
                }];
            }
        }
    }];
}

- (void)handleStationDeepLink:(NSArray *)stations animated:(BOOL)animated
{
    [self.filterView forceShow:stations];
    [self.mapPresenter setVisibleMapAnnotations:stations animated:animated];
    [self presentAnnotationsDetail:stations titleString:nil animated:animated];
}

- (void)updateWeatherBarButtonItem
{
    NSString *mapType = [self.managersAssembly.userDefaultsManager storedStringForKey:kBMUserDefaultsMapTypeKey];
    self.weatherViewController.fahrenheit = [self.managersAssembly.userDefaultsManager storedBoolForKey:kBMUserDefaultsFahrenheitKey];
    self.weatherViewController.shouldHighlightContent = [mapType isEqualToString:kBMUserDefaultsMapTypeStandardValue] == NO;
    NSString *currentTempString;
    if (self.weatherViewController.fahrenheit)
    {
        currentTempString = self.weatherViewController.data.currentData.currentTempStri_Fahrenheit;
    }
    else
    {
        currentTempString = self.weatherViewController.data.currentData.currentTempStri_Celsius;
    }
    
    if (currentTempString.length > 0)
    {
        self.weatherBarButtonItem.badgeValue = currentTempString;
    }
}

- (IBAction)reloadAllStations:(id)sender
{
    [self reloadAllStations:sender completion:nil];
}

- (void)reloadAllStations:(id)sender completion:(void (^)(NSArray *stations))completion
{
    if (!self.isReloadingAllStations)
    {
        self.isReloadingAllStations = YES;
        BOOL shouldRefreshMapView = sender == self.reloadAllStationsButton || sender == self.favoritesButton || !self.mapPresenter.annotations.count;
        id selectedAnnotation = sender != self.favoritesButton ? self.mapPresenter.selectedAnnotations.anyObject : nil;
        
        selectedAnnotation = [self.mapPresenter uniqueLocationAnnotation:selectedAnnotation];
        
        [self reloadAllStationsButtonRotation:YES];
        
        @weakify(self)
        [self.stationsService allStationsWithSuccessBlock:^(NSArray *stations) {
            @strongify(self)
            [self reloadAllStationsButtonRotation:NO];

            CLLocation *location = self.location;
            if (location && CLLocationCoordinate2DIsValid(location.coordinate))
            {
                for (id<BMNavigable> navigable in stations) {
                    navigable.distance = [location distanceFromLocation:[[CLLocation alloc] initWithLatitude:navigable.latitude longitude:navigable.longitude]];
                }
            }
            
            if (self.favoritesButton.selected)
            {
                [self loadFavoritesStations:sender completion:completion];
            }
            else
            {
                [self.filterView setCompletion:^{
                    @strongify(self)
                    if (shouldRefreshMapView)
                    {
                        [self.mapPresenter setVisibleMapAnnotations:self.mapPresenter.annotations animated:YES];
                    }
                    if ([stations containsObject:selectedAnnotation])
                    {
                        [self.mapPresenter selectAnnotation:selectedAnnotation andZoomToRegionWithLatitudinalMeters:0.f longitudinalMeters:0.f];
                    }
                    self.isReloadingAllStations = NO;
                    if (completion)
                    {
                        completion(stations);
                    }
                }];
                self.filterView.stations = stations;
            }
        } failureBlock:^(NSError *error) {
            @strongify(self)
            [self reloadAllStationsButtonRotation:NO];
            [self handleError:error completion:^{
                self.isReloadingAllStations = NO;
                if (completion)
                {
                    completion(nil);
                }
            }];
        }];
    }
}

- (void)reloadAllStationsButtonRotation:(BOOL)rotation
{
    [self.reloadAllStationsButton.layer removeAnimationForKey:@"reloadAllStationsButtonRotation"];
    
    if (rotation)
    {
        CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotateAnimation.fromValue = @0.f;
        rotateAnimation.toValue = @(2*M_PI);
        rotateAnimation.duration = 0.5f;
        rotateAnimation.repeatCount = HUGE_VALF;
        
        [self.reloadAllStationsButton.layer addAnimation:rotateAnimation forKey:@"reloadAllStationsButtonRotation"];
    }
}

- (void)loadFavoritesStations:(id)sender completion:(void (^)(NSArray *stations))completion
{
    NSArray *favorites = [self.managersAssembly.favoritesManager findAll:BMStation.class];
    favorites = [favorites arrayByAddingObjectsFromArray:[self.managersAssembly.favoritesManager findAll:BMPlace.class]];
    //favorites = [favorites arrayByAddingObjectsFromArray:[self.managersAssembly.favoritesManager findAll:BMPromotion.class]];
    if (favorites.count > 0)
    {
        if (sender == self.favoritesButton)
        {
            [self presentAnnotationsDetail:favorites titleString:NSLocalizedString(@"Favorites", @"Favorites") animated:YES];
        }
        @weakify(self)
        [self.filterView setCompletion:^{
            @strongify(self)
            [self.mapPresenter setVisibleMapAnnotations:self.mapPresenter.annotations animated:YES];
            self.isReloadingAllStations = NO;
            if (completion)
            {
                completion(favorites);
            }
        }];
        self.filterView.stations = favorites;
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"D'oh", @"D'oh") message:NSLocalizedString(@"Still don't have favorite stations.", @"Still don't have favorite stations.") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"Ok") style:UIAlertActionStyleCancel handler:nil]];
        @weakify(self)
        [self presentViewController:alertController animated:YES completion:^{
            @strongify(self)
            [self.favoritesButton deselect];
            self.isReloadingAllStations = NO;
            [self reloadAllStations:sender completion:completion];
        }];
        alertController.view.tintColor = UIColor.bm_tintColor;
    }
}

- (IBAction)switchFavorites:(id)sender
{
    if (self.favoritesButton.selected)
    {
        [self.favoritesButton deselect];
    }
    else
    {
        [self.favoritesButton select];
    }
    
    [self reloadAllStations:sender];
}

- (IBAction)showWeather:(id)sender
{
    [self showUserLocation:sender];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.weatherViewController];
    navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)showFilter:(id)sender
{
    Popover *filterPopover = Popover.new;
    filterPopover.popoverColor = UIColor.clearColor;
    [filterPopover show:self.filterView fromView:[sender view] inView:self.applicationAssembly.window];
}

- (IBAction)showUserLocation:(id)sender
{
    [self.mapPresenter showUserLocation:sender];
}

- (IBAction)showSearch:(id)sender
{
    [self.searchPresenter showSearch:sender];
}

- (void)presentAnnotationsDetail:(NSArray *)annotations titleString:(NSString *)titleString animated:(BOOL)animated
{
    BMAnnotationsDetailViewController *annotationsDetailViewController = [self.viewControllersAssembly annotationsDetailViewControllerWithAnnotations:annotations titleString:titleString];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:annotationsDetailViewController];
    navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    if (self.presentedViewController)
    {
        @weakify(self)
        [self.presentedViewController dismissViewControllerAnimated:animated completion:^{
            @strongify(self)
            [self presentViewController:navigationController animated:animated completion:nil];
        }];
    }
    else
    {
        [self presentViewController:navigationController animated:animated completion:nil];
    }
}

- (void)locationPermissionsNeeded:(void (^)(BOOL success))completionHandler
{
    [self.managersAssembly.prePermissionManager location:completionHandler];
}

- (void)handleError:(NSError *)error completion:(void (^)(void))completion
{
    if (!self.presentedViewController && [error.domain isEqualToString:NSURLErrorDomain] && error.code != NSURLErrorCancelled)
    {
        NSString *message = error.localizedDescription;
        if (error.code == NSURLErrorNotConnectedToInternet)
        {
            message = [message stringByAppendingString:NSLocalizedString(@"\nPotentially outdated information.", @"\nPotentially outdated information.")];
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error") message:message preferredStyle:UIAlertControllerStyleAlert];
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

#pragma mark - BMMapPresenterDelegate

- (void)didUpdateUserLocation:(CLLocation *)location
{
    @weakify(self)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kBMHTTPClientDefaultTimeout / 10.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self)
            self.weatherViewController.location = location;
        });
    });
}

- (void)didFinishRenderingMap:(BOOL)fullyRendered
{
    if (!self.weatherViewController.location)
    {
        CLLocationCoordinate2D centerCoordinate = self.mapPresenter.centerCoordinate;
        if (CLLocationCoordinate2DIsValid(centerCoordinate))
        {
            self.weatherViewController.location = [[CLLocation alloc] initWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
        }
    }
}

#pragma mark - BMSearchPresenterDelegate

- (CLLocation *)location
{
    return self.mapPresenter.location;
}

- (CLLocationCoordinate2D)centerCoordinate
{
    return self.mapPresenter.centerCoordinate;
}

- (void)didSearch:(NSArray *)results addressString:(NSString *)addressString placemark:(CLPlacemark *)placemark
{
    if (self.favoritesButton.selected)
    {
        [self.favoritesButton deselect];
        @weakify(self)
        [self reloadAllStations:self.searchPresenter completion:^(NSArray *stations) {
            @strongify(self)
            if (results)
            {
                [self.filterView forceShow:results];
                [self.mapPresenter setVisibleMapAnnotations:results animated:YES];
                [self presentAnnotationsDetail:results titleString:addressString animated:YES];
            }
            else
            {
                CLCircularRegion *region = (CLCircularRegion *)placemark.region;
                if (!region)
                {
                    [self.mapPresenter showUserLocation:placemark];
                }
                else
                {
                    [self.mapPresenter setVisibleCircularRegion:region animated:YES];
                }
            }
        }];
    }
    else if (results)
    {
        @weakify(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self)
            [self.filterView forceShow:results];
            [self.mapPresenter setVisibleMapAnnotations:results animated:YES];
            [self presentAnnotationsDetail:results titleString:addressString animated:YES];
        });
    }
    else
    {
        CLCircularRegion *region = (CLCircularRegion *)placemark.region;
        if (!region)
        {
            [self.mapPresenter showUserLocation:placemark];
        }
        else
        {
            [self.mapPresenter setVisibleCircularRegion:region animated:YES];
        }
    }
}

@end
