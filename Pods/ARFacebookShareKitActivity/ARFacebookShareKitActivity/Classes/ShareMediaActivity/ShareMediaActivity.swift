//
//  ShareMediaActivity
//  ARFacebookShareKitActivity
//
//  Created by alexruperez on 2/6/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import FBSDKShareKit

@objc open class ShareMediaActivity: UIActivity {
    
    open var title: String?
    open var image: UIImage?
    open var mode: FBSDKShareDialogMode = .automatic
    open static var category: UIActivityCategory?
    
    fileprivate lazy var shareDialog: FBSDKShareDialog = {
        
        let shareDialog = FBSDKShareDialog()
        shareDialog.delegate = self
        let shareContent = FBSDKShareMediaContent()
        shareContent.media = [AnyObject]()
        shareDialog.shareContent = shareContent
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
        return UIActivityType(String(describing: ShareMediaActivity.self))
    }
    
    open override var activityTitle : String? {
        return title ?? NSLocalizedString("Facebook Upload", comment: "\(activityType!) Title")
    }
    
    open override var activityImage : UIImage? {
        return image ?? UIImage(named: "\(activityType!)\(ShareMediaActivity.activityCategory.rawValue)", in: Bundle(for: ShareMediaActivity.self), compatibleWith: nil)
    }
    
    open override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for item in activityItems {
            if let contentURL = item as? URL {
                shareDialog.shareContent.contentURL = contentURL
            }
            if let image = item as? UIImage {
                if let shareContent = shareDialog.shareContent as? FBSDKShareMediaContent {
                    let photo = FBSDKSharePhoto(image: image, userGenerated: true)
                    shareContent.media.append(photo)
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
