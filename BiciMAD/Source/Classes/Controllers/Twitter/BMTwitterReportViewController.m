//
//  BMTwitterReportViewController.m
//  BiciMAD
//
//  Created by alexruperez on 4/8/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

#import "BMTwitterReportViewController.h"

@import TwitterKit;
@import SVProgressHUD;

#import "BMManagersAssembly.h"
#import "BMAnalyticsManager.h"
#import "BMDraggableDialogManager.h"
#import "MADBike-Swift.h"

static NSString * const kBMTwitterReportUpdateStatusURLString = @"https://api.twitter.com/1.1/statuses/update.json";
static NSString * const kBMTwitterReportPOSTMethod = @"POST";

static NSString * const kBMTwitterReportStatusKey = @"status";
static NSString * const kBMTwitterReportDisplayCoordinatesKey = @"display_coordinates";
static NSString * const kBMTwitterReportMediaKey = @"media_ids";
static NSString * const kBMTwitterReportLatitudeKey = @"lat";
static NSString * const kBMTwitterReportLongitudeKey = @"long";
static NSString * const kBMTwitterReportTrueValue = @"true";
static NSString * const kBMTwitterReportCoordinateFormat = @"%.8f";

static NSString * const kBMTwitterReportJPEGContentType = @"image/jpeg";

@interface BMTwitterReportViewController ()

@property (nonatomic, strong, readonly) Twitter *twitter;

@property (nonatomic, strong, readonly) TWTRAPIClient *APIClient;

@end

@implementation BMTwitterReportViewController

- (Twitter *)twitter
{
    return Twitter.sharedInstance;
}

- (TWTRAPIClient *)APIClient
{
    return TWTRAPIClient.clientWithCurrentUser;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setUserActivityWithActivityType:kBMMADBikeUserActivityReport title:NSLocalizedString(@"Report", @"Report") description:NSLocalizedString(@"#MADBikeLost", @"#MADBikeLost")];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [BMAnalyticsManager logContentViewWithName:self.bm_className contentType:nil contentId:nil customAttributes:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)reportImage:(UIImage *)image mediaID:(NSString *)mediaID
{
    CLLocation *location = self.managersAssembly.locationManager.location;
    if (location && CLLocationCoordinate2DIsValid(location.coordinate))
    {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Acquiring location...", @"Acquiring location...")];
        
        @weakify(self)
        [self.managersAssembly.geocoderManager reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            @strongify(self)
            if (placemarks.count > 0 && !error)
            {
                CLPlacemark *placemark = placemarks.firstObject;
                [self reportImage:image mediaID:mediaID coordinate:placemark.location.coordinate placemark:placemark];
            }
            else
            {
                [self reportImage:image mediaID:mediaID coordinate:location.coordinate placemark:nil];
            }
        }];
    }
    else
    {
        [self reportImage:image mediaID:mediaID coordinate:kCLLocationCoordinate2DInvalid placemark:nil];
    }
}

- (void)reportImage:(UIImage *)image mediaID:(NSString *)mediaID coordinate:(CLLocationCoordinate2D)coordinate placemark:(CLPlacemark *)placemark
{
    NSMutableDictionary *parameters = NSMutableDictionary.new;
    parameters[kBMTwitterReportStatusKey] = [NSString stringWithFormat:NSLocalizedString(@"@madbikeapp #MADBikeLost %@", @"@madbikeapp #MADBikeLost %@"), placemark.name ? placemark.name : @""];
    parameters[kBMTwitterReportDisplayCoordinatesKey] = kBMTwitterReportTrueValue;
    if (mediaID.length > 0)
    {
        parameters[kBMTwitterReportMediaKey] = mediaID;
    }
    if (CLLocationCoordinate2DIsValid(coordinate))
    {
        parameters[kBMTwitterReportLatitudeKey] = [NSString stringWithFormat:kBMTwitterReportCoordinateFormat, coordinate.latitude];
        parameters[kBMTwitterReportLongitudeKey] = [NSString stringWithFormat:kBMTwitterReportCoordinateFormat, coordinate.longitude];
    }
    NSError *error = nil;
    NSURLRequest *request = [self.APIClient URLRequestWithMethod:kBMTwitterReportPOSTMethod URLString:kBMTwitterReportUpdateStatusURLString parameters:parameters.copy error:&error];
    if (!error)
    {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Reporting...", @"Reporting...")];
        @weakify(self)
        [self.APIClient sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            @strongify(self)
            if (!connectionError)
            {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Reported!", @"Reported!")];
                NSError *serializationError = nil;
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&serializationError];
                if (!serializationError)
                {
                    TWTRTweet *tweet = [[TWTRTweet alloc] initWithJSONDictionary:responseDictionary];
                    if (tweet)
                    {
                        [self.tweetPresenter presentTweetWithTweet:tweet view:self.view completion:^(NSUInteger buttonIndex, NSError *tweetError) {
                            @strongify(self)
                            [self dismissImagePickerController];
                            [BMAnalyticsManager logContentViewWithName:kBMIncidenceKey contentType:self.bm_className contentId:nil customAttributes:@{kBMSourceKey: self.bm_className, FBSDKAppEventParameterNameSuccess: tweetError == nil ? FBSDKAppEventParameterValueYes : FBSDKAppEventParameterValueNo}];
                        }];
                        [SVProgressHUD dismissWithDelay:1.f];
                    }
                    
                }
            }
            else
            {
                [self showError:connectionError];
            }
        }];
    }
    else
    {
        [self showError:error];
    }
}

- (void)dismissImagePickerController
{
    [self dismissImagePickerControllerAnimated:YES];
}

- (void)dismissImagePickerControllerAnimated:(BOOL)animated
{
    [self dismissViewControllerAnimated:animated completion:nil];
}

- (void)showError:(NSError *)error {
    NSString *localizedDescription = error.localizedDescription;
    if (localizedDescription.length > 0)
    {
        @weakify(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([SVProgressHUD displayDurationForString:localizedDescription] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self)
            [self dismissImagePickerController];
        });
        [SVProgressHUD showErrorWithStatus:localizedDescription];
    }
    else
    {
        [self dismissImagePickerController];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Uploading image...", @"Uploading image...")];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData *data = UIImageJPEGRepresentation(image, 0.5f);
    @weakify(self)
    [self.APIClient uploadMedia:data contentType:kBMTwitterReportJPEGContentType completion:^(NSString *mediaID, NSError *error) {
        @strongify(self)
        if (mediaID && !error)
        {
            [self reportImage:image mediaID:mediaID];
        }
        else
        {
            [self showError:error];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissImagePickerController];
}

@end
