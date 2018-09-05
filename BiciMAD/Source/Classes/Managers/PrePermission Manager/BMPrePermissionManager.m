//
//  BMPrePermissionManager.m
//  BiciMAD
//
//  Created by alexruperez on 12/8/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMPrePermissionManager.h"

@import TwitterKit;
@import CoreLocation;
@import AVFoundation;

#import "BMAnalyticsManager.h"

static NSString * const kBMTwitterCreateFriendshipsURLString = @"https://api.twitter.com/1.1/friendships/create.json";
static NSString * const kBMTwitterPOSTMethod = @"POST";

static NSString * const kBMTwitterCreateFriendshipsFollowKey = @"follow";
static NSString * const kBMTwitterCreateFriendshipsScreenNameKey = @"screen_name";

static NSString * const kBMTwitterCreateFriendshipsScreenNameValue = @"madbikeapp";
static NSString * const kBMTwitterCreateFriendshipsTrueValue = @"true";

@interface BMPrePermissionManager ()

@property (nonatomic, strong) Twitter *twitter;

@end

@implementation BMPrePermissionManager

- (Twitter *)twitter
{
    return Twitter.sharedInstance;
}

- (TWTRAPIClient *)APIClient
{
    return TWTRAPIClient.clientWithCurrentUser;
}

+ (void)openSettings:(UIApplication *)application completionHandler:(BMPrePermissionCompletionHandler)completionHandler
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    BOOL result = NO;
    
    if ([application canOpenURL:url])
    {
        [application openURL:url options:@{} completionHandler:completionHandler];
        result = YES;
    }

    if (completionHandler)
    {
        completionHandler(result);
    }
}

- (void)location:(BMPrePermissionCompletionHandler)completionHandler
{
    @weakify(self)
    CLAuthorizationStatus locationAuthorizationStatus = CLLocationManager.authorizationStatus;
    switch (locationAuthorizationStatus) {
        case kCLAuthorizationStatusNotDetermined:
        {
            [self.draggableDialogManager presentDialogWithPhoto:[UIImage imageNamed:@"ic_location"] title:NSLocalizedString(@"Location ask title", @"Location ask title") message:NSLocalizedString(@"Location ask message", @"Location ask message") inView:nil completionHandler:^(NSUInteger buttonIndex) {
                @strongify(self)
                [BMAnalyticsManager logContentViewWithName:NSStringFromClass(BMDraggableDialogManager.class) contentType:NSStringFromClass(CLLocationManager.class) contentId:nil customAttributes:@{FBSDKAppEventParameterNameContentType: NSStringFromClass(CLLocationManager.class), FBSDKAppEventParameterNameContentID: @(locationAuthorizationStatus)}];
                if (buttonIndex == 0)
                {
                    [self.locationManager requestWhenInUseAuthorization];
                }
                if (completionHandler)
                {
                    completionHandler(buttonIndex == 0);
                }
            }];
            break;
        }
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        {
            [self.draggableDialogManager presentDialogWithPhoto:[UIImage imageNamed:@"ic_location"] title:NSLocalizedString(@"Location demand title", @"Location demand title") message:NSLocalizedString(@"Location demand message", @"Location demand message") inView:nil completionHandler:^(NSUInteger buttonIndex) {
                @strongify(self)
                [BMAnalyticsManager logContentViewWithName:NSStringFromClass(BMDraggableDialogManager.class) contentType:NSStringFromClass(CLLocationManager.class) contentId:nil customAttributes:@{FBSDKAppEventParameterNameContentType: NSStringFromClass(CLLocationManager.class), FBSDKAppEventParameterNameContentID: @(locationAuthorizationStatus)}];
                if (buttonIndex == 0)
                {
                    [self.class openSettings:self.application completionHandler:completionHandler];
                }
                else if (completionHandler)
                {
                    completionHandler(NO);
                }
            }];
            break;
        }
        default:
        {
            if (completionHandler)
            {
                completionHandler(YES);
            }
            break;
        }
    }
}

- (void)camera:(BMPrePermissionCompletionHandler)completionHandler
{
    AVAuthorizationStatus videoAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (videoAuthorizationStatus) {
        case AVAuthorizationStatusNotDetermined:
        {
            [self.draggableDialogManager presentDialogWithPhoto:[UIImage imageNamed:@"ic_camera"] title:NSLocalizedString(@"Camera ask title", @"Camera ask title") message:NSLocalizedString(@"Camera ask message", @"Camera ask message") inView:nil completionHandler:^(NSUInteger buttonIndex) {
                [BMAnalyticsManager logContentViewWithName:NSStringFromClass(BMDraggableDialogManager.class) contentType:NSStringFromClass(AVCaptureDevice.class) contentId:nil customAttributes:@{FBSDKAppEventParameterNameContentType: NSStringFromClass(AVCaptureDevice.class), FBSDKAppEventParameterNameContentID: @(videoAuthorizationStatus)}];
                if (buttonIndex == 0)
                {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        if (completionHandler)
                        {
                            completionHandler(granted);
                        }
                    }];
                }
                else if (completionHandler)
                {
                    completionHandler(NO);
                }
            }];
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
        {
            @weakify(self)
            [self.draggableDialogManager presentDialogWithPhoto:[UIImage imageNamed:@"ic_camera"] title:NSLocalizedString(@"Camera demand title", @"Camera demand title") message:NSLocalizedString(@"Camera demand message", @"Camera demand message") inView:nil completionHandler:^(NSUInteger buttonIndex) {
                @strongify(self)
                [BMAnalyticsManager logContentViewWithName:NSStringFromClass(BMDraggableDialogManager.class) contentType:NSStringFromClass(AVCaptureDevice.class) contentId:nil customAttributes:@{FBSDKAppEventParameterNameContentType: NSStringFromClass(AVCaptureDevice.class), FBSDKAppEventParameterNameContentID: @(videoAuthorizationStatus)}];
                if (buttonIndex == 0)
                {
                    [self.class openSettings:self.application completionHandler:completionHandler];
                }
                else if (completionHandler)
                {
                    completionHandler(NO);
                }
            }];
            break;
        }
        default:
            if (completionHandler)
            {
                completionHandler(YES);
            }
            break;
    }
}

- (void)twitter:(BMPrePermissionCompletionHandler)completionHandler
{
    if (!self.twitter.sessionStore.session)
    {
        @weakify(self)
        [self.draggableDialogManager presentDialogWithPhoto:[UIImage imageNamed:@"ic_twitter"] title:NSLocalizedString(@"Twitter ask title", @"Twitter ask title") message:NSLocalizedString(@"Twitter ask message", @"Twitter ask message") inView:nil completionHandler:^(NSUInteger buttonIndex) {
            @strongify(self)
            [BMAnalyticsManager logContentViewWithName:NSStringFromClass(BMDraggableDialogManager.class) contentType:NSStringFromClass(TWTRSession.class) contentId:nil customAttributes:@{FBSDKAppEventParameterNameContentType: NSStringFromClass(TWTRSession.class)}];
            if (buttonIndex == 0)
            {
                [self.twitter logInWithCompletion:^(TWTRSession *session, NSError *error) {
                    [BMAnalyticsManager logLoginWithMethod:kBMTwitterLoginMethodKey success:@(!error) customAttributes:@{kBMLoginIDKey: session.userID ? session.userID : NSNull.null, kBMLoginNameKey: session.userName ? session.userName : NSNull.null, FBSDKAppEventParameterNameSuccess: !error ? FBSDKAppEventParameterValueYes : FBSDKAppEventParameterValueNo}];
                    NSError *requestError = nil;
                    NSURLRequest *request = [self.APIClient URLRequestWithMethod:kBMTwitterPOSTMethod URLString:kBMTwitterCreateFriendshipsURLString parameters:@{kBMTwitterCreateFriendshipsScreenNameKey: kBMTwitterCreateFriendshipsScreenNameValue, kBMTwitterCreateFriendshipsFollowKey: kBMTwitterCreateFriendshipsTrueValue} error:&requestError];
                    [self.APIClient sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                        if (completionHandler)
                        {
                            completionHandler(session && !error);
                        }
                    }];
                }];
            }
            else if (completionHandler)
            {
                completionHandler(NO);
            }
        }];
    }
    else if (completionHandler)
    {
        completionHandler(YES);
    }
}

- (void)push:(BMPrePermissionCompletionHandler)completionHandler
{
    if (!self.application.isRegisteredForRemoteNotifications)
    {
        [self.draggableDialogManager presentDialogWithPhoto:[UIImage imageNamed:@"ic_notification"] title:NSLocalizedString(@"Push ask title", @"Push ask title") message:NSLocalizedString(@"Push ask message", @"Push ask message") inView:nil completionHandler:^(NSUInteger buttonIndex) {
            [BMAnalyticsManager logContentViewWithName:NSStringFromClass(BMDraggableDialogManager.class) contentType:nil contentId:nil customAttributes:nil];
            BOOL success = NO;
            if (buttonIndex == 0)
            {
                [BMAnalyticsManager registerForRemoteNotifications];
                success = YES;
            }
            if (completionHandler)
            {
                completionHandler(success);
            }
        }];
    }
    else if (completionHandler)
    {
        completionHandler(YES);
    }
}

@end
