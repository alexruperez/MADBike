////
////  SmileWeatherDemoVC.m
////  SmileWeather-Example
////
////  Created by ryu-ushin on 7/15/15.
////  Copyright (c) 2015 rain. All rights reserved.
////

#if TARGET_OS_IOS

#import "SmileWeatherDemoVC.h"
#import "SmileLineLayout.h"
#import "SmileWeatherDownLoader.h"

@interface SmileWeatherDemoVC () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView_hourly;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView_property;

@property (weak, nonatomic) IBOutlet UILabel *currentTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *localityLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftViewLeadingConstraint;

@property (weak, nonatomic) IBOutlet UISegmentedControl *tempUnitsSegmentControl;


@property (weak, nonatomic) IBOutlet UILabel *conditionsLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (weak, nonatomic) IBOutlet UIImageView *logo_openweather;
@property (weak, nonatomic) IBOutlet UIImageView *logo_wunderground;

@end

#define kStoryBoardName @"SmileWeatherDemoView"

@implementation SmileWeatherDemoVC{
    NSArray *_propertyArray;
    UIView *_hairLine_top;
    UIView *_hairLine_bottom;
    SmileLineLayout *_lineLayout;
}

typedef NS_ENUM(int, SmileHairLinePosition) {
    top,
    left,
    bottom,
    right
};

static NSString * const NIB_name_forecast = @"SmileWeatherForecastCell";
static NSString * const NIB_name_forecast_hourly = @"SmileWeatherHourlyCell";
static NSString * const NIB_name_forecast_property = @"SmileWeatherPropertyCell";

static NSString * const reuseIdentifier = @"forecastCell";
static NSString * const reuseIdentifier_hourly = @"hourlyCell";
static NSString * const reuseIdentifier_property = @"propertyCell";

- (IBAction)convertTempUnit:(UISegmentedControl*)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.fahrenheit = NO;
    } else {
        self.fahrenheit = YES;
    }
    if ([self.delegate respondsToSelector:@selector(changeTempUnitsToFahrenheit:)]) {
        [self.delegate changeTempUnitsToFahrenheit:self.isFahrenheit];
    }
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainInterfaceColor = [UIColor blackColor];
    self.mainInterfaceNightModeColor = [UIColor whiteColor];
    self.higlightedInterfaceColor = [UIColor redColor];
    
    if (self.nightMode) {
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    } else {
        self.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    }
    
    NSUInteger itemNum = 4;
    if ([SmileWeatherDownLoader sharedDownloader].weatherAPI == API_openweathermap) {
        itemNum = 5;
    }
    _lineLayout = [[SmileLineLayout alloc] initWithItemNum:itemNum];
    self.collectionView.collectionViewLayout = _lineLayout;
    NSBundle *bundle = [NSBundle bundleForClass: self.class];
    [self.collectionView registerNib:[UINib nibWithNibName:NIB_name_forecast bundle:bundle] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView_hourly registerNib:[UINib nibWithNibName:NIB_name_forecast_hourly bundle:bundle] forCellWithReuseIdentifier:reuseIdentifier_hourly];
    [self.collectionView_property registerNib:[UINib nibWithNibName:NIB_name_forecast_property bundle:bundle] forCellWithReuseIdentifier:reuseIdentifier_property];
    
    //hair line
    [self addHairLine];
    
    //add shadow
    [self addShadowToView:self.view];
    
    self.activityView.backgroundColor = self.higlightedInterfaceColor;
    self.activityView.layer.cornerRadius = CGRectGetMidX(self.activityView.bounds);
    
    [self handleAPILogoAndLayout];
}

-(void)handleAPILogoAndLayout {
    NSUInteger itemNum = 4;
    if ([SmileWeatherDownLoader sharedDownloader].weatherAPI == API_wunderground) {
        self.logo_openweather.hidden = YES;
        self.logo_wunderground.hidden = NO;
    } else if ([SmileWeatherDownLoader sharedDownloader].weatherAPI == API_openweathermap){
        self.logo_openweather.hidden = NO;
        self.logo_wunderground.hidden = YES;
        itemNum = 5;
    }
    if (_lineLayout.itemNum != itemNum) {
        _lineLayout.itemNum = itemNum;
        [self viewDidLayoutSubviews];
    }
}

-(void)addShadowToView:(UIView*)view{
    //add shadow
    view.layer.masksToBounds = NO;
    // 影のかかる方向を指定する
    view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    // 影の透明度
    view.layer.shadowOpacity = 0.1f;
    // 影の色
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    // ぼかしの量
    view.layer.shadowRadius = 3.0f;
}

-(void)addHairLine{
    UIColor *hairLineColor = [UIColor blackColor];
    CGFloat hairline_Height = 0.5;
    _hairLine_top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), hairline_Height)];
    _hairLine_top.backgroundColor = hairLineColor;
    _hairLine_top.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_hairLine_top];
    
    _hairLine_bottom = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-hairline_Height, CGRectGetWidth(self.view.bounds), hairline_Height)];
    _hairLine_bottom.backgroundColor = hairLineColor;
    _hairLine_bottom.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_hairLine_bottom];
    
    [self addHeightConstraintToView:_hairLine_top];
    [self addHeightConstraintToView:_hairLine_bottom];
    
    [self addConstraintsToPosition:top forView:_hairLine_top];
    [self addConstraintsToPosition:bottom forView:_hairLine_bottom];
}

-(void)addConstraintsToPosition:(SmileHairLinePosition)position forView:(UIView*)view{
    if(position == top) {
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.collectionView_hourly attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.collectionView_hourly attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.collectionView_hourly attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        
        NSArray *constraints = @[left, right, top];
        [self.view addConstraints: constraints];
    } else if (position == bottom){
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.collectionView_hourly attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.collectionView_hourly attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.collectionView_hourly attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        
        NSArray *constraints = @[left, right, bottom];
        [self.view addConstraints: constraints];
    }
}

-(void)addHeightConstraintToView:(UIView*)view{
    NSDictionary *viewsDictionary = @{@"View":view};
    NSArray *constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[View(0.5)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewsDictionary];
    [view addConstraints:constraint_H];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    SmileLineLayout *lineLayout =  (SmileLineLayout*)self.collectionView.collectionViewLayout;
    [lineLayout shouldInvalidateLayoutForBoundsChange:self.view.bounds];
    CGFloat left = lineLayout.sectionInset.left;
    self.leftViewLeadingConstraint.constant = left;
    UICollectionViewFlowLayout*hourlyLayout = (UICollectionViewFlowLayout*)self.collectionView_hourly.collectionViewLayout;
    hourlyLayout.sectionInset = UIEdgeInsetsMake(0, left, 0, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setter
-(void)setNightMode:(BOOL)nightMode{
    if (_nightMode != nightMode) {
        _nightMode = nightMode;
        SmileWeather_DispatchMainThread(^(){
            [self.collectionView reloadData];
            [self.collectionView_hourly reloadData];
            [self.collectionView_property reloadData];
            [self updateUI];
        });
    }

}

-(void)setLoading:(BOOL)loading {
    _loading = loading;
    SmileWeather_DispatchMainThread(^(){
        if (_loading) {
            [self.activityView startAnimating];
        } else {
            [self.activityView stopAnimating];
        }
    });
}

-(void)setFahrenheit:(BOOL)isFahrenheit{
    if (_fahrenheit != isFahrenheit) {
        _fahrenheit = isFahrenheit;
        SmileWeather_DispatchMainThread(^(){
            self.tempUnitsSegmentControl.selectedSegmentIndex = isFahrenheit;
            [self.collectionView reloadData];
            [self.collectionView_hourly reloadData];
            [self.collectionView_property reloadData];
            [self updateUI];
        });
    }
}

-(void)setData:(SmileWeatherData *)data{
    if (_data != data) {
        _data = data;
        SmileWeather_DispatchMainThread(^(){
            [self.collectionView reloadData];
            [self.collectionView_hourly reloadData];
            [self.collectionView_property reloadData];
            if (self.data.hourlyData.count > 0) {
                 [self.collectionView_hourly scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
            }
            [self updateUI];
            [self handleAPILogoAndLayout];
        });
    }
}

-(void)updateUI{
    if (!self.data.currentData) {
        return;
    }
    
    if (self.nightMode) {
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        self.localityLabel.textColor = self.mainInterfaceNightModeColor;
        self.conditionsLabel.textColor = self.mainInterfaceNightModeColor;
        _hairLine_bottom.backgroundColor = self.mainInterfaceNightModeColor;
        _hairLine_top.backgroundColor = self.mainInterfaceNightModeColor;
    } else {
        self.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        self.localityLabel.textColor = self.mainInterfaceColor;
        self.conditionsLabel.textColor = self.mainInterfaceColor;
        _hairLine_bottom.backgroundColor = self.mainInterfaceColor;
        _hairLine_top.backgroundColor = self.mainInterfaceColor;
    }
    
    NSString *temp;
    if (self.isFahrenheit) {
        temp = self.data.currentData.currentTempStri_Fahrenheit;
    } else {
        temp = self.data.currentData.currentTempStri_Celsius;
    }
    
    self.currentTempLabel.textColor = self.higlightedInterfaceColor;
    self.currentTempLabel.text = temp;
    self.localityLabel.text = self.data.placeName;
    
    NSString *pressureStri = self.data.currentData.pressure;
    if ([self.data.currentData.pressureTrend isEqualToString:@"+"]) {
        pressureStri = [pressureStri stringByAppendingString:@"↑"];
    }

    NSString *windStri = self.data.currentData.windSpeed;
    if (self.data.currentData.windDirection.length > 0) {
        NSString *dir = [NSString stringWithFormat:@" %@", self.data.currentData.windDirection];
        windStri = [windStri stringByAppendingString:dir];
    }
    
    NSDictionary *propertyPair1 = @{@"smile_wind": windStri};
    NSDictionary *propertyPair2 = @{@"smile_umbrella": self.data.currentData.precipitation};
    NSDictionary *propertyPair3 = @{@"smile_pressure": pressureStri};
    NSDictionary *propertyPair4 = @{@"smile_drop": self.data.currentData.humidity};
    NSDictionary *propertyPair5 = @{@"smile_sunglass": self.data.currentData.UV};
    NSDictionary *propertyPair6 = @{@"smile_sunrise": self.data.currentData.sunRise};
    NSDictionary *propertyPair7 = @{@"smile_sunset": self.data.currentData.sunSet};
    
    _propertyArray = @[propertyPair1, propertyPair2, propertyPair3, propertyPair4, propertyPair5, propertyPair6, propertyPair7];
    
    self.conditionsLabel.text = self.data.currentData.condition;
    self.loading = NO;
    
    self.tempUnitsSegmentControl.tintColor = self.higlightedInterfaceColor;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSInteger number = 0;

    if (collectionView == self.collectionView) {
        if (self.data.forecastData.count > 0) {
            number = self.data.forecastData.count;
        }
    } else if (collectionView == self.collectionView_hourly){
        if (self.data.hourlyData.count > 0) {
            number = self.data.hourlyData.count;
        }
    } else if (collectionView == self.collectionView_property){
        if (_propertyArray.count > 0) {
            number = _propertyArray.count;
        }
    }
    
    
    return number;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    if (collectionView == self.collectionView) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        [self configureForForecastCell:cell atIndexPath:indexPath];
    } else if (collectionView == self.collectionView_hourly){
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier_hourly forIndexPath:indexPath];
        [self configureForHourlyCell:cell atIndexPath:indexPath];
    } else if (collectionView == self.collectionView_property){
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier_property forIndexPath:indexPath];
        [self configureForPropertyCell:cell atIndexPath:indexPath];
    }
    return cell;
}

-(void)configureForForecastCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    UILabel *weekLabel = (UILabel*)[cell viewWithTag:100];
    UILabel *weatherLabel = (UILabel*)[cell viewWithTag:200];
    UILabel *highTempLabel = (UILabel*)[cell viewWithTag:300];
    UILabel *lowTempLabel = (UILabel*)[cell viewWithTag:400];
    
    if (self.nightMode) {
        weatherLabel.textColor = self.mainInterfaceNightModeColor;
        highTempLabel.textColor = self.mainInterfaceNightModeColor;
    } else {
        weatherLabel.textColor = self.mainInterfaceColor;
        highTempLabel.textColor = self.mainInterfaceColor;
    }
    
    // Configure the cell
    if (!self.data) {
        weekLabel.text = @"--";
        weatherLabel.text = @"";
        highTempLabel.text = @"--";
        lowTempLabel.text = @"--";
    } else {
        SmileWeatherForecastDayData *forecastDayData = self.data.forecastData[indexPath.row];
        weekLabel.text = forecastDayData.dayOfWeek;
        weatherLabel.text = forecastDayData.icon;
        
        if (indexPath.row == 0) {
            weekLabel.backgroundColor = self.higlightedInterfaceColor;
            if (self.nightMode){
                weekLabel.textColor = self.mainInterfaceNightModeColor;
            }else{
                weekLabel.textColor = [UIColor whiteColor];
            }
            weekLabel.layer.cornerRadius = 3;
            weekLabel.layer.masksToBounds = YES;
        } else {
            weekLabel.backgroundColor = [UIColor clearColor];
            weekLabel.textColor = self.higlightedInterfaceColor;
            weekLabel.layer.cornerRadius = 0;
            weekLabel.layer.masksToBounds = NO;
        }
        
        
        NSString *tempHigh;
        NSString *tempLow;
        if (self.isFahrenheit) {
            tempHigh = forecastDayData.highTempStri_Fahrenheit;
            tempLow = forecastDayData.lowTempStri_Fahrenheit;
        } else {
            tempHigh = forecastDayData.highTempStri_Celsius;
            tempLow = forecastDayData.lowTempStri_Celsius;
        }

        
        highTempLabel.text = tempHigh;
        lowTempLabel.text = tempLow;
    }
}

-(void)configureForHourlyCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    UILabel *timeLabel = (UILabel*)[cell viewWithTag:100];
    UILabel *weatherLabel = (UILabel*)[cell viewWithTag:200];
    UILabel *tempLabel = (UILabel*)[cell viewWithTag:300];
    UILabel *popLabel = (UILabel*)[cell viewWithTag:400];
    
    if (self.nightMode) {
        timeLabel.textColor = self.mainInterfaceNightModeColor;
        weatherLabel.textColor = self.mainInterfaceNightModeColor;
        tempLabel.textColor = self.mainInterfaceNightModeColor;
    } else {
        timeLabel.textColor = self.mainInterfaceColor;
        weatherLabel.textColor = self.mainInterfaceColor;
        tempLabel.textColor = self.mainInterfaceColor;
    }


    popLabel.text = @"";
    popLabel.textColor = self.higlightedInterfaceColor;
    
    // Configure the cell
    if (!self.data) {
        timeLabel.text = @"--:--";
        weatherLabel.text = @"";
        tempLabel.text = @"--";
    } else {
        SmileWeatherHourlyData *hourlyData = self.data.hourlyData[indexPath.row];
        timeLabel.text = hourlyData.localizedTime;
        weatherLabel.text = hourlyData.icon;
        
        NSString *temp;
        if (self.isFahrenheit) {
            temp = hourlyData.currentTempStri_Fahrenheit;
        } else {
            temp = hourlyData.currentTempStri_Celsius;
        }
        
        tempLabel.text = temp;
        
        if (hourlyData.precipitationRaw.length > 0) {
            if ([hourlyData.precipitationRaw contains:@"mm"]) {
                if (![hourlyData.precipitationRaw isEqualToString:@"0 mm"]) {
                    popLabel.text = hourlyData.precipitation;
                }
            } else {
                NSInteger pop = hourlyData.precipitationRaw.integerValue;
                if (pop > 15) {
                    popLabel.text = hourlyData.precipitation;
                }
            }
        }
    }
}

-(void)configureForPropertyCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    UIImageView *iconImageView = (UIImageView*)[cell viewWithTag:100];
    UILabel *valueLabel = (UILabel*)[cell viewWithTag:200];
    
    // Configure the cell
    if (!self.data) {
        iconImageView.image = nil;
        valueLabel.text = @"--";
    } else {
        NSDictionary *propertyDic = _propertyArray[indexPath.row];
        NSString *iconName = [propertyDic allKeys][0];
        iconImageView.image = [UIImage imageNamed: iconName];
        valueLabel.text = propertyDic[iconName];
    }
    
    iconImageView.image = [iconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if (self.nightMode) {
        valueLabel.textColor = self.mainInterfaceNightModeColor;
        [iconImageView setTintColor:self.mainInterfaceNightModeColor];
    } else {
        valueLabel.textColor = self.mainInterfaceColor;
        [iconImageView setTintColor:self.mainInterfaceColor];
    }
}

#pragma mark <UICollectionViewDelegate>


#pragma mark - DemoVC

+(SmileWeatherDemoVC*)createDemoVC {
    NSBundle *bundle = [NSBundle bundleForClass: self.class];
    SmileWeatherDemoVC *demoVC = [[SmileWeatherDemoVC alloc] initWithNibName:kStoryBoardName bundle:bundle];
    return demoVC;
}

+(SmileWeatherDemoVC *)DemoVCToView:(UIView *)parentView {
    SmileWeatherDemoVC *demoVC = [SmileWeatherDemoVC createDemoVC];
    
    demoVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [parentView addSubview:demoVC.view];
    
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:parentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:demoVC.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:parentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:demoVC.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:parentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:demoVC.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSArray *constraints = @[left, right, top];
    
    [parentView addConstraints: constraints];
    
    NSDictionary *viewsDictionary = @{@"View":demoVC.view};
    NSArray *constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[View(425)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewsDictionary];
    [demoVC.view addConstraints:constraint_H];
    
    return demoVC;
}
@end

#endif
