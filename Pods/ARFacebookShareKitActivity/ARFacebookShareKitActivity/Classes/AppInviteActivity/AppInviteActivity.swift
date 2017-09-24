//
//  AppInviteActivity.swift
//  ARFacebookShareKitActivity
//
//  Created by alexruperez on 2/6/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import FBSDKShareKit

@objc open class AppInviteActivity: UIActivity {
    
    open var title: String?
    open var image: UIImage?
    open static var category: UIActivityCategory?
    
    fileprivate lazy var appInviteDialog: FBSDKAppInviteDialog = {
        
        let appInviteDialog = FBSDKAppInviteDialog()
        appInviteDialog.delegate = self
        appInviteDialog.content = FBSDKAppInviteContent()
        
        return appInviteDialog
    }()
    
    open override class var activityCategory : UIActivityCategory {
        return category ?? .share
    }
    
    open class func setActivityCategory(_ category: UIActivityCategory) {
        self.category = category
    }
    
    public convenience init(title: String?, image: UIImage?) {
        self.init()
        self.title = title
        self.image = image
    }
    
    open override var activityType : UIActivityType? {
        return UIActivityType(String(describing: AppInviteActivity.self))
    }
    
    open override var activityTitle : String? {
        return title ?? NSLocalizedString("Facebook Invite", comment: "\(activityType!) Title")
    }
    
    open override var activityImage : UIImage? {
        return image ?? UIImage(named: "\(activityType!)\(AppInviteActivity.activityCategory.rawValue)", in: Bundle(for: AppInviteActivity.self), compatibleWith: nil)
    }
    
    open override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for item in activityItems {
            if let appLinkURL = item as? URL {
                appInviteDialog.content.appLinkURL = appLinkURL
            }
            if let promotionText = item as? String {
                appInviteDialog.content.promotionText = promotionText
            }
        }
        
        do {
            try appInviteDialog.validate()
            return appInviteDialog.canShow()
        } catch {
            return false
        }
    }
    
    open override func perform() {
        appInviteDialog.show()
    }
    
}
