source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

def base_pods
    pod 'OneSignal', '>= 2.5.2', '< 3.0'
end

def app_pods
    base_pods
    pod 'AFNetworkActivityLogger', :git => 'https://github.com/AFNetworking/AFNetworkActivityLogger.git', :branch => '3_0_0'
    pod 'AFNetworking', '~> 3.1'
    pod 'BBBadgeBarButtonItem', '~> 1.2'
    pod 'Branch'
    pod 'CCHMapClusterController', '~> 1.7'
    pod 'Charts', '3.0.4'
    pod 'CMMapLauncher', :git => 'https://github.com/alexruperez/CMMapLauncher.git'
    pod 'Crashlytics', '~> 3.8'
    pod 'DGRunkeeperSwitch', '~> 1.1'
    pod 'DOFavoriteButton', :git => 'https://github.com/okmr-d/DOFavoriteButton.git'
    pod 'DTMHeatmap', '~> 1.0'
    pod 'Fabric', '~> 1.6'
    pod 'FBSDKCoreKit', '~> 4.23'
    pod 'FXNotifications', '~> 1.1'
    pod 'GearRefreshControl', '~> 1.0'
    pod 'GoogleMaps', '~> 2.3'
    pod 'InAppSettingsKit', '~> 2.8'
    pod 'INTULocationManager', '~> 4.2'
    pod 'libextobjc', '~> 0.4'
    pod 'MagicalRecord/CocoaLumberjack', '~> 2.3'
    pod 'Mantle', '~> 2.0'
    pod 'MTLManagedObjectAdapter', '~> 1.0'
    pod 'OpenInGoogleMaps', '~> 0.1'
    pod 'Popover', '1.0.6'
    pod 'RESideMenu', '~> 4.0'
    pod 'RNCryptor', '5.0.1'
    pod 'SFDraggableDialogView', '~> 1.1'
    pod 'SmileWeather', '~> 0.2'
    pod 'SPGooglePlacesAutocomplete', '~> 1.0'
    pod 'SVProgressHUD', '~> 2.0'
    pod 'SVPulsingAnnotationView', :git => 'https://github.com/TransitApp/SVPulsingAnnotationView.git'
    pod 'TwitterKit', '~> 3.1'
    pod 'Typhoon', '~> 3.6'
    pod 'Zephyr', '2.2.3'
    
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

post_install do |installer|
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-BiciMAD/Pods-BiciMAD-acknowledgements.plist', 'BiciMAD/Resources/Settings/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
