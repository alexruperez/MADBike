//
//  UIResponder+UserActivity.swift
//

import UIKit
import CoreSpotlight
import MobileCoreServices
import MapKit
import Intents

@objc public extension UIResponder {

    @objc func setUserActivity(activityType: String, title: String, description: String?) {
        setUserActivity(activityType, title: title, contentDescription: description)
    }

    @discardableResult func setUserActivity(_ activityType: String,
                                                   title: String,
                                                   contentDescription: String? = nil,
                                                   thumbnailData: Data? = nil,
                                                   userInfo: [AnyHashable : Any] = [:],
                                                   requiredKeys: Set<String> = Set<String>(),
                                                   needsSave: Bool = false,
                                                   webpageURL: URL? = nil,
                                                   referrerURL: URL? = nil,
                                                   expiration: Date? = nil,
                                                   displayName: String? = nil,
                                                   keywords: Set<String> = Set<String>(),
                                                   continuationStreams: Bool = false,
                                                   delegate: NSUserActivityDelegate? = nil,
                                                   becomeCurrent: Bool = true,
                                                   search: Bool = true,
                                                   handoff: Bool = true,
                                                   publicIndexing: Bool = true,
                                                   prediction: Bool = true,
                                                   persistentIdentifier: String? = nil,
                                                   suggestedInvocationPhrase: String? = nil,
                                                   mapItem: MKMapItem? = nil,
                                                   attributeSet: CSSearchableItemAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String),
                                                   supportsNavigation: Bool = true,
                                                   supportsPhoneCall: Bool = true) -> NSUserActivity {
        let userActivity = NSUserActivity(activityType: activityType)
        attributeSet.contentDescription = contentDescription
        attributeSet.thumbnailData = thumbnailData
        attributeSet.displayName = displayName ?? title
        attributeSet.keywords = Array(keywords)
        userActivity.contentAttributeSet = attributeSet
        userActivity.contentAttributeSet?.supportsNavigation = NSNumber(value: supportsNavigation)
        userActivity.contentAttributeSet?.supportsPhoneCall = NSNumber(value: supportsPhoneCall)
        userActivity.title = title
        userActivity.userInfo = userInfo
        userActivity.requiredUserInfoKeys = requiredKeys
        userActivity.needsSave = needsSave
        userActivity.webpageURL = webpageURL
        if #available(iOS 11.0, *) {
            userActivity.referrerURL = referrerURL
        }
        if let expiration = expiration {
            userActivity.expirationDate = expiration
        }
        userActivity.keywords = keywords
        userActivity.supportsContinuationStreams = continuationStreams
        userActivity.delegate = delegate
        userActivity.isEligibleForSearch = search
        userActivity.isEligibleForHandoff = handoff
        userActivity.isEligibleForPublicIndexing = publicIndexing
        if #available(iOS 12.0, *) {
            userActivity.isEligibleForPrediction = prediction
            userActivity.persistentIdentifier = persistentIdentifier ?? activityType
            #if swift(>=4.2)
            userActivity.suggestedInvocationPhrase = suggestedInvocationPhrase ?? title
            #endif
        }
        if let mapItem = mapItem {
            userActivity.mapItem = mapItem
        }
        self.userActivity = userActivity
        if becomeCurrent {
            userActivity.becomeCurrent()
        }
        return userActivity
    }

}
