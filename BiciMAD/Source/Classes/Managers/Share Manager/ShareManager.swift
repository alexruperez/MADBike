//
//  ShareManager.swift
//  BiciMAD
//
//  Created by alexruperez on 15/11/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

import UIKit
import Branch

class ShareManager: NSObject {
    fileprivate struct Constants {
        static let madbikeLinkKey = kBMMADBikeLinkKey
        static let pointsURLScheme = "madbike://share"
        static let titleKey = "$og_title"
        static let descriptionKey = "$og_description"
        static let desktopURLKey = "$desktop_url"
        static let iOSDeepViewKey = "$ios_deepview"
        static let androidDeepViewKey = "$android_deepview"
        static let pointsDeepViewValue = "madpoints_deepview_j01b"
        static let emailSubject = BRANCH_LINK_DATA_KEY_EMAIL_SUBJECT
        static let shareTag = BRANCH_FEATURE_TAG_SHARE
        static let referralTag = BRANCH_FEATURE_TAG_REFERRAL
        static let contentType = FBSDKAppEventParameterNameContentType
        static let successKey = FBSDKAppEventParameterNameSuccess
        static let yesValue = FBSDKAppEventParameterValueYes
        static let noValue = FBSDKAppEventParameterValueNo
    }

    @objc func shareStation(_ station: AnyObject, fromViewController: UIViewController, barButtonItem: AnyObject?, handler: ((_ activityType: String?, _ completed: Bool) -> ())?) {
        guard let station = station as? BMStation else {
            if let handler = handler {
                handler(nil, false)
            }
            return
        }

        let anchor = barButtonItem is UIBarButtonItem ? barButtonItem as? UIBarButtonItem : fromViewController.navigationItem.leftBarButtonItem
        var shareText = NSLocalizedString("MADBike", comment: "MADBike")
        if let title = station.title {
            shareText.append(" - \(title)")
        }
        let linkProperties = BranchLinkProperties()
        linkProperties.feature = Constants.shareTag
        linkProperties.addControlParam(Constants.madbikeLinkKey, withValue: station.urlScheme as String)
        linkProperties.addControlParam(Constants.desktopURLKey, withValue: station.urlString as String)
        linkProperties.addControlParam(Constants.emailSubject, withValue: shareText)
        linkProperties.addControlParam(Constants.titleKey, withValue: station.title)
        linkProperties.addControlParam(Constants.descriptionKey, withValue: station.subtitle)

        let branchUniversalObject = BranchUniversalObject(canonicalIdentifier: station.urlString as String)
        branchUniversalObject.showShareSheet(with: linkProperties, andShareText: shareText, from: fromViewController, anchor: anchor) { (activityType: String?, completed: Bool) in
            var method = ""
            if let activityType = activityType {
                method = activityType
                if let range = activityType.range(of: ".", options: .backwards) {
                    method = String(activityType.suffix(from: range.upperBound))
                }
            }
            BMAnalyticsManager.logShare(withMethod: method, contentName: station.name, contentType: String(describing: BMStation.self), contentId: station.stationId, customAttributes: [Constants.contentType : String(describing: BMStation.self), Constants.successKey: completed ? Constants.yesValue : Constants.noValue])
            if let handler = handler {
                handler(activityType, completed)
            }
        }
    }

    @objc func shareMADBike(_ fromViewController: UIViewController, barButtonItem: AnyObject?, handler: ((_ activityType: String?, _ completed: Bool) -> ())?) {
        let anchor = barButtonItem is UIBarButtonItem ? barButtonItem as? UIBarButtonItem : fromViewController.navigationItem.leftBarButtonItem
        let linkProperties = BranchLinkProperties()
        linkProperties.feature = Constants.referralTag
        linkProperties.addControlParam(Constants.madbikeLinkKey, withValue: Constants.pointsURLScheme)
        linkProperties.addControlParam(Constants.emailSubject, withValue: NSLocalizedString("MADBike", comment: "MADBike"))
        linkProperties.addControlParam(Constants.iOSDeepViewKey, withValue: Constants.pointsDeepViewValue)
        linkProperties.addControlParam(Constants.androidDeepViewKey, withValue: Constants.pointsDeepViewValue)

        let branchUniversalObject = BranchUniversalObject(canonicalIdentifier: Constants.pointsURLScheme)
        branchUniversalObject.showShareSheet(with: linkProperties, andShareText: NSLocalizedString("MADBike", comment: "MADBike"), from: fromViewController, anchor: anchor) { (activityType: String?, completed: Bool) in
            var method = ""
            if let activityType = activityType {
                method = activityType
                if let range = activityType.range(of: ".", options: .backwards) {
                    method = String(activityType.suffix(from: range.upperBound))
                }
            }
            BMAnalyticsManager.logInvite(withMethod: method, customAttributes: [Constants.contentType: method, Constants.successKey: completed ? Constants.yesValue : Constants.noValue])
            if let handler = handler {
                handler(activityType, completed)
            }
        }
    }
}
