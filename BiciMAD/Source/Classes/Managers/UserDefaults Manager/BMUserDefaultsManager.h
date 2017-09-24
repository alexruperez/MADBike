//
//  BMUserDefaultsManager.h
//  BiciMAD
//
//  Created by alexruperez on 14/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

@import Foundation;

extern NSString * const kBMUserDefaultsAuthKey;
extern NSString * const kBMUserDefaultsDNIKey;
extern NSString * const kBMUserDefaultsHistoryKey;
extern NSString * const kBMUserDefaultsFahrenheitKey;
extern NSString * const kBMUserDefaultsIdleTimerDisabledKey;
extern NSString * const kBMUserDefaultsCompassKey;
extern NSString * const kBMUserDefaultsScaleKey;
extern NSString * const kBMUserDefaultsPointsOfInterestKey;
extern NSString * const kBMUserDefaultsBuildingsKey;
extern NSString * const kBMUserDefaultsClusteringKey;
extern NSString * const kBMUserDefaultsTrafficKey;
extern NSString * const kBMUserDefaultsMapEngineKey;
extern NSString * const kBMUserDefaultsMapTypeKey;
extern NSString * const kBMUserDefaultsNavigationKey;
extern NSString * const kBMUserDefaultsGreenFilterKey;
extern NSString * const kBMUserDefaultsRedFilterKey;
extern NSString * const kBMUserDefaultsYellowFilterKey;
extern NSString * const kBMUserDefaultsGrayFilterKey;

extern NSString * const kBMUserDefaultsMapEngineAppleMapsValue;
extern NSString * const kBMUserDefaultsMapEngineGoogleMapsValue;
extern NSString * const kBMUserDefaultsMapTypeStandardValue;
extern NSString * const kBMUserDefaultsMapTypeSatelliteValue;
extern NSString * const kBMUserDefaultsMapTypeHybridValue;

@interface BMUserDefaultsManager : NSObject

+ (instancetype)managerWithUserDefaults:(NSUserDefaults *)userDefaults notificationCenter:(NSNotificationCenter *)notificationCenter;

- (BOOL)takeOff;

- (void)refreshNotificationTags:(id)sender;

- (BOOL)storeObject:(id<NSSecureCoding>)object forKey:(NSString *)key;

- (id)storedObjectForKey:(NSString *)key;

- (BOOL)storeString:(NSString *)string forKey:(NSString *)key;

- (NSString *)storedStringForKey:(NSString *)key;

- (BOOL)storeData:(NSData *)data forKey:(NSString *)key;

- (NSData *)storedDataForKey:(NSString *)key;

- (BOOL)storeNumber:(NSNumber *)number forKey:(NSString *)key;

- (NSNumber *)storedNumberForKey:(NSString *)key;

- (BOOL)storeBool:(BOOL)boolValue forKey:(NSString *)key;

- (BOOL)storedBoolForKey:(NSString *)key;

- (BOOL)removeObjectForKey:(NSString *)key;

- (BOOL)truncateUserDefaults;

@end
