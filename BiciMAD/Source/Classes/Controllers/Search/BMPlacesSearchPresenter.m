//
//  BMPlacesSearchPresenter.m
//  BiciMAD
//
//  Created by alexruperez on 4/3/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMPlacesSearchPresenter.h"

@import FXNotifications;

#import "BMViewControllersAssembly.h"
#import "BMManagersAssembly.h"
#import "BMDeepLinkingManager.h"
#import "BMPlacesTableViewController.h"
#import "BMPlacesService.h"
#import "BMStationsService.h"
#import "BMAnalyticsManager.h"
#import "BMStation.h"

static NSUInteger const kBMSearchControllerOffset = 0;

@interface BMPlacesSearchPresenter () <UISearchControllerDelegate, UISearchResultsUpdating, BMPlacesTableViewControllerDelegate>

@property (nonatomic, strong) BMPlacesTableViewController *searchResultsTableViewController;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, strong) GMSAutocompleteSessionToken *sessionToken;
@property (nonatomic, strong) GMSAutocompleteFilter *filter;

@end

@implementation BMPlacesSearchPresenter

- (instancetype)initWithDelegate:(UIViewController<BMSearchPresenterDelegate> *)delegate
{
    self = [super init];
    
    if (self)
    {
        _delegate = delegate;
    }
    
    return self;
}

- (GMSAutocompleteSessionToken *)sessionToken
{
    if (!_sessionToken)
    {
        _sessionToken = [[GMSAutocompleteSessionToken alloc] init];
    }

    return _sessionToken;
}

- (GMSAutocompleteFilter *)filter
{
    if (!_filter)
    {
        _filter = [[GMSAutocompleteFilter alloc] init];
        _filter.country = @"ES";
    }

    return _filter;
}

- (BMPlacesTableViewController *)searchResultsTableViewController
{
    if (!_searchResultsTableViewController)
    {
        _searchResultsTableViewController = [self.viewControllersAssembly placesTableViewControllerWithDelegate:self];
        _searchResultsTableViewController.sessionToken = self.sessionToken;
    }
    
    return _searchResultsTableViewController;
}

- (UISearchController *)searchController
{
    if (!_searchController)
    {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsTableViewController];
        _searchController.delegate = self;
        _searchController.searchResultsUpdater = self;
        _searchController.hidesNavigationBarDuringPresentation = NO;
    }
    
    return _searchController;
}

- (void)loadViewIfNeeded
{
    [self.searchController loadViewIfNeeded];
    self.searchController.searchBar.placeholder = NSLocalizedString(@"MADBike Search", @"MADBike Search");
    self.delegate.navigationItem.titleView = self.searchController.searchBar;
    
    @weakify(self)
    [self.managersAssembly.notificationCenter addObserver:self forName:kBMMADBikeDeepLinkDirectionsRequestNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        MKDirectionsRequest *directionsRequest = note.object;
        if ([directionsRequest isKindOfClass:MKDirectionsRequest.class])
        {
            CLPlacemark *destinationPlacemark = directionsRequest.destination.placemark;
            @strongify(self)
            if (destinationPlacemark.location && !CLLocationCoordinate2DIsValid(destinationPlacemark.location.coordinate))
            {
                [self.managersAssembly.geocoderManager reverseGeocodeLocation:destinationPlacemark.location completionHandler:^(NSArray *placemarks, NSError *error) {
                    CLPlacemark *placemark = placemarks.firstObject;
                    if (!placemark)
                    {
                        placemark = destinationPlacemark;
                    }
                    [self placesTableViewController:self.searchResultsTableViewController didSelectPlacemark:placemark addressString:destinationPlacemark.name error:nil];
                }];
            }
            else if (destinationPlacemark.postalAddress && !destinationPlacemark.location)
            {
                [self.managersAssembly.geocoderManager geocodePostalAddress:destinationPlacemark.postalAddress completionHandler:^(NSArray *placemarks, NSError *error) {
                    CLPlacemark *placemark = placemarks.firstObject;
                    if (!placemark)
                    {
                        placemark = destinationPlacemark;
                    }
                    [self placesTableViewController:self.searchResultsTableViewController didSelectPlacemark:placemark addressString:destinationPlacemark.name error:nil];
                }];
            }
            else
            {
                [self placesTableViewController:self.searchResultsTableViewController didSelectPlacemark:directionsRequest.destination.placemark addressString:destinationPlacemark.name error:nil];
            }
        }
    }];
    [self.managersAssembly.notificationCenter addObserver:self forName:kBMMADBikeDeepLinkSearchNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note, id observer) {
        NSString *searchQueryString = note.object;
        if ([searchQueryString isKindOfClass:NSString.class])
        {
            @strongify(self)
            self.searchController.searchBar.text = searchQueryString;
        }
    }];
}

- (void)searchPlacesWithInput:(NSString *)input
{
    CLLocation *location = self.delegate.location;
    @weakify(self)
    [self.placesService placesWithInput:input sessionToken:self.sessionToken filter:self.filter bounds:nil boundsMode:kGMSAutocompleteBoundsModeBias successBlock:^(NSArray *places) {
        @strongify(self)
        [self.searchResultsTableViewController reloadDataWithPlaces:places stations:nil input:input];
    } failureBlock:nil];
    [self.stationsService findStationsWithInput:input successBlock:^(NSArray *stations) {
        @strongify(self)

        if (location && CLLocationCoordinate2DIsValid(location.coordinate))
        {
            for (id<BMNavigable> navigable in stations) {
                navigable.distance = [location distanceFromLocation:[[CLLocation alloc] initWithLatitude:navigable.latitude longitude:navigable.longitude]];
            }
        }

        [self.searchResultsTableViewController reloadDataWithPlaces:nil stations:stations input:input];
    } failureBlock:nil];
}

- (void)showSearch:(id)sender
{
    self.searchController.active = !self.searchController.active;
}

#pragma mark - UISearchControllerDelegate

- (void)presentSearchController:(UISearchController *)searchController
{
    searchController.searchBar.delegate = self.searchResultsTableViewController;
    self.searchController.searchBar.placeholder = NSLocalizedString(@"e.g. Puerta del Sol", @"e.g. Puerta del Sol");
    [searchController.searchBar becomeFirstResponder];
    if (self.delegate.navigationItem.rightBarButtonItem)
    {
        self.rightBarButtonItem = self.delegate.navigationItem.rightBarButtonItem;
        self.delegate.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    self.searchController.searchBar.placeholder = NSLocalizedString(@"MADBike Search", @"MADBike Search");
    [searchController.searchBar resignFirstResponder];
    self.delegate.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    if (searchController.active)
    {
        if (searchController.searchBar.text.length >= kBMSearchControllerOffset)
        {
            [self searchPlacesWithInput:searchController.searchBar.text];
        }
        else
        {
            [self.searchResultsTableViewController reloadDataWithPlaces:nil stations:nil input:nil];
        }
    }
}

#pragma mark - BMPlacesTableViewControllerDelegate

- (void)placesTableViewController:(BMPlacesTableViewController *)placesTableViewController didSearch:(NSString *)input
{
    self.searchController.searchBar.text = input;
    [self searchPlacesWithInput:input];
}

- (void)placesTableViewControllerWillLoadPlacemark:(BMPlacesTableViewController *)placesTableViewController
{
    [self showSearch:placesTableViewController];
}

- (void)placesTableViewController:(BMPlacesTableViewController *)placesTableViewController didSelectStation:(BMStation *)station
{
    NSString *addressString = station.title;
    [self.delegate didSearch:@[station] addressString:addressString placemark:nil];
    [BMAnalyticsManager logSearchWithQuery:addressString customAttributes:@{FBSDKAppEventParameterNameContentType: NSStringFromClass(BMStation.class), FBSDKAppEventParameterNameSearchString: addressString ? addressString : NSNull.null, FBSDKAppEventParameterNameSuccess: FBSDKAppEventParameterValueYes}];
}

- (void)placesTableViewController:(BMPlacesTableViewController *)placesTableViewController didSelectPlacemark:(CLPlacemark *)placemark addressString:(NSString *)addressString error:(NSError *)error
{
    if (placemark)
    {
        [self.delegate didSearch:nil addressString:addressString placemark:placemark];
        [BMAnalyticsManager logSearchWithQuery:addressString customAttributes:@{FBSDKAppEventParameterNameContentType: NSStringFromClass(BMStation.class), FBSDKAppEventParameterNameSearchString: addressString ? addressString : NSNull.null, FBSDKAppEventParameterNameSuccess: FBSDKAppEventParameterValueYes}];
        [self.delegate handleError:error completion:nil];
    }
    else
    {
        [BMAnalyticsManager logSearchWithQuery:addressString customAttributes:@{FBSDKAppEventParameterNameContentType: NSStringFromClass(BMStation.class), FBSDKAppEventParameterNameSearchString: addressString ? addressString : NSNull.null, FBSDKAppEventParameterNameSuccess: FBSDKAppEventParameterValueNo}];
        [self.delegate handleError:error completion:nil];
    }
}

@end
