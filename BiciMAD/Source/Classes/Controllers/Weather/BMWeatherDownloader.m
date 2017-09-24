//
//  BMWeatherDownloader.m
//  BiciMAD
//
//  Created by alexruperez on 13/12/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMWeatherDownloader.h"

#define INFO_DIC @"SmileWeather"
#define API_NOW  @"API_NOW"
#define API_KEY_wunderground @"API_KEY_wunderground"
#define API_KEY_openweathermap @"API_KEY_openweathermap"

@interface SmileWeatherDownLoader ()

@property (nonatomic, readwrite) SmileWeatherAPI weatherAPI;

+ (NSDictionary*)smileWeatherInfoDic;

- (instancetype)initWithWundergroundAPIKey:(NSString*)apikey;
- (instancetype)initWithOpenweathermapAPIKey:(NSString*)apikey;

@end

@implementation BMWeatherDownloader

+ (SmileWeatherDownLoader*)sharedDownloader
{
    static BMWeatherDownloader *sharedDownloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *smileInfo =  BMWeatherDownloader.smileWeatherInfoDic;
        sharedDownloader = [[BMWeatherDownloader alloc] initFromInfoKey:smileInfo];
    });
    return sharedDownloader;
}

- (instancetype)initFromInfoKey:(NSDictionary*)smileInfo
{
    BMWeatherDownloader *sharedDownloader;
    
    if ([smileInfo[API_NOW] isKindOfClass:[NSNumber class]])
    {
        NSNumber *api_now = smileInfo[API_NOW];
        sharedDownloader = [[BMWeatherDownloader alloc]initWithAPIType:(SmileWeatherAPI)[api_now intValue]];
    }
    else
    {
        NSString *apikey_wunderground = smileInfo[API_KEY_wunderground];
        NSString *apikey_openweathermap = smileInfo[API_KEY_openweathermap];
        if (apikey_wunderground && !apikey_openweathermap)
        {
            sharedDownloader = [[BMWeatherDownloader alloc] initWithWundergroundAPIKey:apikey_wunderground];
        }
        else if (!apikey_wunderground && apikey_openweathermap)
        {
            sharedDownloader = [[BMWeatherDownloader alloc] initWithOpenweathermapAPIKey:apikey_openweathermap];
        }
        else
        {
            NSAssert( apikey_wunderground != nil && apikey_openweathermap !=nil, @"No Wunderground or Openweathermap key to your Info.plist");
            
            NSAssert( apikey_wunderground == nil && apikey_openweathermap ==nil, @"Both of Wunderground and Openweathermap key in your Info.plist, please add API_NOW key to select which one is used.");
        }
    }
    
    return sharedDownloader;
}

- (instancetype)initWithAPIType:(SmileWeatherAPI)type
{
    self = super.init;
    
    if (self)
    {
        self.weatherAPI = type;
        NSDictionary *smileInfo =  BMWeatherDownloader.smileWeatherInfoDic;
        NSString *apikey;
        if (self.weatherAPI == API_wunderground)
        {
            apikey = smileInfo[API_KEY_wunderground];
            NSAssert(apikey != nil, @"Please add Wunderground key to your Info.plist");
            self = [[BMWeatherDownloader alloc] initWithWundergroundAPIKey:apikey];
        }
        else if (self.weatherAPI == API_openweathermap)
        {
            apikey = smileInfo[API_KEY_openweathermap];
            NSAssert(apikey != nil, @"Please add openweathermap key to your Info.plist");
            self = [[BMWeatherDownloader alloc] initWithOpenweathermapAPIKey:apikey];
        }
    }
    
    return self;
}

- (NSString *)preferedLanguage
{
    return [NSLocale.autoupdatingCurrentLocale objectForKey:NSLocaleLanguageCode];
}

@end
