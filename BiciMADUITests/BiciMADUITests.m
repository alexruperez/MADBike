//
//  BiciMADUITests.m
//  BiciMADUITests
//
//  Created by alexruperez on 7/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import XCTest;

#import "MADBike-Swift.h"

@interface BiciMADUITests : XCTestCase

@property (nonatomic, strong) XCUIApplication *app;

@end

@implementation BiciMADUITests

- (void)setUp
{
    [super setUp];
    
    self.continueAfterFailure = NO;
    self.app = XCUIApplication.new;
    [Snapshot setupSnapshot:self.app];
    [self.app launch];
    
    if (!self.isLogged)
    {
        [self login];
    }
}

- (void)tearDown
{
    self.app = nil;
    [super tearDown];
}

- (void)testAnnotation
{
    sleep(5);
    XCUIElement *annotation = self.app.otherElements[@"165 - Entrada Matadero, Paseo de la Chopera 14"];
    if (annotation.exists)
    {
        [annotation tap];
        [Snapshot snapshot:@"Annotation" waitForLoadingIndicator:NO];
        XCUIElement *moreDetailsButton = self.app.buttons[NSLocalizedString(@"More details", @"More details")];
        if (moreDetailsButton.exists)
        {
            [moreDetailsButton tap];
            [Snapshot snapshot:@"Detail" waitForLoadingIndicator:NO];
            XCUIElement *incidenceButton = self.app.tables.cells.buttons[NSLocalizedString(@"Report an incidence", @"Report an incidence")];
            XCTAssert(incidenceButton.exists);
            [incidenceButton tap];
            [Snapshot snapshot:@"Incidence" waitForLoadingIndicator:NO];
        }
    }
}

- (void)testFavorites
{
    XCUIElement *favoritesButton = self.app.toolbars.buttons[NSLocalizedString(@"Your favorite stations", @"Your favorite stations")];
    if (favoritesButton.exists)
    {
        [favoritesButton tap];
        sleep(5);
        XCUIElement *errorAlert = self.app.alerts.element;
        if (errorAlert.exists)
        {
            XCUIElement *errorAlertButton = errorAlert.buttons[@"OK"];
            XCTAssert(errorAlertButton.exists);
            [errorAlertButton tap];
            XCUIElement *annotation = self.app.otherElements[@"165 - Entrada Matadero, Paseo de la Chopera nº 14"];
            XCTAssert(annotation.exists);
            [annotation tap];
            XCUIElement *moreDetailsButton = self.app.buttons[NSLocalizedString(@"More details", @"More details")];
            [moreDetailsButton tap];
            XCUIElement *favoriteButton = self.app.tables.cells.buttons[NSLocalizedString(@"Favorite", @"Favorite")];
            [favoriteButton tap];
            [Snapshot snapshot:@"DetailFavorite" waitForLoadingIndicator:NO];
            XCUIElement *closeButton = self.app.navigationBars.element.buttons[NSLocalizedString(@"Close", @"Close")];
            XCTAssert(closeButton.exists);
            [closeButton tap];
            favoritesButton = self.app.toolbars.buttons[NSLocalizedString(@"Your favorite stations", @"Your favorite stations")];
            [favoritesButton tap];
            sleep(5);
        }
        [Snapshot snapshot:@"FavoritesDetail" waitForLoadingIndicator:NO];
        XCUIElement *closeButton = self.app.navigationBars.element.buttons[NSLocalizedString(@"Close", @"Close")];
        [closeButton tap];
        [Snapshot snapshot:@"FavoritesMap" waitForLoadingIndicator:NO];
    }
}

- (void)testSearch
{
    XCUIElement *navigationBar = self.app.navigationBars.element;
    XCTAssert(navigationBar.exists);
    XCUIElement *searchButton = navigationBar.buttons[NSLocalizedString(@"Search", @"Search")];
    if (searchButton.exists)
    {
        [searchButton tap];
        XCUIElement *searchField = navigationBar.searchFields.element;
        XCTAssert(searchField.exists);
        [searchField typeText:@"Plaza de España"];
        XCTAssert([searchField.value isEqualToString:@"Plaza de España"]);
        [Snapshot snapshot:@"Search" waitForLoadingIndicator:NO];
        XCUIElement *doneButton = self.app.buttons[NSLocalizedString(@"Search", @"Search")];
        XCTAssert(doneButton.exists);
        [doneButton tap];
        [Snapshot snapshot:@"SearchDetail" waitForLoadingIndicator:NO];
        XCUIElement *closeButton = navigationBar.buttons[NSLocalizedString(@"Close", @"Close")];
        if (closeButton.exists)
        {
            [closeButton tap];
            [Snapshot snapshot:@"SearchMap" waitForLoadingIndicator:NO];
        }
    }
}

- (void)testWeather
{
    XCUIElementQuery *toolbarsQuery = self.app.toolbars;
    XCUIElement *locationButton = toolbarsQuery.buttons[NSLocalizedString(@"Your location", @"Your location")];
    if (locationButton.exists)
    {
        [locationButton tap];
        XCUIElement *locationAlert = self.app.alerts.element;
        if (locationAlert.exists)
        {
            XCUIElement *locationAlertButton = locationAlert.collectionViews.buttons[NSLocalizedString(@"Allow", @"Allow")];
            XCTAssert(locationAlertButton.exists);
            [locationAlertButton tap];
        }
        sleep(10);
        XCUIElement *weatherButton = toolbarsQuery.buttons[NSLocalizedString(@"Weather", @"Weather")];
        XCTAssert(weatherButton.exists);
        [weatherButton tap];
        [Snapshot snapshot:@"Weather" waitForLoadingIndicator:NO];
    }
}

@end
