//
//  SmileWeatherData.h
//  SmileWeather-Example
//
//  Created by ryu-ushin on 7/13/15.
//  Copyright (c) 2015 rain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SmileWeatherCurrentData.h"
#import "SmileWeatherForecastDayData.h"
#import "SmileWeatherHourlyData.h"

#define SmileWeather_DispatchMainThread(block, ...) if(block) dispatch_async(dispatch_get_main_queue(), ^{ block(__VA_ARGS__); })

@interface SmileWeatherData : NSObject <NSCoding>

/*!The weather data for current weather data.*/
@property (nonatomic, readonly) SmileWeatherCurrentData *currentData;
/*!The array of weather data for four days forecast.*/
@property (nonatomic, readonly) NSArray<SmileWeatherForecastDayData*> *forecastData;
/*!The array of weather data for hourly forecast.*/
@property (nonatomic, readonly) NSArray<SmileWeatherHourlyData*> *hourlyData;
@property (nonatomic, readonly) CLPlacemark *placeMark;
@property (nonatomic, readonly) NSDate *timeStamp;
@property (nonatomic, readonly) NSTimeZone *timeZone;
@property (nonatomic, readonly) NSString *placeName;
-(instancetype)initWithJSON:(NSDictionary*)jsonData inPlacemark:(CLPlacemark*)placeMark;

@end
