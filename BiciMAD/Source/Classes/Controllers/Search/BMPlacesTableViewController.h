//
//  BMPlacesTableViewController.h
//  BiciMAD
//
//  Created by alexruperez on 22/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import UIKit;
@import CoreLocation;

@class BMPlacesTableViewController;
@class BMManagersAssembly;
@class BMStation;
@class GMSAutocompleteSessionToken;

@protocol BMPlacesTableViewControllerDelegate <NSObject>

- (void)placesTableViewController:(BMPlacesTableViewController *)placesTableViewController didSearch:(NSString *)input;

- (void)placesTableViewController:(BMPlacesTableViewController *)placesTableViewController didSelectPlacemark:(CLPlacemark *)placemark addressString:(NSString *)addressString error:(NSError *)error;

- (void)placesTableViewController:(BMPlacesTableViewController *)placesTableViewController didSelectStation:(BMStation *)station;

@optional

- (void)placesTableViewControllerWillLoadPlacemark:(BMPlacesTableViewController *)placesTableViewController;

@end

@interface BMPlacesTableViewController : UITableViewController <UISearchBarDelegate>

@property (nonatomic, strong) BMManagersAssembly *managersAssembly;
@property (nonatomic, strong) GMSAutocompleteSessionToken *sessionToken;

- (instancetype)initWithDelegate:(id<BMPlacesTableViewControllerDelegate>)delegate;

- (void)reloadDataWithPlaces:(NSArray *)places stations:(NSArray *)stations input:(NSString *)input;

@end
