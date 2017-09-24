//
//  SmileWeatherCurrentData.h
//  SmileWeather-Example
//
//  Created by ryu-ushin on 7/24/15.
//  Copyright (c) 2015 rain. All rights reserved.
//

#import "SmileWeatherOneDayData.h"

@interface SmileWeatherCurrentData : SmileWeatherOneDayData <NSCoding>

//today weather only
//"UV": "5",
@property (copy, nonatomic) NSString *UV;
//"pressure_mb": "1013",
@property (copy, nonatomic) NSString *pressureRaw;
/*!pressure unit: hPa*/
@property (readonly, nonatomic) NSString *pressure;
/*!pressure unit: inch of mercury*/
@property (readonly, nonatomic) NSString *pressure_mercuryInch;
//"pressure_trend": "+",
@property (copy, nonatomic) NSString *pressureTrend;
// "temp_f": 66.3, "temp_c": 19.1
@property (nonatomic) SmileTemperature currentTemperature;

@property (readonly, nonatomic) NSString *currentTempStri_Celsius;
@property (readonly, nonatomic) NSString *currentTempStri_Fahrenheit;
/*
 "sunrise": {
 "hour": "7",
 "minute": "01"
 },
 "sunset": {
 "hour": "16",
 "minute": "56"
 }
 */
@property (copy, nonatomic) NSString *sunRise;
@property (copy, nonatomic) NSString *sunSet;

@end
