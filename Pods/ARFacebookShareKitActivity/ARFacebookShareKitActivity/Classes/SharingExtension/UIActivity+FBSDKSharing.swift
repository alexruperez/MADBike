//
//  UIActivity+FBSDKSharing.swift
//  ARFacebookShareKitActivity
//
//  Created by alexruperez on 2/6/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import FBSDKShareKit

fileprivate extension DispatchQueue {

    private static var _onceTracker = [String]()

    class func once(token: String, block:()->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }

        if _onceTracker.contains(token) {
            return
        }

        _onceTracker.append(token)
        block()
    }
}

public extension UIActivity {
    fileprivate struct AssociatedKeys {
        static var ActivityContent = "ar_ActivityContent"
    }
    
    var activityContent: FBSDKCopying? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ActivityContent) as? FBSDKCopying
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.ActivityContent,
                    newValue as FBSDKCopying?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }

    private static let _onceToken = NSUUID().uuidString

    public class func replaceFacebookSharing() {
        let klass: AnyClass = NSClassFromString("UISoc"+"ialAct"+"ivity")!
        
        if self != klass {
            return
        }

        DispatchQueue.once(token: _onceToken) {
            ARSwizzleInstanceMethod(klass, originalSelector: #selector(UIActivity.prepare(withActivityItems:)), swizzledSelector: #selector(UIActivity.ar_prepare(withActivityItems:)))

            ARSwizzleInstanceMethod(klass, originalSelector: #selector(UIActivity.canPerform(withActivityItems:)), swizzledSelector: #selector(UIActivity.ar_canPerform(withActivityItems:)))

            ARSwizzleInstanceMethod(klass, originalSelector: Selector("UIActivity.perform"), swizzledSelector: #selector(UIActivity.ar_perform))
        }
    }
    
    private static func ar_defaultFacebookActivityType() -> UIActivityType? {
        struct Static {
            static var token: Int = 0
            static var activityType: UIActivityType? = nil
        }
        DispatchQueue.once(token: _onceToken) {
            Static.activityType = UIActivityType(["com", "apple", "UIKit", "activity", "PostToFacebook"].joined(separator: "."))
        }
        return Static.activityType
    }
    
    private static func ar_canShowFacebookShareDialog() -> Bool {
        return FBSDKShareDialog().canShow
    }
    
    private static func ar_canShowFacebookAppInviteDialog() -> Bool {
        return FBSDKAppInviteDialog().canShow
    }
    
    private func ar_canUseFacebookActivityOverride() -> Bool {
        return activityType == type(of: self).ar_defaultFacebookActivityType() && (type(of: self).ar_canShowFacebookShareDialog() || type(of: self).ar_canShowFacebookAppInviteDialog())
    }
    
    @objc func ar_canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return ar_canUseFacebookActivityOverride() || ar_canPerform(withActivityItems:activityItems)
    }
    
    @objc func ar_prepare(withActivityItems activityItems: [AnyObject]) {
        if !ar_canUseFacebookActivityOverride() {
            ar_prepare(withActivityItems:activityItems)
            return
        }
        
        var sharedURL: URL? = nil
        var sharedText: String? = nil
        
        for itemSource in activityItems {
            var item: AnyObject? = nil
            if itemSource.conforms(to: UIActivityItemSource.self) {
                if let activityType = activityType {
                    item = (itemSource as? UIActivityItemSource)?.activityViewController(activityViewController as! UIActivityViewController, itemForActivityType: activityType) as AnyObject?
                }
            } else {
                item = itemSource
            }
            
            if let item = item as? URL {
                sharedURL = item
            } else if let item = item as? String {
                sharedText = item
            }
        }
        
        if sharedURL == nil && sharedText == nil {
            activityDidFinish(false)
            return
        }
        
        var isAppInvite = false
        
        if let sharedURL = sharedURL {
            if let branchUniversalLinkDomains = Bundle.main.infoDictionary?["branch_universal_link_domains"] {
                if let oneDomain = branchUniversalLinkDomains as? String {
                    if sharedURL.host?.contains(oneDomain) == true {
                        isAppInvite = true
                    }
                } else if let branchUniversalLinkDomains = branchUniversalLinkDomains as? [String] {
                    for oneDomain: String in branchUniversalLinkDomains {
                        if sharedURL.host?.contains(oneDomain) == true {
                            isAppInvite = true
                        }
                    }
                }
            }
            
            let branchDomains = ["bnc.lt", "app.link", "test-app.link"]
            for oneDomain in branchDomains {
                if sharedURL.host?.contains(oneDomain) == true {
                    isAppInvite = true
                }
            }
        }
        
        if isAppInvite {
            let appInviteContent = FBSDKAppInviteContent()
            appInviteContent.promotionText = sharedText
            appInviteContent.appLinkURL = sharedURL
            activityContent = appInviteContent
        } else {
            let linkContent = FBSDKShareLinkContent()
            linkContent.quote = sharedText
            linkContent.contentURL = sharedURL
            activityContent = linkContent
        }
    }
    
    @objc func ar_perform() {
        if !ar_canUseFacebookActivityOverride() {
            ar_perform()
            return
        }
        
        if activityContent == nil {
            activityDidFinish(false)
            return
        }
        
        if let activityContent = activityContent as? FBSDKAppInviteContent {
            FBSDKAppInviteDialog.show(from: activityViewController, with: activityContent, delegate: self)
        } else if let activityContent = activityContent as? FBSDKSharingContent {
            FBSDKShareDialog.show(from: activityViewController, with: activityContent, delegate: self)
        }
    }
    
    private static func ARSwizzleInstanceMethod(_ klass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(klass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(klass, swizzledSelector)
        
        let didAddMethod = class_addMethod(klass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        
        if didAddMethod {
            class_replaceMethod(klass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
}
