//
//  TweetPresenter.swift
//  BiciMAD
//
//  Created by alexruperez on 6/10/16.
//  Copyright © 2016 alexruperez. All rights reserved.
//

import UIKit
import TwitterKit

typealias TweetPresenterCompletion = (_ buttonIndex: UInt, _ error: NSError?) -> ()

@objc class TweetPresenter: NSObject {

    let client: TWTRAPIClient
    let draggableDialogManager: BMDraggableDialogManager

    @objc init(client: TWTRAPIClient, draggableDialogManager: BMDraggableDialogManager) {
        self.client = client
        self.draggableDialogManager = draggableDialogManager
    }

    @objc func presentTweet(id: String, view: UIView, completion: TweetPresenterCompletion?) {
        client.loadTweet(withID: id) { tweet, error in
            guard let tweet = tweet else {
                completion?(0, error as NSError?)
                return
            }
            self.presentTweet(tweet: tweet, view: view, completion: completion)
        }
    }

    @objc func presentTweet(tweet: TWTRTweet, view: UIView, completion: TweetPresenterCompletion?) {
        let tweetView = TWTRTweetView(tweet: tweet)
        tweetView.showBorder = false
        tweetView.showActionButtons = true

        draggableDialogManager.presentCustomView(tweetView, firstButton: NSLocalizedString("Ok", comment: "Ok"), cancelButton: " ", in: view) { buttonIndex in
            BMAnalyticsManager.logContentView(withName: String(describing: BMDraggableDialogManager.self), contentType: String(describing: TWTRTweet.self), contentId: tweet.tweetID, customAttributes: [FBSDKAppEventParameterNameContentType: String(describing: TWTRTweet.self), FBSDKAppEventParameterNameContentID: tweet.tweetID != .none ? tweet.tweetID : ""])
            completion?(buttonIndex, nil)
        }
    }
}
