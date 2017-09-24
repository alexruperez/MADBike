//
//  SmileWeatherData.m
//  SmileWeather-Example
//
//  Created by ryu-ushin on 7/13/15.
//  Copyright (c) 2015 rain. All rights reserved.
//

#import "SmileWeatherData.h"
#import "SmileClimacons.h"
#import "SmileWeatherDownLoader.h"

@interface SmileWeatherData()

@property (nonatomic, readwrite) SmileWeatherCurrentData *currentData;
@property (nonatomic, readwrite) NSArray *forecastData;
@property (nonatomic, readwrite) NSArray *hourlyData;
@property (nonatomic, readwrite) CLPlacemark *placeMark;
@property (nonatomic, readwrite) NSDate *timeStamp;
@property (nonatomic, readwrite) NSTimeZone *timeZone;
@property (nonatomic, readwrite) NSString *placeName;
@property (nonatomic, readwrite) SmileWeatherAPI weatherAPI;
@end

@implementation SmileWeatherData

static NSString * const SmileCoder_currentData = @"currentData";
static NSString * const SmileCoder_forecastData = @"forecastData";
static NSString * const SmileCoder_hourlyData = @"hourlyData";
static NSString * const SmileCoder_placemark = @"placemark";
static NSString * const SmileCoder_timeStamp = @"timeStamp";
static NSString * const SmileCoder_timeZone = @"timeZone";

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.currentData forKey:SmileCoder_currentData];
    [encoder encodeObject:self.forecastData forKey:SmileCoder_forecastData];
    [encoder encodeObject:self.hourlyData forKey:SmileCoder_hourlyData];
    [encoder encodeObject:self.placeMark forKey:SmileCoder_placemark];
    [encoder encodeObject:self.timeStamp forKey:SmileCoder_timeStamp];
    [encoder encodeObject:self.timeZone forKey:SmileCoder_timeZone];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        _currentData = [decoder decodeObjectForKey:SmileCoder_currentData];
        _forecastData = [decoder decodeObjectForKey:SmileCoder_forecastData];
        _hourlyData = [decoder decodeObjectForKey:SmileCoder_hourlyData];
        _placeMark = [decoder decodeObjectForKey:SmileCoder_placemark];
        _timeStamp = [decoder decodeObjectForKey:SmileCoder_timeStamp];
        _timeZone = [decoder decodeObjectForKey:SmileCoder_timeZone];
    }

    return self;
}

#pragma mark - Description

-(NSString *)description{
    NSString *all = [NSString stringWithFormat:@"%@\r\r%@\r\r%@\r%@\r", self.placeName, self.currentData, self.forecastData, self.hourlyData];
    return all;
}

#pragma mark - getter 

-(NSString *)placeName{
    return [SmileWeatherDownLoader placeNameForDisplay:self.placeMark];
}

#pragma mark - Setter

-(void)setTimeZone:(NSTimeZone *)timeZone{
    _timeZone = timeZone;
    [self hourlyDateFormatter].timeZone = timeZone;
    [self weekdayDateFormatter].timeZone = timeZone;
    [self ampmDateFormatter].timeZone = timeZone;
    [self twentyFourHoursDateFormatter].timeZone = timeZone;
    [self openweathermapCalendar].timeZone = self.timeZone;
}

-(instancetype)initWithJSON:(NSDictionary*)jsonData inPlacemark:(CLPlacemark *)placeMark {
    if(self = [super init]) {
        self.weatherAPI = [SmileWeatherDownLoader sharedDownloader].weatherAPI;
        self.placeMark = placeMark;
        self.timeStamp = [NSDate date];
        [self configureFromJSON:jsonData];
    }
    return self;
}

-(void)configureFromJSON:(NSDictionary*)jsonData{
    if (self.weatherAPI == API_wunderground) {
        [self configureJSON_wunderground:jsonData];
    } else if (self.weatherAPI == API_openweathermap){
#if TARGET_OS_IOS
        //new api in iOS9
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0){
            self.timeZone = self.placeMark.timeZone;
        }
#endif
        [self configureJSON_openweathermap:jsonData];
    }
}

-(NSArray*)createOneDayDataForForecast:(NSArray*)forecastData{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:forecastData.count];
    
    [forecastData enumerateObjectsUsingBlock:^(NSDictionary *forecastday, NSUInteger idx, BOOL *stop) {
        SmileWeatherForecastDayData *forecast = [[SmileWeatherForecastDayData alloc] init];

        NSDateFormatter *weekdayFormatter = [self weekdayDateFormatter];
        
        //forecast weekday
        forecast.dayOfWeek = [weekdayFormatter stringFromDate:[self.timeStamp dateByAddingTimeInterval:60 * 60 * 24 * idx]];
        
        //condition
        NSString *condition = [self createConditionStringFromObject:[forecastday valueForKey:@"conditions"]];
        NSString *icon = [forecastday valueForKey:@"icon"];
        
        forecast.condition = condition;
        forecast.icon = [self iconForCondition:icon];
        
        //forecast temperature
        forecast.highTemperature = [self createSmileTemperatureFromObject:[forecastday valueForKey:@"high"] forKey_F:@"fahrenheit" forKey_C:@"celsius"];
        forecast.lowTemperature = [self createSmileTemperatureFromObject:[forecastday valueForKey:@"low"] forKey_F:@"fahrenheit" forKey_C:@"celsius"];
        
        //precipitation
        forecast.precipitationRaw = [self createPopStringFromObject:[forecastday valueForKey:@"pop"]];
        
        //avehumidity
        forecast.humidity = [self createHumidityStringFromObject:[forecastday valueForKey:@"avehumidity"]];;
        
        //wind speed
        forecast.windSpeedRaw = [self createWindSpeedRawFromObject:[[forecastday valueForKey:@"avewind"] valueForKey:@"kph"]];
        forecast.windDirection = [[forecastday valueForKey:@"avewind"] valueForKey:@"dir"];
        
        [results addObject:forecast];
    }];
    
    return [NSArray arrayWithArray:results];
}

-(NSArray*)createOneDayDataForHourly:(NSArray*)hourlyData{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:hourlyData.count];
    
    NSDateFormatter *hourlyDateFormatter = [self hourlyDateFormatter];
    [hourlyData enumerateObjectsUsingBlock:^(NSDictionary *hourlyData, NSUInteger idx, BOOL *stop) {
        
        if (idx > 23) {
            *stop = YES;
        }
        
        SmileWeatherHourlyData *forecast = [[SmileWeatherHourlyData alloc] init];
        
        //time
        NSDictionary *timeDic  = [hourlyData valueForKey:@"FCTTIME"];

        NSString *dateStri = [NSString stringWithFormat:@"%@/%@/%@ %@:00:00",[timeDic valueForKey:@"year"], [timeDic valueForKey:@"mon_padded"], [timeDic valueForKey:@"mday_padded"], [timeDic valueForKey:@"hour_padded"]];
        
        forecast.date = [hourlyDateFormatter dateFromString:dateStri];
//        NSLog(@"%@==============%@", dateStri, forecast.date);
        //condition
        NSString *condition = [hourlyData valueForKey:@"conditions"];
        NSString *icon = [hourlyData valueForKey:@"icon"];
        
        forecast.condition = condition;
        forecast.icon = [self iconForCondition:icon];
        
        //forecast temperature
        forecast.currentTemperature = [self createSmileTemperatureFromObject:[hourlyData valueForKey:@"temp"] forKey_F:@"english" forKey_C:@"metric"];
        
        //precipitation
        forecast.precipitationRaw = [self createPopStringFromObject:[hourlyData valueForKey:@"pop"]];
        
        //avehumidity
        forecast.humidity = [NSString stringWithFormat:@"%@%%", [hourlyData valueForKey:@"humidity"]];
        
        //wind
        forecast.windSpeedRaw = [self createWindSpeedRawFromObject:[[hourlyData valueForKey:@"wspd"] valueForKey:@"metric"]];
        forecast.windDirection = [[hourlyData valueForKey:@"wdir"] valueForKey:@"dir"];
        
        [results addObject:forecast];
    }];
    
    NSDateFormatter *ampmDateFormatter = [self ampmDateFormatter];
    for (SmileWeatherHourlyData *data in results) {
        data.localizedTime = [ampmDateFormatter stringFromDate:data.date];
    }
    
    return [NSArray arrayWithArray:results];
}

-(void)configureJSON_wunderground:(NSDictionary*)jsonData{
    NSDictionary *currentObservation = [jsonData objectForKey:@"current_observation"];
    NSArray *hourlyForecastDays = [jsonData objectForKey:@"hourly_forecast"];
    
    NSDictionary *forecast = [jsonData objectForKey:@"forecast"];
    NSDictionary *simpleforecast = [forecast objectForKey:@"simpleforecast"];
    NSArray *forecastday = [simpleforecast objectForKey:@"forecastday"];
    
    
    NSDictionary *forecastday0 = [forecastday objectAtIndex:0];
    
    //weather one day data
    self.currentData = [[SmileWeatherCurrentData alloc] init];
    
    //time zone
    NSString *tz_short = [currentObservation valueForKey:@"local_tz_short"];
    NSDateFormatter *weekdayFormatter = [self weekdayDateFormatter];
    self.timeZone = [NSTimeZone timeZoneWithAbbreviation:tz_short];
    
    //today weekday
    self.currentData.dayOfWeek = [weekdayFormatter stringFromDate:self.timeStamp];
    

    //condition
    NSString *currentCondition = [self createConditionStringFromObject: [currentObservation valueForKey:@"weather"]];
    NSString *currentIcon = [currentObservation valueForKey:@"icon"];
    
    self.currentData.condition = currentCondition;
    self.currentData.icon = [self iconForCondition:currentIcon];
    
    
    //temperature
    //today temperature
    self.currentData.currentTemperature = [self createSmileTemperatureFromObject:currentObservation forKey_F:@"temp_f" forKey_C:@"temp_c"];
    
    
    //precipitation
    self.currentData.precipitationRaw = [self createPopStringFromObject:[forecastday0 valueForKey:@"pop"]];
    
    //avehumidity
    self.currentData.humidity = [self createHumidityStringFromObject:[currentObservation valueForKey:@"relative_humidity"]];
    
    //wind speed
    self.currentData.windSpeedRaw = [self createWindSpeedRawFromObject:[currentObservation valueForKey:@"wind_kph"]];
    self.currentData.windDirection = [currentObservation valueForKey:@"wind_dir"];
    
    //today only property
    self.currentData.pressureTrend = [currentObservation valueForKey:@"pressure_trend"];
    
    self.currentData.UV = [self createUVStringFromObject:[currentObservation valueForKey:@"UV"]];
    
    self.currentData.pressureRaw = [self createPressureStringFromObject:[currentObservation valueForKey:@"pressure_mb"]];
    self.currentData.sunRise = [self createSunStringFromObject:[[jsonData valueForKey:@"moon_phase"]  valueForKey:@"sunrise"]];
    self.currentData.sunSet = [self createSunStringFromObject:[[jsonData valueForKey:@"moon_phase"]  valueForKey:@"sunset"]];
    
    //hourly data
    self.hourlyData = [self createOneDayDataForHourly:hourlyForecastDays];
    
    //forecast data
    self.forecastData = [self createOneDayDataForForecast:forecastday];
}

-(void)configureJSON_openweathermap:(NSDictionary*)jsonData{
    
    //current weather data
    self.currentData = [[SmileWeatherCurrentData alloc] init];
    NSDictionary *mainDataDic = [jsonData objectForKey:@"main"];
    NSDictionary *windDic = [jsonData objectForKey:@"wind"];
    
    NSDateFormatter *weekdayFormatter = [self weekdayDateFormatter];
    
    //today weekday
    self.currentData.dayOfWeek = [weekdayFormatter stringFromDate:self.timeStamp];
    
    //condition
    NSArray *currentObservation = [jsonData objectForKey:@"weather"];
    NSDictionary *currentDic = [currentObservation lastObject];
    
    self.currentData.condition = [self createConditionStringFromObject:[currentDic valueForKey:@"description"]];
    
    //icon
    self.currentData.icon = [self iconForCondition:[currentDic valueForKey:@"main"]];
    
    //temperature
    //today temperature
    self.currentData.currentTemperature = [self createTemperatureFromObject_openweathermap:[mainDataDic valueForKey:@"temp"]];
    
    
    //avehumidity
    self.currentData.humidity = [self createHumidityStringFromObject:[mainDataDic valueForKey:@"humidity"]];
    
    //wind speed
    self.currentData.windSpeedRaw = [self createWindSpeedRawFromObject:[windDic valueForKey:@"speed"]];
    self.currentData.windDirection = [self getOpenWeatherMapWindDirection:windDic];
    
    //today only property
    self.currentData.pressureRaw = [self createPressureStringFromObject:[mainDataDic valueForKey:@"pressure"]];
    
    //precipitation
    self.currentData.precipitationRaw = [self createNowAmountOfRainFromObject_openweathermap:[jsonData objectForKey:@"rain"]];
    
    NSDictionary *sysDic = [jsonData objectForKey:@"sys"];
    self.currentData.sunRise = [self createSunStringFromObject_openweathermap:[sysDic valueForKey:@"sunrise"]];
    self.currentData.sunSet = [self createSunStringFromObject_openweathermap:[sysDic valueForKey:@"sunset"]];
    self.currentData.UV = [self createUVStringFromObject:nil];
    
    
    [self configureForecastDaysAndHourly_openweathermap:(NSArray*)[jsonData objectForKey:@"list"]];
}

-(NSString*)getOpenWeatherMapWindDirection:(NSDictionary*)windDic {
    NSString *result = @"";
    id data = [windDic valueForKey:@"deg"];
    if ([data isKindOfClass:[NSNumber class]]) {
        NSInteger degree = [data integerValue];
        result = [NSString stringWithFormat:@"%ldº", (long)degree];
    }
    return result;
}

#pragma mark - convertor for openweathermap
-(void)configureForecastDaysAndHourly_openweathermap:(NSArray*)object{
    __block NSMutableArray *hourlyData = [NSMutableArray new];
    __block NSMutableArray *forecastData = [NSMutableArray new];
    __block NSInteger dayFlag;
    
    [object enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSDateFormatter *dateFormatter = [self openweathermapDateFormatter];
        NSString *dateStri = [obj objectForKey:@"dt_txt"];
        NSDate *date = [dateFormatter dateFromString:dateStri];
        
        //forecast data
        NSDateComponents *components = [[self openweathermapCalendar] components:NSCalendarUnitDay fromDate: date];
        
        if (dayFlag == 0 || dayFlag != components.day) {
            //this is a day
            SmileWeatherForecastDayData *forecast = [[SmileWeatherForecastDayData alloc] init];
            NSDateFormatter *weekdayFormatter = [self weekdayDateFormatter];
            forecast.dayOfWeek = [weekdayFormatter stringFromDate:date];
            
            NSDictionary *mainDataDic = [obj objectForKey:@"main"];
            NSDictionary *windDic = [obj objectForKey:@"wind"];
            
            //condition
            NSArray *currentObservation = [obj objectForKey:@"weather"];
            NSDictionary *currentDic = [currentObservation lastObject];
            
            forecast.condition = [self createConditionStringFromObject:[currentDic valueForKey:@"description"]];
            
            //icon
            forecast.icon = [self iconForCondition:[currentDic valueForKey:@"main"]];
            
            //temperature
            forecast.highTemperature = [self createTemperatureFromObject_openweathermap:[mainDataDic valueForKey:@"temp_max"]];
            forecast.lowTemperature = [self createTemperatureFromObject_openweathermap:[mainDataDic valueForKey:@"temp_min"]];
            
            //avehumidity
            forecast.humidity = [self createHumidityStringFromObject:[mainDataDic valueForKey:@"humidity"]];
            
            //wind speed
            forecast.windSpeedRaw = [self createWindSpeedRawFromObject:[windDic valueForKey:@"speed"]];
            forecast.windDirection = [self getOpenWeatherMapWindDirection:windDic];
            
            //precipitation
            forecast.precipitationRaw = [self createForecastAmountOfRainFromObject_openweathermap:[obj objectForKey:@"rain"]];
            
            [forecastData addObject:forecast];
            dayFlag = components.day;
        }
        if (dayFlag == components.day) {
            SmileWeatherForecastDayData *sameDayData = [forecastData lastObject];
            NSDictionary *mainDataDic = [obj objectForKey:@"main"];
            
            SmileTemperature highTemperature = [self createTemperatureFromObject_openweathermap:[mainDataDic valueForKey:@"temp_max"]];
            if (highTemperature.initialized && highTemperature.celsius > sameDayData.highTemperature.celsius) {
                sameDayData.highTemperature = highTemperature;
            }
            
            SmileTemperature lowTemperature = [self createTemperatureFromObject_openweathermap:[mainDataDic valueForKey:@"temp_min"]];
            if (lowTemperature.initialized && lowTemperature.celsius < sameDayData.lowTemperature.celsius) {
                sameDayData.lowTemperature = lowTemperature;
            }
        }
        
        //hourly data
        if (idx < 13) {
            SmileWeatherHourlyData *forecast = [[SmileWeatherHourlyData alloc] init];
            forecast.date = date;
            
            NSDictionary *mainDataDic = [obj objectForKey:@"main"];
            NSDictionary *windDic = [obj objectForKey:@"wind"];
            
            //condition
            NSArray *currentObservation = [obj objectForKey:@"weather"];
            NSDictionary *currentDic = [currentObservation lastObject];
            
            forecast.condition = [self createConditionStringFromObject:[currentDic valueForKey:@"description"]];
            
            //icon
            forecast.icon = [self iconForCondition:[currentDic valueForKey:@"main"]];
            
            //temperature
            forecast.currentTemperature = [self createTemperatureFromObject_openweathermap:[mainDataDic valueForKey:@"temp"]];
            //avehumidity
            forecast.humidity = [self createHumidityStringFromObject:[mainDataDic valueForKey:@"humidity"]];
            
            //wind speed
            forecast.windSpeedRaw = [self createWindSpeedRawFromObject:[windDic valueForKey:@"speed"]];
            forecast.windDirection = [self getOpenWeatherMapWindDirection:windDic];
            
            //precipitation
            forecast.precipitationRaw = [self createForecastAmountOfRainFromObject_openweathermap:[obj objectForKey:@"rain"]];
            
            [hourlyData addObject:forecast];
        }
        
    }];
    
    NSDateFormatter *ampmDateFormatter = [self ampmDateFormatter];
    for (SmileWeatherHourlyData *data in hourlyData) {
        data.localizedTime = [ampmDateFormatter stringFromDate:data.date];
    }
    
    self.hourlyData = [hourlyData mutableCopy];
    
    //get just 5 days forecast
    if (forecastData.count > 5) {
        [forecastData removeLastObject];
    }
    self.forecastData = [forecastData mutableCopy];
}

-(NSString*)createForecastAmountOfRainFromObject_openweathermap:(id)object {
    return [self createAmountOfRainFromObject_openweathermap:object key:@"3h"];
}

-(NSString*)createNowAmountOfRainFromObject_openweathermap:(id)object {
    return [self createAmountOfRainFromObject_openweathermap:object key:@"1h"];
}

-(NSString*)createAmountOfRainFromObject_openweathermap:(id)object key:(NSString*)key{
    NSString *result = @"0 mm";;
    if (object){
        NSDictionary *dic = (NSDictionary*)object;
        id value = [dic objectForKey:key];
        if ([value isKindOfClass:[NSNumber class]]) {
            result = [NSString stringWithFormat:@"%.2f mm", [(NSNumber*)value floatValue]];
        }
    }
    return result;
}

-(NSString*)createSunStringFromObject_openweathermap:(id)object{
    NSString *result;
    
    //if iOS9, it will get right result by using placemark's timezone, prior iOS9 will use current timezone. 
    if ([object isKindOfClass:[NSNumber class]]) {
        NSNumber *value = (NSNumber*)object;
        NSDate *sunDate = [SmileWeatherData sunSecToDate:value];
        NSDateFormatter *ampmDateFormatter = [self twentyFourHoursDateFormatter];
        result = [NSString stringWithFormat:@"%@", [ampmDateFormatter stringFromDate:sunDate]];
    } else {
        result = @"--:--";
    }
    
    return result;
}


-(SmileTemperature)createTemperatureFromObject_openweathermap:(id)object{
    SmileTemperature result = SmileTemperatureMake(0, 0, false);
    if ([object isKindOfClass:[NSNumber class]]) {
        NSNumber *tempNum = (NSNumber*)object;
        result = SmileTemperatureMake([SmileWeatherData tempToFahrenheit:tempNum], [SmileWeatherData tempToCelcius:tempNum], YES);
    }
    return result;
}

+ (NSDate *) sunSecToDate:(NSNumber *) num {
    return [NSDate dateWithTimeIntervalSince1970:num.intValue];
}

+ (float) tempToCelcius:(NSNumber *) tempKelvin
{
    return (tempKelvin.floatValue - 273.15);
}

+ (float) tempToFahrenheit:(NSNumber *) tempKelvin
{
    return ((tempKelvin.floatValue * 9/5) - 459.67);
}

#pragma mark - convertor for wunderground

-(NSString*)createPopStringFromObject:(id)object{
    NSString *result;
    if (object) {
        NSInteger degree = [object integerValue];
        result = [NSString stringWithFormat:@"%ld", (long)degree];
    }
    return result;
}

-(NSString*)createSunStringFromObject:(NSDictionary*)object{
    NSString *result;
    
    id hour = object[@"hour"];
    id min = object[@"minute"];
    
    if ([hour isKindOfClass:[NSString class]] && [min isKindOfClass:[NSString class]]) {
        NSString *hourStri = (NSString*)hour;
        NSString *minStri = (NSString*)min;
        if (hourStri.length > 0 && minStri.length > 0) {
            result = [NSString stringWithFormat:@"%@:%@", hourStri, minStri];
        } else {
            result = @"--:--";
        }
    } else {
        result = @"--:--";
    }
    
    return result;
}

-(NSString*)createConditionStringFromObject:(id)object {
    NSString *result;
    if ([object isKindOfClass:[NSString class]]) {
        NSString *value = (NSString*)object;
        if (value.length > 0) {
            result = [NSString stringWithFormat:@"%@", value];
        } else {
            result = @"--";
        }
    } else {
        result = @"--";
    }
    
    return result;
}

-(NSString*)createHumidityStringFromObject:(id)object {
    
    NSString *result;
    
    if (self.weatherAPI == API_wunderground) {
        if ([object isKindOfClass:[NSString class]]) {
            NSString *value = (NSString*)object;
            if (value.length > 0) {
                result = [NSString stringWithFormat:@"%@", value];
                
                if ([result isEqualToString:@"%"]) {
                    result = @"--%";
                }
                
            } else {
                result = @"--%";
            }
        } else {
            result = @"--%";
        }
    } else if (self.weatherAPI == API_openweathermap){
        if ([object isKindOfClass:[NSNumber class]]) {
            NSNumber *value = (NSNumber*)object;
            if (value) {
                result = [NSString stringWithFormat:@"%0.f%%", value.floatValue];
            } else {
                result = @"--%";
            }
        } else {
            result = @"--%";
        }
    }
    
    
    return result;
}

-(NSString*)createUVStringFromObject:(id)object {
    NSString *result;
    
    if ([object isKindOfClass:[NSString class]]) {
        NSString *value = (NSString*)object;
        if (value.length > 0) {
            result = [NSString stringWithFormat:@"%@", value];
        } else {
            result = @"--";
        }
    } else {
        result = @"--";
    }
    
    return result;
}

-(NSString*)createPressureStringFromObject:(id)object {
    NSString *result;
    if ([object isKindOfClass:[NSString class]]) {
        NSString *value = (NSString*)object;
        if (value.length > 0) {
            result = [NSString stringWithFormat:@"%@", value];
        } else {
            result = @"";
        }
    } else if ([object isKindOfClass:[NSNumber class]]){
        NSNumber *value = (NSNumber*)object;
        result = [NSString stringWithFormat:@"%.0f", value.floatValue];
    }
    else {
        result = @"";
    }
    return result;
}

-(NSString*)createWindSpeedRawFromObject:(id)object {
    NSString *result = @"";
    if (self.weatherAPI == API_openweathermap) {
        if ([object isKindOfClass:[NSNumber class]] || [object isKindOfClass:[NSString class]]) {
            NSNumber *value = (NSNumber*)object;
            result = [NSString stringWithFormat:@"%.0f", value.floatValue];
        }
    } else if (self.weatherAPI == API_wunderground){
        if ([object isKindOfClass:[NSNumber class]] || [object isKindOfClass:[NSString class]]) {
            float value = [object floatValue]* 1000 / (60 * 60);
            result = [NSString stringWithFormat:@"%.0f", value];
        }
    }
    return result;
}

-(SmileTemperature)createSmileTemperatureFromObject:(id)object forKey_F:(NSString*)key_f forKey_C:(NSString*)key_c {
    
    SmileTemperature result;
    
    id object_f = [object valueForKey:key_f];
    id object_c = [object valueForKey:key_c];
    
    if ([object_f isKindOfClass:[NSNumber class]] && [object_c isKindOfClass:[NSNumber class]]) {
        float value_f = [object_f doubleValue];
        float value_c = [object_c doubleValue];
        result = SmileTemperatureMake(value_f, value_c, YES);
    } else if([object_f isKindOfClass:[NSString class]] && [object_c isKindOfClass:[NSString class]]){
        float value_f = [object_f doubleValue];
        float value_c = [object_c doubleValue];
        result = SmileTemperatureMake(value_f, value_c, YES);

    }
    else {
        result = SmileTemperatureMake(0, 0, NO);
    }
    
    return result;
}

#pragma mark - common tools

- (NSString *)iconForCondition:(NSString *)condition
{
    NSString *iconName = [NSString stringWithFormat:@"%c", ClimaconSun];
    NSString *lowercaseCondition = [condition lowercaseString];
    
    if([lowercaseCondition contains:@"clear"] || [lowercaseCondition contains:@"sunny"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconSun];
    }
    
    else if([lowercaseCondition contains:@"cloudy"] || [lowercaseCondition contains:@"clouds"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconCloud];
    }

    else if ([lowercaseCondition contains:@"rain"]){
        iconName = [NSString stringWithFormat:@"%c", ClimaconRain];
    }
    
    else if ([lowercaseCondition contains:@"storms"]){
        iconName = [NSString stringWithFormat:@"%c", ClimaconDownpour];
    }
    
    else if([lowercaseCondition contains:@"fog"] || [lowercaseCondition contains:@"hazy"] ||
            [lowercaseCondition contains:@"haze"]||[lowercaseCondition contains:@"mist"]){
        iconName = [NSString stringWithFormat:@"%c", ClimaconHaze];
    }
    
    else if ([lowercaseCondition contains:@"sleet"]){
        iconName = [NSString stringWithFormat:@"%c", ClimaconSleet];
    }
    
    else if ([lowercaseCondition contains:@"flurries"]){
        iconName = [NSString stringWithFormat:@"%c", ClimaconFlurries];
    }
    
    else if ([lowercaseCondition contains:@"snow"]){
        iconName = [NSString stringWithFormat:@"%c", ClimaconSnow];
    }
    
    return iconName;
}

-(NSDateFormatter*)ampmDateFormatter{
    static dispatch_once_t onceToken;
    static NSDateFormatter *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NSDateFormatter alloc] init];
        [_sharedInstance setTimeStyle:NSDateFormatterShortStyle];
    });
    return _sharedInstance;
}

-(NSDateFormatter*)hourlyDateFormatter{
    static dispatch_once_t onceToken;
    static NSDateFormatter *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NSDateFormatter alloc] init];
        [_sharedInstance setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        _sharedInstance.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    });
    return _sharedInstance;
}

-(NSDateFormatter*)weekdayDateFormatter {
    static dispatch_once_t onceToken;
    static NSDateFormatter *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NSDateFormatter alloc] init];
        [_sharedInstance setDateFormat:@"EEE"];
    });
    return _sharedInstance;
}

-(NSDateFormatter*)openweathermapDateFormatter {
    static dispatch_once_t onceToken;
    static NSDateFormatter *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NSDateFormatter alloc] init];
        _sharedInstance.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [_sharedInstance setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _sharedInstance.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    });
    return _sharedInstance;
}

-(NSCalendar*)openweathermapCalendar {
    static dispatch_once_t onceToken;
    static NSCalendar *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    });
    return _sharedInstance;
}

-(NSDateFormatter*)twentyFourHoursDateFormatter{
    static dispatch_once_t onceToken;
    static NSDateFormatter *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NSDateFormatter alloc] init];
        [_sharedInstance setTimeStyle:NSDateFormatterShortStyle];
        _sharedInstance.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    });
    return _sharedInstance;
}

@end
