//
//  BMPlacesTableViewController.m
//  BiciMAD
//
//  Created by alexruperez on 22/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMPlacesTableViewController.h"

@import MapKit;
@import SPGooglePlacesAutocomplete;

#import "BMManagersAssembly.h"
#import "BMAnalyticsManager.h"
#import "BMPrePermissionManager.h"
#import "BMUserDefaultsManager.h"
#import "BMStation.h"
#import "BMClusterAnnotationView.h"
#import "MKAnnotationView+BMUtils.h"
#import "MADBike-Swift.h"

static NSString * const kBMPlaceCellIdentifier = @"BMPlaceCell";
static NSUInteger const kBMStationsCacheSize = 2;
static NSUInteger const kBMPlaceHistorySize = 8;

@interface BMPlacesTableViewController ()

@property (nonatomic, weak) id<BMPlacesTableViewControllerDelegate> delegate;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, copy) NSArray *places;
@property (nonatomic, copy) NSArray *stations;
@property (nonatomic, copy) NSMutableArray *history;
@property (nonatomic, copy) NSString *input;

@end

@implementation BMPlacesTableViewController

- (instancetype)initWithDelegate:(id<BMPlacesTableViewControllerDelegate>)delegate
{
    self = super.init;
    
    if (self)
    {
        _delegate = delegate;
    }
    
    return self;
}

- (NSArray *)history
{
    if (!_history)
    {
        NSArray *history = [self.managersAssembly.userDefaultsManager storedObjectForKey:kBMUserDefaultsHistoryKey];
        _history = history != nil ? history.mutableCopy : NSMutableArray.new;
    }

    return _history;
}

- (void)addToHistory:(NSString *)input
{
    if (input.length > 0 && ![input isEqualToString:NSLocalizedString(@"Close to me", @"Close to me")])
    {
        if ([self.history containsObject:input])
        {
            [self.history removeObject:input];
        }
        [self.history insertObject:input atIndex:0];
        NSUInteger historyCount = self.history.count;
        NSArray *recentHistory = [self.history subarrayWithRange:NSMakeRange(0, MIN(historyCount, kBMPlaceHistorySize))];
        [self.managersAssembly.userDefaultsManager storeObject:recentHistory forKey:kBMUserDefaultsHistoryKey];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setUserActivityWithActivityType:kBMMADBikeUserActivitySearch title:NSLocalizedString(@"Search", @"Search") description:NSLocalizedString(@"Find the closest stations", @"Find the closest stations")];

    [self configureTableView];
    [self configureLoader];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [BMAnalyticsManager logContentViewWithName:self.bm_className contentType:nil contentId:nil customAttributes:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)configureLoader
{
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.f, 0.f, 50.f, 50.f)];
    self.activityIndicatorView.color = UIColor.bm_tintColor;
    self.activityIndicatorView.backgroundColor = UIColor.clearColor;
    self.tableView.tableFooterView = self.activityIndicatorView;
}

- (void)configureTableView
{
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.tableView.rowHeight = 66.f;
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
}

- (void)showLoader:(BOOL)show
{
    if (show)
    {
        [self.activityIndicatorView startAnimating];
    }
    else
    {
        [self.activityIndicatorView stopAnimating];
    }
}

- (void)reloadDataWithPlaces:(NSArray *)places stations:(NSArray *)stations input:(NSString *)input
{
    if ([self.input isEqualToString:input])
    {
        if (places)
        {
            self.places = places;
        }
        if (stations)
        {
            self.stations = stations;
        }
        if (self.places && self.stations)
        {
            [self showLoader:NO];
        }
    }
    else
    {
        if (input)
        {
            [self showLoader:YES];
        }
        self.places = places;
        self.stations = stations;
        self.input = input;
    }

    self.view.hidden = NO;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 1;
        case 1:
            return (NSInteger)MIN(kBMStationsCacheSize, self.stations.count);
        case 2:
            return (NSInteger)self.places.count;
        case 3:
            return (NSInteger)MIN(kBMPlaceHistorySize, self.history.count);
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 1:
            if (self.stations.count > 0)
            {
                return NSLocalizedString(@"Stations", @"Stations");
            }
            break;
        case 2:
            if (self.places.count > 0)
            {
                return NSLocalizedString(@"Places", @"Places");
            }
            break;
        case 3:
            if (self.history.count > 0)
            {
                return NSLocalizedString(@"History", @"History");
            }
            break;
        default:
            break;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBMPlaceCellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kBMPlaceCellIdentifier];
    }
    
    NSString *text = @"";
    NSString *detailText = @"";
    if (indexPath.section == 0)
    {
        cell.imageView.image = [UIImage imageNamed:@"ic_my_location"];
        text = NSLocalizedString(@"Close to me", @"Close to me");
        detailText = NSLocalizedString(@"Find the closest stations", @"Find the closest stations");
    }
    else if (indexPath.section == 1 && self.stations.count > (NSUInteger)indexPath.row)
    {
        BMStation *station = self.stations[(NSUInteger)indexPath.row];
        if ([station isKindOfClass:BMStation.class])
        {
            BMClusterAnnotationView *annotationView = [BMClusterAnnotationView bm_viewWithAnnotation:station];
            cell.imageView.image = annotationView.annotationImage;
            text = station.name;
            detailText = station.subtitle;
        }
    }
    else if (indexPath.section == 2 && self.places.count > (NSUInteger)indexPath.row)
    {
        SPGooglePlacesAutocompletePlace *place = self.places[(NSUInteger)indexPath.row];
        if ([place isKindOfClass:SPGooglePlacesAutocompletePlace.class])
        {
            cell.imageView.image = [UIImage imageNamed:@"ic_marker_gray"];
            if (place.terms.count > 1)
            {
                NSMutableArray *terms = place.terms.mutableCopy;
                text = terms.firstObject;
                [terms removeObject:text];
                detailText = [terms.copy componentsJoinedByString:@", "];
            }
            else
            {
                text = place.name;
            }
        }
    }
    else if (indexPath.section == 3 && self.history.count > (NSUInteger)indexPath.row)
    {
        cell.imageView.image = [UIImage imageNamed:@"ic_marker_gray"];
        text = self.history[(NSUInteger)indexPath.row];
    }
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    NSArray *inputArray = [self.input componentsSeparatedByString:@" "];
    for (NSString *input in inputArray)
    {
        NSRange inputRange = [text rangeOfString:input options:(NSStringCompareOptions)(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
        if (inputRange.location != NSNotFound)
        {
            [attributedText setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.f]} range:inputRange];
        }
    }
    cell.tintColor = UIColor.bm_tintColor;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.attributedText = attributedText.copy;
    cell.detailTextLabel.textColor = UIColor.bm_tintColor;
    cell.detailTextLabel.text = detailText;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.separatorInset = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    cell.layoutMargins = UIEdgeInsetsZero;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.backgroundView.backgroundColor = UIColor.lightTextColor;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.delegate != nil)
    {
        if (indexPath.section == 3 && self.history.count > (NSUInteger)indexPath.row)
        {
            [self.delegate placesTableViewController:self didSearch:self.history[(NSUInteger)indexPath.row]];
        }
        else
        {
            [self.delegate placesTableViewControllerWillLoadPlacemark:self];

            if (indexPath.section == 0)
            {
                [self.managersAssembly.prePermissionManager location:^(BOOL success) {
                    if (success)
                    {
                        CLLocation *location = self.managersAssembly.locationManager.location;
                        if (location && CLLocationCoordinate2DIsValid(location.coordinate))
                        {
                            [self.managersAssembly.geocoderManager reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                                CLPlacemark *placemark = placemarks.firstObject;
                                if (!placemark)
                                {
                                    placemark = [[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary:nil];
                                }
                                [self.delegate placesTableViewController:self didSelectPlacemark:placemark addressString:placemark.name error:error];
                            }];
                        }
                    }
                }];
            }
            else if (indexPath.section == 1 && self.stations.count > (NSUInteger)indexPath.row)
            {
                BMStation *station = self.stations[(NSUInteger)indexPath.row];
                if ([station isKindOfClass:BMStation.class])
                {
                    [self.delegate placesTableViewController:self didSelectStation:station];
                }
            }
            else if (indexPath.section == 2 && self.places.count > (NSUInteger)indexPath.row)
            {
                SPGooglePlacesAutocompletePlace *place = self.places[(NSUInteger)indexPath.row];
                if ([place isKindOfClass:SPGooglePlacesAutocompletePlace.class])
                {
                    [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
                        [self.delegate placesTableViewController:self didSelectPlacemark:placemark addressString:addressString error:error];
                    }];
                }
            }
        }
    }

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self addToHistory:cell.textLabel.attributedText.string];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSIndexPath *indexPath = nil;
    if (self.places.count > 0)
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    }
    else if (self.stations.count > 0)
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    }
    else
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

@end
