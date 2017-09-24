//
//  BMUserDefaultsManager.m
//  BiciMAD
//
//  Created by alexruperez on 14/10/15.
//  Copyright © 2015 alexruperez. All rights reserved.
//

#import "BMUserDefaultsManager.h"
#import "BMAnalyticsManager.h"
#import "MADBike-Swift.h"

@import InAppSettingsKit;
@import FXNotifications;
@import Zephyr;

static NSString * const kBMUserDefaultsRootFile = @"Root";
static NSString * const kBMUserDefaultsNotificationsFile = @"Notifications";
NSString * const kBMUserDefaultsAuthKey = @"id_auth";
NSString * const kBMUserDefaultsDNIKey = @"dni";
NSString * const kBMUserDefaultsHistoryKey = @"searchHistory";
NSString * const kBMUserDefaultsFahrenheitKey = @"fahrenheit";
NSString * const kBMUserDefaultsIdleTimerDisabledKey = @"idleTimerDisabled";
NSString * const kBMUserDefaultsCompassKey = @"showsCompass";
NSString * const kBMUserDefaultsScaleKey = @"showsScale";
NSString * const kBMUserDefaultsPointsOfInterestKey = @"showsPointsOfInterest";
NSString * const kBMUserDefaultsBuildingsKey = @"showsBuildings";
NSString * const kBMUserDefaultsClusteringKey = @"clustering";
NSString * const kBMUserDefaultsTrafficKey = @"showsTraffic";
NSString * const kBMUserDefaultsMapEngineKey = @"mapEngine";
NSString * const kBMUserDefaultsMapTypeKey = @"mapType";
NSString * const kBMUserDefaultsNavigationKey = @"navigation";

NSString * const kBMUserDefaultsGreenFilterKey = @"greenFilter";
NSString * const kBMUserDefaultsRedFilterKey = @"redFilter";
NSString * const kBMUserDefaultsYellowFilterKey = @"yellowFilter";
NSString * const kBMUserDefaultsGrayFilterKey = @"grayFilter";

NSString * const kBMUserDefaultsMapEngineAppleMapsValue = @"appleMaps";
NSString * const kBMUserDefaultsMapEngineGoogleMapsValue = @"googleMaps";
NSString * const kBMUserDefaultsMapTypeStandardValue = @"standard";
NSString * const kBMUserDefaultsMapTypeSatelliteValue = @"satellite";
NSString * const kBMUserDefaultsMapTypeHybridValue = @"hybrid";

@interface BMUserDefaultsManager ()

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) NSNotificationCenter *notificationCenter;

@end

@implementation BMUserDefaultsManager

+ (instancetype)managerWithUserDefaults:(NSUserDefaults *)userDefaults notificationCenter:(NSNotificationCenter *)notificationCenter
{
    return [[self alloc] initWithUserDefaults:userDefaults notificationCenter:notificationCenter];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults notificationCenter:(NSNotificationCenter *)notificationCenter
{
    self = super.init;
    
    if (self)
    {
        _userDefaults = userDefaults;
        _notificationCenter = notificationCenter;
    }
    
    return self;
}

- (NSBundle *)bundle
{
    if (!_bundle)
    {
        _bundle = NSBundle.mainBundle;
    }

    return _bundle;
}

- (BOOL)takeOff
{
    NSMutableDictionary *defaultsToRegister = NSMutableDictionary.new;

    [defaultsToRegister addEntriesFromDictionary:[self defaultsFromFile:kBMUserDefaultsRootFile]];
    [defaultsToRegister addEntriesFromDictionary:[self defaultsFromFile:kBMUserDefaultsNotificationsFile]];

    defaultsToRegister[kBMUserDefaultsGreenFilterKey] = @(YES);
    defaultsToRegister[kBMUserDefaultsRedFilterKey] = @(YES);
    defaultsToRegister[kBMUserDefaultsYellowFilterKey] = @(YES);
    defaultsToRegister[kBMUserDefaultsGrayFilterKey] = @(YES);

    [self.userDefaults registerDefaults:defaultsToRegister.copy];

    [Zephyr addKeysToBeMonitoredWithKeys:defaultsToRegister.allKeys];

    @weakify(self)
    [self.notificationCenter addObserver:self forName:kIASKAppSettingChanged object:nil queue:NSOperationQueue.new usingBlock:^(NSNotification *note, id observer) {
        @strongify(self)
        [self refreshNotificationTags:note];
    }];

    return [self synchronize];
}

- (NSDictionary *)defaultsFromFile:(NSString *)file
{
    NSMutableDictionary *defaultsToRegister = NSMutableDictionary.new;
    NSString *settingsBundle = [self.bundle pathForResource:@"Settings" ofType:@"bundle"];
    if (settingsBundle)
    {
        NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[[settingsBundle stringByAppendingPathComponent:file] stringByAppendingPathExtension:@"plist"]];
        NSArray *preferences = settings[@"PreferenceSpecifiers"];

        for (NSDictionary *preference in preferences)
        {
            NSString *key = preference[@"Key"];
            if (key && [preference.allKeys containsObject:@"DefaultValue"])
            {
                defaultsToRegister[key] = preference[@"DefaultValue"];
            }
        }
    }
    return defaultsToRegister.copy;
}

- (void)refreshNotificationTags:(id)sender
{
    NSMutableDictionary *notificationTags = NSMutableDictionary.new;
    NSArray *notificationKeys = [self defaultsFromFile:kBMUserDefaultsNotificationsFile].allKeys;
    for (NSString *key in notificationKeys) {
        notificationTags[key] = [self storedBoolForKey:key] ? FBSDKAppEventParameterValueYes : FBSDKAppEventParameterValueNo;
    }
    [BMAnalyticsManager logNotificationTags:notificationTags.copy];
}

- (BOOL)storeObject:(id<NSSecureCoding>)object forKey:(NSString *)key
{
    if (object)
    {
        NSData *objectData = [NSKeyedArchiver archivedDataWithRootObject:object];
        
        return [self storeData:objectData forKey:key];
    }
    
    return NO;
}

- (id)storedObjectForKey:(NSString *)key
{
    NSData *data = [self storedDataForKey:key];
    
    if ([data isKindOfClass:NSData.class])
    {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return nil;
}

- (BOOL)storeString:(NSString *)string forKey:(NSString *)key
{
    if ([string isKindOfClass:NSString.class])
    {
        NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        return [self storeData:stringData forKey:key];
    }
    
    return NO;
}

- (NSString *)storedStringForKey:(NSString *)key
{
    NSData *data = [self storedDataForKey:key];
    
    if ([data isKindOfClass:NSData.class] && data.bytes != NULL)
    {
        return [NSString stringWithUTF8String:data.bytes];
    }
    else if ([data isKindOfClass:NSString.class])
    {
        return (NSString *)data;
    }
    
    return nil;
}

- (BOOL)storeData:(NSData *)data forKey:(NSString *)key
{
    if ([data isKindOfClass:NSData.class] && [key isKindOfClass:NSString.class])
    {
        NSData *encryptedData = [RNCryptorManager encryptData:data password:key];
        
        if (encryptedData)
        {
            [self.userDefaults setObject:encryptedData forKey:key];
            return [self synchronize];
        }
    }
    
    return NO;
}

- (NSData *)storedDataForKey:(NSString *)key
{
    if ([key isKindOfClass:NSString.class])
    {
        NSData *encryptedData = [self.userDefaults objectForKey:key];
        
        if ([encryptedData isKindOfClass:NSData.class])
        {
            return [RNCryptorManager decryptData:encryptedData password:key];
        }
        
        return encryptedData;
    }
    
    return nil;
}

- (BOOL)storeNumber:(NSNumber *)number forKey:(NSString *)key
{
    if ([key isKindOfClass:NSString.class])
    {
        [self.userDefaults setObject:number forKey:key];
        return [self synchronize];
    }
    
    return NO;
}

- (NSNumber *)storedNumberForKey:(NSString *)key
{
    return [key isKindOfClass:NSString.class] ? [self.userDefaults objectForKey:key] : nil;
}

- (BOOL)storeBool:(BOOL)boolValue forKey:(NSString *)key
{
    if ([key isKindOfClass:NSString.class])
    {
        [self.userDefaults setBool:boolValue forKey:key];
        return [self synchronize];
    }
    
    return NO;
}

- (BOOL)storedBoolForKey:(NSString *)key
{
    return [key isKindOfClass:NSString.class] && [self.userDefaults boolForKey:key];
}

- (BOOL)removeObjectForKey:(NSString *)key
{
    if ([key isKindOfClass:NSString.class])
    {
        [self.userDefaults removeObjectForKey:key];
        return [self synchronize];
    }
    
    return NO;
}

- (BOOL)truncateUserDefaults
{
    [self.userDefaults removeObjectForKey:kBMUserDefaultsAuthKey];
    [self.userDefaults removeObjectForKey:kBMUserDefaultsDNIKey];
    return [self synchronize];
}

- (BOOL)synchronize
{
    return [self.userDefaults synchronize];
}

@end
