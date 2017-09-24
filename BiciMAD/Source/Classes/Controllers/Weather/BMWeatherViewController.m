//
//  BMWeatherViewController.m
//  BiciMAD
//
//  Created by alexruperez on 19/11/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMWeatherViewController.h"

#import "BMServicesAssembly.h"
#import "BMManagersAssembly.h"
#import "BMAnalyticsManager.h"
#import "BMWeatherDownloader.h"

static NSString * const kBMSmileWeatherDemoViewBundleIdentifier = @"org.cocoapods.SmileWeather";
static NSString * const kBMSmileWeatherDemoViewNibName = @"SmileWeatherDemoView";
static NSString * const kBMSmileWeatherForecastCellNibName = @"SmileWeatherForecastCell";
static NSString * const kBMSmileWeatherHourlyCellNibName = @"SmileWeatherHourlyCell";
static NSString * const kBMSmileWeatherPropertyCellNibName = @"SmileWeatherPropertyCell";
static NSString * const kBMSmileWeatherForecastCellReuseIdentifier = @"forecastCell";
static NSString * const kBMSmileWeatherHourlyCellReuseIdentifier = @"hourlyCell";
static NSString * const kBMSmileWeatherPropertyCellReuseIdentifier = @"propertyCell";

@interface SmileWeatherDemoVC ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView_hourly;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView_property;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *currentTempLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tempUnitsSegmentControl;

@property (weak, nonatomic) IBOutlet UIImageView *logo_openweather;
@property (weak, nonatomic) IBOutlet UIImageView *logo_wunderground;

- (void)updateUI;

- (void)configureForForecastCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;

- (void)configureForHourlyCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;

- (void)configureForPropertyCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;

@end

@interface BMWeatherViewController () <SmileDemoChangeTempUnitsDelegate>

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) BMWeatherDownloader *weatherDownloader;
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;

@property (nonatomic, copy) void (^successBlock)(SmileWeatherData *data);
@property (nonatomic, copy) void (^failureBlock)(NSError *error);
@property (nonatomic, copy) void (^tempUnitsBlock)(SmileWeatherData *data, BOOL fahrenheit);

@end

@implementation BMWeatherViewController {
    NSArray *_propertyArray;
}

- (instancetype)init
{
    self = [super initWithNibName:kBMSmileWeatherDemoViewNibName bundle:self.bundle];
    return self;
}

- (NSBundle *)bundle
{
    if (!_bundle)
    {
        _bundle = [NSBundle bundleWithIdentifier:kBMSmileWeatherDemoViewBundleIdentifier];
    }
    return _bundle;
}

- (void)registerNibsWithBundle:(NSBundle *)bundle
{
    [self.collectionView registerNib:[UINib nibWithNibName:kBMSmileWeatherForecastCellNibName bundle:bundle] forCellWithReuseIdentifier:kBMSmileWeatherForecastCellReuseIdentifier];
    [self.collectionView_hourly registerNib:[UINib nibWithNibName:kBMSmileWeatherHourlyCellNibName bundle:bundle] forCellWithReuseIdentifier:kBMSmileWeatherHourlyCellReuseIdentifier];
    [self.collectionView_property registerNib:[UINib nibWithNibName:kBMSmileWeatherPropertyCellNibName bundle:bundle] forCellWithReuseIdentifier:kBMSmileWeatherPropertyCellReuseIdentifier];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerNibsWithBundle:self.bundle];
    
    self.delegate = self;
    
    self.activityView.backgroundColor = UIColor.clearColor;
    self.activityView.color = UIColor.bm_tintColor;
    self.currentTempLabel.textColor = UIColor.bm_tintColor;
    self.tempUnitsSegmentControl.tintColor = UIColor.bm_tintColor;
    self.higlightedInterfaceColor = UIColor.bm_tintColor;
    
    self.logo_openweather.hidden = YES;
    self.logo_wunderground.hidden = YES;
    
    self.title = NSLocalizedString(@"Weather", @"Weather");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_close"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewController:)];
    self.navigationItem.leftBarButtonItem.accessibilityLabel = NSLocalizedString(@"Close", @"Close");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [BMAnalyticsManager logContentViewWithName:self.bm_className contentType:nil contentId:nil customAttributes:nil];
}

- (IBAction)dismissViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIVisualEffectView *)visualEffectView
{
    if (!_visualEffectView)
    {
        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        UIView *view = self.view;
        view.backgroundColor = UIColor.clearColor;
        [_visualEffectView.contentView addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *variableBindings = NSDictionaryOfVariableBindings(view);
        [_visualEffectView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:(NSLayoutFormatOptions)kNilOptions metrics:nil views:variableBindings]];
        [_visualEffectView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:(NSLayoutFormatOptions)kNilOptions metrics:nil views:variableBindings]];
        self.view = _visualEffectView;
    }

    return _visualEffectView;
}

- (void)setShouldHighlightContent:(BOOL)shouldHighlightContent
{
    _shouldHighlightContent = shouldHighlightContent;
    [self.visualEffectView setEffect:[UIBlurEffect effectWithStyle:_shouldHighlightContent ? UIBlurEffectStyleExtraLight : UIBlurEffectStyleLight]];
}

- (BMWeatherDownloader *)weatherDownloader
{
    if (!_weatherDownloader)
    {
        _weatherDownloader = self.servicesAssembly.weatherDownloader;
    }
    
    return _weatherDownloader;
}

- (void)setData:(SmileWeatherData *)data
{
    [super setData:data];
    
    @weakify(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self)
        self.logo_openweather.hidden = YES;
        self.logo_wunderground.hidden = YES;
    });
}

- (void)setPlacemark:(CLPlacemark *)placemark
{
    _location = nil;
    _placemark = placemark;
    [self getWeatherDataFromPlacemark];
}

- (void)setLocation:(CLLocation *)location
{
    _placemark = nil;
    _location = location;
    [self getWeatherDataFromLocation];
}

- (void)getWeatherDataFromLocation
{
    @weakify(self)
    [self.weatherDownloader getWeatherDataFromLocation:self.location completion:^(SmileWeatherData *data, NSError *error) {
        @strongify(self)
        [self handleResponse:data error:error];
    }];
}

- (void)getWeatherDataFromPlacemark
{
    @weakify(self)
    [self.weatherDownloader getWeatherDataFromPlacemark:self.placemark completion:^(SmileWeatherData *data, NSError *error) {
        @strongify(self)
        [self handleResponse:data error:error];
    }];
}

- (void)updateUI
{
    [super updateUI];
    
    self.view.backgroundColor = UIColor.clearColor;
    
    NSString *pressureStri = self.data.currentData.pressure;
    if ([self.data.currentData.pressureTrend isEqualToString:@"+"])
    {
        pressureStri = [pressureStri stringByAppendingString:@"↑"];
    }
    
    NSString *windStri = self.data.currentData.windSpeed;
    if (self.data.currentData.windDirection.length > 0)
    {
        NSString *dir = [NSString stringWithFormat:@" %@", self.data.currentData.windDirection];
        windStri = [windStri stringByAppendingString:dir];
    }
    
    NSDictionary *propertyPair1 = @{@"smile_wind": windStri ? windStri : @""};
    NSDictionary *propertyPair2 = @{@"smile_umbrella": self.data.currentData.precipitation ? self.data.currentData.precipitation : @""};
    NSDictionary *propertyPair3 = @{@"smile_pressure": pressureStri ? pressureStri : @""};
    NSDictionary *propertyPair4 = @{@"smile_drop": self.data.currentData.humidity ? self.data.currentData.humidity : @""};
    NSDictionary *propertyPair5 = @{@"smile_sunglass": self.data.currentData.UV ? self.data.currentData.UV : @""};
    NSDictionary *propertyPair6 = @{@"smile_sunrise": self.data.currentData.sunRise ? self.data.currentData.sunRise : @""};
    NSDictionary *propertyPair7 = @{@"smile_sunset": self.data.currentData.sunSet ? self.data.currentData.sunSet : @""};
    
    _propertyArray = @[propertyPair1, propertyPair2, propertyPair3, propertyPair4, propertyPair5, propertyPair6, propertyPair7];
}

- (void)configureForForecastCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    [super configureForForecastCell:cell atIndexPath:indexPath];
    
    UILabel *weekLabel = [cell viewWithTag:100];
    
    if (indexPath.row == 0)
    {
        weekLabel.backgroundColor = UIColor.bm_backgroundColor;
    }
    else
    {
        weekLabel.textColor = UIColor.bm_tintColor;
    }
}

- (void)configureForHourlyCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    [super configureForHourlyCell:cell atIndexPath:indexPath];
    
    if (self.data)
    {
        UILabel *popLabel = [cell viewWithTag:400];
        popLabel.textColor = UIColor.bm_tintColor;
    }
}

- (void)configureForPropertyCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    [super configureForPropertyCell:cell atIndexPath:indexPath];
    
    if (self.data)
    {
        UIImageView *iconImageView = [cell viewWithTag:100];
        NSDictionary *propertyDic = _propertyArray[(NSUInteger)indexPath.row];
        NSString *iconName = [propertyDic allKeys][0];
        iconImageView.image = [[UIImage imageNamed: iconName inBundle:self.bundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
}

- (void)handleResponse:(SmileWeatherData *)data error:(NSError *)error
{
    if (!error)
    {
        self.data = data;
        
        if (self.successBlock)
        {
            self.successBlock(data);
        }
    }
    else
    {
        DDLogError(@"Weather error: %@", error.localizedDescription);
        
        if (self.failureBlock)
        {
            self.failureBlock(error);
        }
    }
}

#pragma mark - SmileDemoChangeTempUnitsDelegate

- (void)changeTempUnitsToFahrenheit:(BOOL)isFahrenheit
{
    if (self.tempUnitsBlock)
    {
        self.tempUnitsBlock(self.data, isFahrenheit);
    }
}

@end
