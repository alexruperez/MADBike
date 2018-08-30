# ARFacebookShareKitActivity

[![Twitter](http://img.shields.io/badge/contact-@alexruperez-blue.svg?style=flat)](http://twitter.com/alexruperez)
[![Version](https://img.shields.io/cocoapods/v/ARFacebookShareKitActivity.svg?style=flat)](http://cocoapods.org/pods/ARFacebookShareKitActivity)
[![License](https://img.shields.io/cocoapods/l/ARFacebookShareKitActivity.svg?style=flat)](http://cocoapods.org/pods/ARFacebookShareKitActivity)
[![Platform](https://img.shields.io/cocoapods/p/ARFacebookShareKitActivity.svg?style=flat)](http://cocoapods.org/pods/ARFacebookShareKitActivity)
[![Analytics](https://ga-beacon.appspot.com/UA-55329295-1/ARFacebookShareKitActivity/readme?pixel)](https://github.com/igrigorik/ga-beacon)

## Overview

Launch [FBSDKShareDialog](https://developers.facebook.com/docs/reference/ios/current/class/FBSDKShareDialog/) from [UIActivityViewController](http://nshipster.com/uiactivityviewcontroller/) instead of the default Facebook share sheet.

![ARFacebookShareKitActivity Screenshot 1](https://raw.githubusercontent.com/alexruperez/ARFacebookShareKitActivity/master/screenshot1.jpg)

![ARFacebookShareKitActivity Screenshot 2](https://raw.githubusercontent.com/alexruperez/ARFacebookShareKitActivity/master/screenshot2.jpg)

#### Also compatible with Branch Metrics and Facebook App Invites!

If you are using [Branch Metrics](https://branch.io) and you want to use [Facebook App Invites](https://developers.facebook.com/docs/app-invites/overview) ([FBSDKAppInviteDialog](https://developers.facebook.com/docs/reference/ios/current/class/FBSDKAppInviteDialog/)), i'll do [this job](https://dev.branch.io/features/facebook-app-invites/overview/) for you!

Even if you have custom domain registered or the legacy domain.

![ARFacebookShareKitActivity Screenshot 3](https://raw.githubusercontent.com/alexruperez/ARFacebookShareKitActivity/master/screenshot3.jpg)

#### Like it, but don't want to replace the native sharing activity? Ok, no problem!

You can use the AppInviteActivity, ShareLinkActivity or ShareMediaActivity UIActivity subclasses.

Fully customizable: Title, image, category, mode...

Share activity:

![ARFacebookShareKitActivity Screenshot 4](https://raw.githubusercontent.com/alexruperez/ARFacebookShareKitActivity/master/screenshot4.jpg)

Action activity:

![ARFacebookShareKitActivity Screenshot 5](https://raw.githubusercontent.com/alexruperez/ARFacebookShareKitActivity/master/screenshot5.jpg)

## Installation

ARFacebookShareKitActivity is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ARFacebookShareKitActivity"
```

If you only need certain activities, there subspecs available:

```ruby
pod "ARFacebookShareKitActivity/SharingExtension"
pod "ARFacebookShareKitActivity/ShareLinkActivity"
pod "ARFacebookShareKitActivity/AppInviteActivity"
pod "ARFacebookShareKitActivity/ShareMediaActivity"
```

#### Or you can install it with [Carthage](https://github.com/Carthage/Carthage):

```ruby
github "alexruperez/ARFacebookShareKitActivity"
```

#### Or you can add the following files to your project:
* `UIActivity+FacebookShareKit.swift`
* `AppInviteActivity.swift`
* `ShareLinkActivity.swift`
* `ShareMediaActivity.swift`

## Usage

Use it in the same way you use [UIActivityViewController](http://nshipster.com/uiactivityviewcontroller/), that easy!

If you want to replace native Facebook UISocialActivity, just call `UIActivity.replaceFacebookSharing()`.

# Etc.

* Special thanks to [jilouc](https://github.com/jilouc)/[CCAFacebookAppActivity](https://github.com/jilouc/CCAFacebookAppActivity), which has inspired this repo.
* Also to my colleagues and friends, [JavierQuerol](https://github.com/JavierQuerol) and [PabloLerma](https://github.com/PabloLerma).
* Contributions are very welcome.
* Attribution is appreciated (let's spread the word!), but not mandatory.

## Use it? Love/hate it?

Tweet the author [@alexruperez](http://twitter.com/alexruperez), and check out alexruperez's blog: http://alexruperez.com

## License

ARFacebookShareKitActivity is available under the [MIT license](https://opensource.org/licenses/MIT). See the [LICENSE file](https://github.com/alexruperez/ARFacebookShareKitActivity/blob/master/LICENSE) for more info.
