source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.3'
use_frameworks!
inhibit_all_warnings!

def base_pods
    pod 'OneSignal', '>= 2.6.2', '< 3.0'
end

def app_pods
    base_pods
    pod 'AFNetworkActivityLogger', '~> 3.0'
    pod 'AFNetworking', '~> 3.2'
    pod 'BBBadgeBarButtonItem', '~> 1.2'
    pod 'Branch'
    pod 'CCHMapClusterController', '~> 1.7'
    pod 'Charts', '3.3'
    pod 'CMMapLauncher', :git => 'https://github.com/alexruperez/CMMapLauncher.git'
    pod 'Crashlytics', '~> 3.10'
    pod 'DGRunkeeperSwitch', :git => 'https://github.com/aakpro/DGRunkeeperSwitch.git'
    pod 'DOFavoriteButton', :git => 'https://github.com/okmr-d/DOFavoriteButton.git'
    pod 'DTMHeatmap', '~> 1.0'
    pod 'Fabric', '~> 1.7'
    pod 'FBSDKCoreKit', '~> 4.36'
    pod 'FXNotifications', '~> 1.1'
    pod 'GearRefreshControl', '~> 1.0'
    pod 'GoogleMaps', '~> 3.0'
    pod 'GooglePlaces', '~> 3.0'
    pod 'InAppSettingsKit', '~> 2.9'
    pod 'INTULocationManager', '~> 4.3'
    pod 'libextobjc', '~> 0.4'
    pod 'MagicalRecord/CocoaLumberjack', '~> 2.3'
    pod 'Mantle', '~> 2.1'
    pod 'MTLManagedObjectAdapter', '~> 1.0'
    pod 'OpenInGoogleMaps', '~> 0.1'
    pod 'Popover', '1.2.2'
    pod 'RESideMenu', '~> 4.0'
    pod 'RNCryptor', '5.1.0'
    pod 'SFDraggableDialogView', '~> 1.1'
    pod 'SmileWeather', '~> 0.2'
    pod 'SVProgressHUD', '~> 2.2'
    pod 'SVPulsingAnnotationView', :git => 'https://github.com/TransitApp/SVPulsingAnnotationView.git'
    pod 'TwitterKit', '~> 3.4'
    pod 'Typhoon', '~> 3.6'
    pod 'Zephyr', '3.4.1'
    
    plugin 'cocoapods-keys', {
      project: "BiciMAD",
      keys: [
        "GoogleMapsAPIKey",
        "GooglePlacesAPIKey",
        "OneSignalAppID",
        "TwitterConsumerKey",
		"TwitterConsumerSecret",
        "EMTClientId",
        "EMTPassKey",
        "MADBikeAPIUserEmail",
        "MADBikeAPIUserToken"
      ]
    }
end

target 'BiciMAD' do
    app_pods
    pod 'ARFacebookShareKitActivity', '~> 1.1'
end

target 'Notifications' do
    base_pods
end

post_install do |installer|
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-BiciMAD/Pods-BiciMAD-acknowledgements.plist', 'BiciMAD/Resources/Settings/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
