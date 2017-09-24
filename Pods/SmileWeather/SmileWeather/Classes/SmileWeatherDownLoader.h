//
//  SmileWeatherDownLoader.h
//  SmileWeather-Example
//
//  Created by ryu-ushin on 7/13/15.
//  Copyright (c) 2015 rain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SmileWeatherData.h"

typedef void(^SmileWeatherDataDownloadCompletion)(SmileWeatherData * _Nullable data,  NSError *_Nullable error);
typedef void(^SmileWeatherPlacemarksCompletion)(NSArray<CLPlacemark*> *_Nullable placeMarks, NSError *_Nullable error);
typedef void(^SmileWeatherRawDicCompletion)(NSDictionary *_Nullable rawDic, NSError *_Nullable error);
typedef void(^SmileWeatherRawDataCompletion)(NSData *_Nullable rawData, NSError *_Nullable error);


typedef NS_ENUM(int, SmileWeatherAPI) {
    /*!*/
    API_wunderground,
    /*!*/
    API_openweathermap,
};


@interface SmileWeatherDownLoader : NSObject

/*!The weather api used for your project, please set it in your info.plist in advance.*/
@property (nonatomic, readonly) SmileWeatherAPI weatherAPI;

/*!Dynamically change api.*/
-(void)changeAPI:(SmileWeatherAPI)newAPI;

+(nonnull SmileWeatherDownLoader*)sharedDownloader;

//Raw data
-(void)getWeatherRawDataFromURL:(nonnull NSURL*)url completion:(nonnull SmileWeatherRawDataCompletion)completion NS_SWIFT_NAME(getWeatherRawData(from:completion:));

-(void)getWeatherRawDicFromURL:(nonnull NSURL*)url completion:(nonnull SmileWeatherRawDicCompletion)completion NS_SWIFT_NAME(getWeatherRawDic(from:completion:));

//weather data
/*!
 @brief Get weather data from CLPlacemark.
 @discussion This method submits the specified CLPlacemark data to the weather server asynchronously and returns well formed data 'SmileWeatherData' for using easily. Your completion handler block will be executed on the main thread.
 @param placeMark The CLPlacemark is submited for weather data.
 @param completion A block object containing the code to execute at the end of the request. This code is called whether the request is successful or unsuccessful.
 @see -getWeatherDataFromLocation:completion:
 */
-(void)getWeatherDataFromPlacemark:(nonnull CLPlacemark*)placeMark completion:(nonnull SmileWeatherDataDownloadCompletion)completion NS_SWIFT_NAME(getWeatherData(from:completion:));

/*!
 @brief Get weather data from CLLocation.
 @discussion This method submits the specified CLLocation data to the weather server asynchronously and returns well formed data 'SmileWeatherData' for using easily. Your completion handler block will be executed on the main thread.
 @param location The CLPlacemark is submited for weather data.
 @param completion A block object containing the code to execute at the end of the request. This code is called whether the request is successful or unsuccessful.
 @see -getWeatherDataFromPlacemark:completion:
 */
-(void)getWeatherDataFromLocation:(nonnull CLLocation*)location completion:(nonnull SmileWeatherDataDownloadCompletion)completion NS_SWIFT_NAME(getWeatherData(from:completion:));

//Placemark Lists
/*!
 @brief Get array of CLPlacemark from the input string in the normal scene.
 @discussion This method submits the specified String to the weather server asynchronously and returns array of CLPlacemark. Your completion handler block will be executed on the main thread.
 @param string The string is submited for search.
 @param completion A block object containing the code to execute at the end of the request. This code is called whether the request is successful or unsuccessful.
 @see -getPlacemarksForSearchDisplayFromString:completion:
 */
-(void)getPlacemarksFromString:(nonnull NSString*)string completion:(nonnull SmileWeatherPlacemarksCompletion)completion NS_SWIFT_NAME(getPlacemarks(from:completion:));

/*!
 @brief Get array of CLPlacemark from the input string for display in the scene where the results is displayed in the search bar. By use this method, the returned array will contains the corresponding results as much as possible.
 @discussion This method submits the specified string to the weather server asynchronously and returns array of CLPlacemark. Your completion handler block will be executed on the main thread.
 @param string The string is submited for search.
 @param completion A block object containing the code to execute at the end of the request. This code is called whether the request is successful or unsuccessful.
 @see -getPlacemarksFromString:completion:
 */
-(void)getPlacemarksForSearchDisplayFromString:(nonnull NSString*)string completion:(nonnull SmileWeatherPlacemarksCompletion)completion NS_SWIFT_NAME(getPlacemarksForSearchDisplay(from:completion:));

//Utility
/*!Optimized placename for display in the search bar scene.*/
+(nonnull NSString*)placeNameForSearchDisplay:(nonnull CLPlacemark*)placemark;
/*!Optimized placename for display in the normal scene.*/
+(nonnull NSString*)placeNameForDisplay:(nonnull CLPlacemark*)placemark;

@end
