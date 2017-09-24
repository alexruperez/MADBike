//
//  ShareLinkActivity.swift
//  ARFacebookShareKitActivity
//
//  Created by alexruperez on 2/6/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import FBSDKShareKit

@objc open class ShareLinkActivity: UIActivity {
    
    open var title: String?
    open var image: UIImage?
    open var mode: FBSDKShareDialogMode = .automatic
    open static var category: UIActivityCategory?
    
    fileprivate lazy var shareDialog: FBSDKShareDialog = {
        
        let shareDialog = FBSDKShareDialog()
        shareDialog.delegate = self
        shareDialog.shareContent = FBSDKShareLinkContent()
        shareDialog.mode = self.mode
        
        return shareDialog
    }()
    
    open override class var activityCategory : UIActivityCategory {
        return category ?? .share
    }
    
    open class func setActivityCategory(_ category: UIActivityCategory) {
        self.category = category
    }
    
    public convenience init(title: String?, image: UIImage?, mode: FBSDKShareDialogMode) {
        self.init()
        self.title = title
        self.image = image
        self.mode = mode
    }

    open override var activityType : UIActivityType? {
        return UIActivityType(String(describing: ShareLinkActivity.self))
    }
    
    open override var activityTitle : String? {
        return title ?? NSLocalizedString("Facebook Share", comment: "\(activityType!) Title")
    }
    
    open override var activityImage : UIImage? {
        return image ?? UIImage(named: "\(activityType!)\(ShareLinkActivity.activityCategory.rawValue)", in: Bundle(for: ShareLinkActivity.self), compatibleWith: nil)
    }
    
    open override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for item in activityItems {
            if let contentURL = item as? URL {
                shareDialog.shareContent.contentURL = contentURL
            }
            if let quote = item as? String {
                if let shareContent = shareDialog.shareContent as? FBSDKShareLinkContent {
                    shareContent.quote = quote
                }
            }
        }
        
        do {
            try shareDialog.validate()
            return shareDialog.canShow()
        } catch {
            return false
        }
    }
    
    open override func perform() {
        shareDialog.show()
    }
    
}
