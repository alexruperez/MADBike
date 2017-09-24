//
//  UIActivity+FBSDKSharingDelegate.swift
//  ARFacebookShareKitActivity
//
//  Created by alexruperez on 2/6/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import FBSDKShareKit

extension UIActivity : FBSDKAppInviteDialogDelegate, FBSDKSharingDelegate {
    public func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        activityDidFinish(true)
    }
    
    public func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        let appInviteContent = appInviteDialog.content
        let linkContent = FBSDKShareLinkContent()
        linkContent.quote = appInviteContent?.promotionText
        linkContent.contentURL = appInviteContent?.appLinkURL
        FBSDKShareDialog.show(from: appInviteDialog.fromViewController, with: linkContent, delegate: self)
    }
    
    public func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        activityDidFinish(true)
    }
    
    public func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        activityDidFinish(false)
    }
    
    public func sharerDidCancel(_ sharer: FBSDKSharing!) {
        activityDidFinish(false)
    }
}
